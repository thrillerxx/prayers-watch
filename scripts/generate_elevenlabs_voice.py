#!/usr/bin/env python3
"""Pre-render ElevenLabs TTS clips for Prayers Watch.

Reads ELEVENLABS_API_KEY from the local credentials file (never from git).
Watch playback uses the generated files; this script is Omarchy studio only.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
JSON_PATH = REPO / "prayers" / "prayers Watch App" / "rosary_prayers_en.json"
AUDITION_DIR = REPO / "artifacts" / "voice-audition"
VOICEBANK_DIR = REPO / "prayers" / "prayers Watch App" / "VoiceBank" / "en"
CREDENTIALS = Path("/home/car/.openclaw/credentials/prayers-watch-elevenlabs.env")
API = "https://api.elevenlabs.io/v1"
MODEL_ID = "eleven_multilingual_v2"

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
        raise SystemExit(f"ElevenLabs HTTP {exc.code} on {path}: {body[:500]}") from exc


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
    path = f"/text-to-speech/{urllib.parse.quote(voice_id)}?output_format=mp3_44100_128"
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


def cmd_bank(key: str, voice_name: str) -> None:
    texts = prayer_texts()
    resolved = resolve_voices(key, [voice_name])
    _, voice_id = resolved[0]
    VOICEBANK_DIR.mkdir(parents=True, exist_ok=True)
    missing_ids = [i for i in ROSARY_IDS if i not in texts]
    if missing_ids:
        raise SystemExit(f"Missing JSON text for: {', '.join(missing_ids)}")
    for prayer_id in ROSARY_IDS:
        dest = VOICEBANK_DIR / f"{prayer_id}.mp3"
        print(f"generating {dest.name}", flush=True)
        write_mp3(dest, synthesize(key, voice_id, texts[prayer_id]))
    note = REPO / "llm" / "implementation" / "2026-09-16-elevenlabs-voicebank.md"
    note.write_text(
        "Purpose: Record which ElevenLabs voice produced the bundled Rosary VoiceBank.\n\n"
        f"# Rosary VoiceBank ({voice_name})\n\n"
        f"- Voice: **{voice_name}** (`{voice_id}`)\n"
        f"- Model: `{MODEL_ID}`\n"
        f"- Files: `prayers/prayers Watch App/VoiceBank/en/*.mp3` ({len(ROSARY_IDS)} clips)\n",
        encoding="utf-8",
    )
    print(f"wrote {note}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)
    audition = sub.add_parser("audition", help="Hail Mary + Creed for a handful of voices")
    audition.add_argument("--voices", nargs="+", default=list(AUDITION_VOICE_NAMES))
    ids = sub.add_parser("ids", help="Hail Mary + Creed for explicit slug:voice_id pairs")
    ids.add_argument("pairs", nargs="+", help="slug:voice_id")
    bank = sub.add_parser("bank", help="Render the full 51-clip Rosary bank")
    bank.add_argument("--voice", required=True, help="Premade voice name (e.g. Rachel)")
    args = parser.parse_args()
    key = load_api_key()
    if args.cmd == "audition":
        cmd_audition(key, args.voices)
    elif args.cmd == "ids":
        cmd_ids(key, args.pairs)
    elif args.cmd == "bank":
        cmd_bank(key, args.voice)


if __name__ == "__main__":
    main()
