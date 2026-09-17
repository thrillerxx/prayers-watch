Purpose: Record the locked spoken decade announces and scripture citations (2026-09-16).

# Spoken decade + scripture (2026-09-16)

Speech comes from `rosary_prayers_en.json`. Now-playing still has no on-screen scripture. Verse **bodies** stay the existing RSV-style wording (not Douay-Rheims). Citations are spoken in full.

- Announces: `1st Decade. The Annunciation.` through `5th Decade. …` on all 20 decades.
- Citations: full book name, chapter, verses through. `Acts of the Apostles`. `Catechism of the Catholic Church, paragraph 974`.
- Luminous 1 speaks Matthew 3:13–17 (full Baptism), not 16–17 only.
- Luminous 3 is Mark 1:14–15, not John.
- Luminous 4 citation is Luke 9:28–36; the spoken excerpt stays short (mountain + voice).
- Sorrowful 1 includes the angel (verses 41 through 44).
- Sorrowful 3 includes the robe and the thorns (verses 28 through 30).

Refresh ElevenLabs announce/meditation clips after JSON changes:

`python3 scripts/generate_elevenlabs_voice.py refresh --suffix _announce _meditation`
