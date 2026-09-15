Purpose: Record that the Watch Rosary session now follows the Complete Rosary Prayer Guide (one set of five mysteries per session).

# Rosary complete-guide sequence (2026-09-15)

The Watch Rosary is no longer a shortened decade (meditation → Our Father → Hail Marys). It follows the guide the operator supplied:

1. **Opening:** Sign of the Cross, Apostles' Creed, Our Father, three Hail Marys (Faith, Hope, Charity), Glory Be.
2. **Each of five decades:** Announce ("The First Joyful Mystery: The Annunciation"), Reflect (guide meditation + meditation points), Our Father, ten Hail Marys, Glory Be, optional Fatima.
3. **Closing:** Hail, Holy Queen (includes "Pray for us…"), Concluding Prayer, Sign of the Cross. St. Joseph remains a Settings extra, not in the guide.

Mystery titles and meditations in `rosary_prayers_en.json` match the guide (including "The Crucifixion and Death of Jesus", "The Descent of the Holy Spirit", "The Baptism of Jesus in the Jordan", etc.).

Picker order is Joyful, Luminous, Sorrowful, Glorious. Weekday defaults match the guide; **Sunday is Glorious except in Advent and Lent (Sorrowful)** via `RosaryLiturgicalCalendar`.

Announce ids (`mystery_*_*_announce`) are filtered out of Prayer Library. Fatima stays optional in Settings (default on).
