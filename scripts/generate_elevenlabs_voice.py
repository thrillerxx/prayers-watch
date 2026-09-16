#!/usr/bin/env python3
"""Pre-render ElevenLabs TTS clips for Prayers Watch.

Reads ELEVENLABS_API_KEY from the local credentials file (never from git).
Watch playback uses the generated files; this script is Omarchy studio only.
"""

from __future__ import annotations

import argparse
import json
import os
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
JSON_PATH = REPO / "prayers" / "prayers Watch App" / "rosary_prayers_en.json"
AUDITION_DIR = REPO / "artifacts" / "voice-audition"
VOICEBANK_ROOT = REPO / "prayers" / "prayers Watch App" / "VoiceBank"
CREDENTIALS = Path("/home/car/.openclaw/credentials/prayers-watch-elevenlabs.env")
API = "https://api.elevenlabs.io/v1"
MODEL_ID = "eleven_multilingual_v2"

# Operator-approved shortlist (2026-09-16). slug, voice_id, display name.
SHORTLIST = [
    ("will", "bIHbv24MWmeRgasZH58o", "Will"),
    ("vestal", "80BSYnPfJdew4qey6gkW", "Vestal"),
    ("sofia-soft", "d3VKSMWd3Wo3CCCSDwEo", "Sofia"),
    ("setsuna", "l0IENxUSt1LQkQMIG7Ww", "Setsuna"),
    ("rowan", "kLhAstPcnnPxqzk6gS5i", "Rowan"),
    ("maxwell", "U9j1BBtczrnky1SP7UBR", "Maxwell"),
    ("emma", "GBRoBWNHbhTm0DtDRtiO", "Emma"),
    ("deacon-hugh", "4cY3czg0tgLP4TfI4JqZ", "Deacon Hugh"),
]

AUDITION_PRAYER_IDS = ("hail_mary", "apostles_creed")
# Premade library names on this account use "Name - descriptor".
AUDITION_VOICE_NAMES = (
    "Sarah",
    "Bella",
    "Lily",
    "George",
    "Daniel",
    "Brian",
)

ROSARY_IDS = [
    "sign_of_cross",
    "apostles_creed",
    "our_father",
    "opening_hail_mary_intention",
    "hail_mary",
    "glory_be",
    "fatima",
    "hail_holy_queen",
    "rosary_prayer",
    "st_michael",
    "st_joseph_after_rosary",
]
for _set in ("joyful", "luminous", "sorrowful", "glorious"):
    for _i in range(1, 6):
        ROSARY_IDS.append(f"mystery_{_set}_{_i}_announce")
        ROSARY_IDS.append(f"mystery_{_set}_{_i}_meditation")

VOICE_SETTINGS = {
    "stability": 0.75,
    "similarity_boost": 0.8,
    "style": 0.0,
    "use_speaker_boost": True,
    "speed": 0.9,
}


def load_api_key() -> str:
    if CREDENTIALS.is_file():
        for line in CREDENTIALS.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line.startswith("ELEVENLABS_API_KEY="):
                return line.split("=", 1)[1].strip().strip('"').strip("'")
    env = os.environ.get("ELEVENLABS_API_KEY", "").strip()
    if env:
        return env
    raise SystemExit(f"Missing ELEVENLABS_API_KEY (expected {CREDENTIALS})")


def prayer_texts() -> dict[str, str]:
    data = json.loads(JSON_PATH.read_text(encoding="utf-8"))
    out: dict[str, str] = {}
    for item in data["prayers"]:
        text = (item.get("translations") or {}).get("en") or ""
        if text.strip():
            out[item["id"]] = text.strip()
    return out


def api_request(path: str, key: str, data: bytes | None = None, accept: str = "application/json") -> bytes:
    delays = (1, 2, 4, 8, 16, 32)
    last_error: Exception | None = None
    for attempt, delay in enumerate((*delays, None)):
        req = urllib.request.Request(
            f"{API}{path}",
            data=data,
            method="POST" if data is not None else "GET",
            headers={
                "xi-api-key": key,
                "Accept": accept,
            },
        )
        if data is not None:
            req.add_header("Content-Type", "application/json")
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                return resp.read()
        except urllib.error.HTTPError as exc:
            body = exc.read().decode("utf-8", errors="replace")
            last_error = exc
            if exc.code in (429, 500, 502, 503) and delay is not None:
                print(f"retry {exc.code} in {delay}s ({path})", flush=True)
                time.sleep(delay)
                continue
            raise SystemExit(f"ElevenLabs HTTP {exc.code} on {path}: {body[:500]}") from exc
        except TimeoutError as exc:
            last_error = exc
            if delay is not None:
                print(f"retry timeout in {delay}s ({path})", flush=True)
                time.sleep(delay)
                continue
            raise
    raise SystemExit(f"ElevenLabs failed after retries: {last_error}")


