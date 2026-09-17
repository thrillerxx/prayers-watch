Purpose: Record the operator-approved ElevenLabs Rosary voices bundled in VoiceBank.

# Rosary VoiceBank shortlist (2026-09-16)

Operator picked eight voices after audition. Each bank has 51 clips. Watch Settings → Speech → Voice selects **Apple Voice** (built-in `AVSpeechSynthesizer`, the old English (US) label) or an ElevenLabs bank. `SpeechManager` plays the mp3 for banks; Apple Voice always uses system TTS. Missing clips also fall back to system TTS.

- Model: `eleven_multilingual_v2` (64 kbps mp3)
- Output: `prayers/prayers Watch App/VoiceBank/{slug}__{prayerId}.mp3` (flat unique names; Xcode synchronized groups copy resources to the app root and collide on `apostles_creed.mp3` if folders are used)
- Default: Will
- Display name: Sofia (files stay `sofia-soft__…`)
- Clip speed follows Settings: Very Slow `0.65×`, Slow `0.82×`, Normal `1.00×`, Fast `1.20×`. Pause-between-parts still delays Auto-advance after each clip.
- Decade announce clips speak `1st Decade. …` through `5th Decade. …`. Scripture clips speak full book names, chapter, and verses (see `2026-09-16-spoken-decade-scripture.md`). Re-render those clips with `python3 scripts/generate_elevenlabs_voice.py refresh --suffix _announce _meditation`.
- Liked now-playing layout is unchanged (no `VideoPlayer`)

| Slug | Display name |
| --- | --- |
| `machine` | Apple Voice (system TTS; no clips) |
| `will` | Will |
| `vestal` | Vestal |
| `sofia-soft` | Sofia |
| `setsuna` | Setsuna |
| `rowan` | Rowan |
| `maxwell` | Maxwell |
| `emma` | Emma |
| `deacon-hugh` | Deacon Hugh |
