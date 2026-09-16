Purpose: Record the operator-approved ElevenLabs Rosary voices bundled in VoiceBank.

# Rosary VoiceBank shortlist (2026-09-16)

Operator picked eight voices after audition. Each bank has 51 clips. Watch Settings → Speech → Voice selects the bank. `SpeechManager` plays the mp3; system TTS is fallback if a clip is missing.

- Model: `eleven_multilingual_v2` (64 kbps mp3)
- Output: `prayers/prayers Watch App/VoiceBank/{slug}__{prayerId}.mp3` (flat unique names; Xcode synchronized groups copy resources to the app root and collide on `apostles_creed.mp3` if folders are used)
- Default: Will
- Display name: Sofia (files stay `sofia-soft__…`)
- Clip speed follows Settings: Very Slow `0.65×`, Slow `0.82×`, Normal `1.00×`, Fast `1.20×`. Pause-between-parts still delays Auto-advance after each clip.
- Liked now-playing layout is unchanged (no `VideoPlayer`)

| Slug | Display name |
| --- | --- |
| `will` | Will |
| `vestal` | Vestal |
| `sofia-soft` | Sofia |
| `setsuna` | Setsuna |
| `rowan` | Rowan |
| `maxwell` | Maxwell |
| `emma` | Emma |
| `deacon-hugh` | Deacon Hugh |