def list_voices(key: str) -> dict[str, dict]:
    payload = json.loads(api_request("/voices", key).decode("utf-8"))
    by_name: dict[str, dict] = {}
    for voice in payload.get("voices", []):
        name = (voice.get("name") or "").strip()
        if name:
            by_name[name] = voice
    return by_name


def match_voice(name: str, available: dict[str, dict]) -> tuple[str, dict] | None:
    wanted = name.strip()
    if wanted in available:
        return wanted, available[wanted]
    lower = wanted.lower()
    for full, voice in available.items():
        stem = full
        for sep in (" - ", " – ", " — ", " − "):
            if sep in full:
                stem = full.split(sep, 1)[0].strip()
                break
        if full.lower() == lower or stem.lower() == lower:
            return full, voice
    return None


def resolve_voices(key: str, names: list[str]) -> list[tuple[str, str]]:
    available = list_voices(key)
    resolved: list[tuple[str, str]] = []
    missing: list[str] = []
    for name in names:
        matched = match_voice(name, available)
        if not matched:
            missing.append(name)
            continue
        full_name, voice = matched
        resolved.append((full_name, voice["voice_id"]))
    if missing:
        sample = ", ".join(sorted(available)[:40])
        raise SystemExit(
            f"Voice name(s) not in this account: {', '.join(missing)}. "
            f"Available (first 40): {sample}"
        )
    return resolved


def synthesize(key: str, voice_id: str, text: str) -> bytes:
    body = json.dumps(
        {
            "text": text,
            "model_id": MODEL_ID,
            "voice_settings": VOICE_SETTINGS,
        }
    ).encode("utf-8")
    path = f"/text-to-speech/{urllib.parse.quote(voice_id)}?output_format=mp3_44100_64"
    return api_request(path, key, data=body, accept="audio/mpeg")


def slug(name: str) -> str:
    stem = name
    for sep in (" - ", " – ", " — ", " − "):
        if sep in name:
            stem = name.split(sep, 1)[0]
            break
    return "".join(ch.lower() if ch.isalnum() else "-" for ch in stem).strip("-")


