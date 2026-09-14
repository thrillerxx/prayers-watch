Purpose: Install Divinity on a real iPhone + Apple Watch after a passcode erase.

# Real-device install

Omarchy cannot install this app. The magnetic Watch cable on Linux is charge-only. Tailscale on an iPhone does not replace Xcode.

## What you need

1. **Apple Watch** set up again after erase (Setup screen, not the old passcode).
2. **The iPhone the Watch is actually paired to** (daily driver is fine). Watch ↔ iPhone is 1:1 — you cannot pair one Watch to two phones at once.
3. **MacBook Pro** with Xcode, this repo cloned, and **that paired iPhone** plugged into **the Mac** (USB the first time).
4. **Apple Developer team** (paid Program is the reliable path for Watch + companion). Free personal teams expire and often fail Watch embedding.
5. `prayers/Signing.local.xcconfig` on the Mac (copy from `Signing.local.xcconfig.example`; gitignored).

### Two iPhones

- **Watch app + Xcode:** only the paired iPhone. Plug that phone into the Mac.
- **iOS companion:** install `com.divinityapp.prayers` on both phones if you want. The extra phone is useful for phone UI, Tailscale, and PWA checks; it will not run or update the Watch app.
- Switching the Watch to the other phone means Unpair (erases Watch) and set up again; restore from backup if you want data back.

## 1. Pair the wiped Watch

On the iPhone: Watch app → start pairing → hold Watch near phone → sign in with the Apple Account that owned Activation Lock.

Stay on the charger until setup finishes. Skip restore if you want a clean QA device; restore only if you need old Watch data.

## 2. Turn on Developer Mode

- iPhone: **Settings → Privacy & Security → Developer Mode** → on → restart if asked.
- Watch: **Settings → Privacy & Security → Developer Mode** (appears after the first Xcode attempt if missing) → on → restart.

## 3. Trust the Mac

1. Plug the iPhone into the MacBook Pro (not Omarchy).
2. Unlock the phone, tap **Trust**.
3. Xcode → **Window → Devices and Simulators** — iPhone listed, Watch paired underneath.

If the Watch is missing, keep both devices unlocked and on the same Wi‑Fi, Watch on charger, then unplug/replug the phone.

## 4. Sign the project (Mac)

```bash
cd ~/dev/prayers-watch/prayers
cp Signing.local.xcconfig.example Signing.local.xcconfig
# put the 10-character Team ID in DEVELOPMENT_TEAM
```

Xcode → open `prayers/prayers.xcodeproj` → each app target → **Signing & Capabilities** → your team.

Bundle IDs (already in the project):

- iOS companion: `com.divinityapp.prayers`
- Watch: `com.divinityapp.prayers.watchkitapp`
- Complications: `com.divinityapp.prayers.watchkitapp.complications`

First install may need **Settings → General → VPN & Device Management** on the iPhone to trust the developer cert. The Watch follows the phone.

## 5. Install

Scheme **prayers Watch App**. Destination: the paired Watch (or iPhone + Watch). Run (⌘R).

The companion iOS app installs on the phone; the Watch app lands on the wrist. First launch can take a minute.

Do this in Xcode on the MacBook Pro after `git pull`. Do not SSH from Omarchy to that laptop. Handoff: [github-airgap.md](github-airgap.md).

## 6. Confirm launch

Watch: Divinity / Prayers home (Rosary, Prayer Library, Mass Responses, Settings).  
Optional: add the **Divinity** complication to a face.

Then run [real-device-qa.md](real-device-qa.md).

## Common failures

| Symptom | Likely cause |
| --- | --- |
| Watch never appears in Xcode | Not paired, Developer Mode off, phone on Omarchy USB instead of Mac |
| Could not launch / pairing proxy | Watch locked, charging poorly, or iPhone too far from Mac |
| Signing / provisioning | Missing Team ID, bundle ID not in the team, free team limits |
| Activation Lock at Watch setup | Wrong Apple Account |
| TTS silent | Simulator-only issue; on device, check Watch silent mode and Settings speech |