def write_mp3(path: Path, blob: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(blob)


def cmd_audition(key: str, names: list[str]) -> None:
    texts = prayer_texts()
    resolved = resolve_voices(key, names)
    AUDITION_DIR.mkdir(parents=True, exist_ok=True)
    lines = [
        "Purpose: Operator voice audition for Rosary TTS (Hail Mary + Apostles' Creed).",
        "",
        f"Model: `{MODEL_ID}`. Speed {VOICE_SETTINGS['speed']}. Stability {VOICE_SETTINGS['stability']}.",
        "Listen on the Mac after a GitHub pull, or play the mp3s in this folder.",
        "",
        "| File | Voice | Prayer |",
        "| --- | --- | --- |",
    ]
    for voice_name, voice_id in resolved:
        for prayer_id in AUDITION_PRAYER_IDS:
            text = texts[prayer_id]
            dest = AUDITION_DIR / f"{slug(voice_name)}-{prayer_id}.mp3"
            print(f"generating {dest.name} ({len(text)} chars)", flush=True)
            write_mp3(dest, synthesize(key, voice_id, text))
            lines.append(f"| `{dest.name}` | {voice_name} (`{voice_id}`) | {prayer_id} |")
    (AUDITION_DIR / "voices.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {AUDITION_DIR / 'voices.md'}")


def cmd_ids(key: str, pairs: list[str]) -> None:
    texts = prayer_texts()
    AUDITION_DIR.mkdir(parents=True, exist_ok=True)
    for pair in pairs:
        if ":" not in pair:
            raise SystemExit(f"expected slug:voice_id, got {pair!r}")
        slug_name, voice_id = pair.split(":", 1)
        slug_name = slug(slug_name)
        voice_id = voice_id.strip()
        for prayer_id in AUDITION_PRAYER_IDS:
            dest = AUDITION_DIR / f"{slug_name}-{prayer_id}.mp3"
            print(f"generating {dest.name} ({len(texts[prayer_id])} chars)", flush=True)
            write_mp3(dest, synthesize(key, voice_id, texts[prayer_id]))


def is_mp3(path: Path) -> bool:
    if not path.is_file() or path.stat().st_size < 1000:
        return False
    head = path.read_bytes()[:3]
    return head == b"ID3" or head[:2] in (b"\xff\xfb", b"\xff\xf3", b"\xff\xf2")


def clip_filename(slug_name: str, prayer_id: str) -> str:
    """Unique bundle names. Xcode synchronized groups flatten resources to the app root."""
    return f"{slug_name}__{prayer_id}.mp3"


def render_bank(key: str, slug_name: str, voice_id: str, display_name: str) -> None:
    texts = prayer_texts()
    missing_ids = [i for i in ROSARY_IDS if i not in texts]
    if missing_ids:
        raise SystemExit(f"Missing JSON text for: {', '.join(missing_ids)}")
    VOICEBANK_ROOT.mkdir(parents=True, exist_ok=True)
    done = 0
    skipped = 0
    for prayer_id in ROSARY_IDS:
        dest = VOICEBANK_ROOT / clip_filename(slug_name, prayer_id)
        if is_mp3(dest):
            skipped += 1
            continue
        print(f"generating {dest.name}", flush=True)
        write_mp3(dest, synthesize(key, voice_id, texts[prayer_id]))
        done += 1
    print(f"{slug_name}: wrote {done}, skipped {skipped}, total {len(ROSARY_IDS)}")


def cmd_bank(key: str, voice_name: str) -> None:
    resolved = resolve_voices(key, [voice_name])
    full_name, voice_id = resolved[0]
    render_bank(key, slug(full_name), voice_id, full_name)


def cmd_shortlist(key: str) -> None:
    for slug_name, voice_id, display_name in SHORTLIST:
        render_bank(key, slug_name, voice_id, display_name)
    catalog = [
        {"slug": slug_name, "displayName": display_name, "voiceId": voice_id}
        for slug_name, voice_id, display_name in SHORTLIST
    ]
    (VOICEBANK_ROOT / "catalog.json").write_text(json.dumps(catalog, indent=2) + "\n", encoding="utf-8")
    note = REPO / "llm" / "implementation" / "2026-09-16-elevenlabs-voicebank.md"
    lines = [
        "Purpose: Record the operator-approved ElevenLabs Rosary voices bundled in VoiceBank.",
        "",
        "# Rosary VoiceBank shortlist (2026-09-16)",
        "",
        f"- Model: `{MODEL_ID}`",
        f"- Output: `prayers/prayers Watch App/VoiceBank/{{slug}}/*.mp3` ({len(ROSARY_IDS)} clips each)",
        "",
        "| Slug | Display name |",
        "| --- | --- |",
    ]
    for slug_name, _voice_id, display_name in SHORTLIST:
        lines.append(f"| `{slug_name}` | {display_name} |")
    note.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {note}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)
    audition = sub.add_parser("audition", help="Hail Mary + Creed for a handful of voices")
    audition.add_argument("--voices", nargs="+", default=list(AUDITION_VOICE_NAMES))
    ids = sub.add_parser("ids", help="Hail Mary + Creed for explicit slug:voice_id pairs")
    ids.add_argument("pairs", nargs="+", help="slug:voice_id")
    bank = sub.add_parser("bank", help="Render the full 51-clip Rosary bank")
    bank.add_argument("--voice", required=True, help="Premade voice name (e.g. Will)")
    sub.add_parser("shortlist", help="Render VoiceBanks for the operator-approved 8 voices")
    args = parser.parse_args()
    key = load_api_key()
    if args.cmd == "audition":
        cmd_audition(key, args.voices)
    elif args.cmd == "ids":
        cmd_ids(key, args.pairs)
    elif args.cmd == "bank":
        cmd_bank(key, args.voice)
    elif args.cmd == "shortlist":
        cmd_shortlist(key)


if __name__ == "__main__":
    main()
