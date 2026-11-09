# Section 4.6 Rehearsal & 3G Chaos Verification Report (`rehearsal_3g_check.dart`)

- **Execution Timestamp:** `2026-10-28T12:05:13+01:00` (`Europe/Berlin`)
- **Harness Command:** `cd flutter_client && dart run tool/rehearsal_3g_check.dart`
- **Target Cloud Run Service:** `https://backyard-barista-389486729482.europe-west3.run.app` (`devfest-backyard-barista-2026`, `europe-west3`, revision `backyard-barista-00008-9v6`; mirror `backyard-barista-00003-9mx` on `europe-west1`)
- **Public GitHub Repository:** `https://github.com/esrakadah/devfest-2026-backyard-barista-cloudrun` (`visibility: PUBLIC`)
- **Simulated Network Profile:** `Slow 3G` (`750 Kbps Down / 250 Kbps Up / 150ms RTT`)

---

## 1. Rehearsal Verification Matrix (`5/5 PASS`)

| Test ID | Rehearsal Check (`workshop-options.md` Section 4.6) | Measured Evidence | Status |
|---|---|---|---|
| **Test 1** | Slow 3G Load Budget (`< 45s`) | Lane A HTML (`49.5 KB`): **`1.01s`** on Slow 3G; Counter + 8 base PNGs (`3,303.4 KB`): **`36.67s`** (budget `< 45s`) | **PASS** |
| **Test 2** | Live Cloud Run & Public GitHub Assets | Cloud Run `https://backyard-barista-389486729482.europe-west3.run.app` `HTTP 200`; Public GitHub Raw PNGs: **`20/20` `HTTP 200`** | **PASS** |
| **Test 3** | Model Access & JSON Schema Guardrail | Default model `gemini-3.5-flash-lite` verified; `responseMimeType: application/json` enforced; zero `gemini-2.5-flash` calls in code or prompts | **PASS** |
| **Test 4** | Offline Wi-Fi Disconnect & HTTP `429` Fallback | `OFFLINE_MODE` compile flag + HTTP `429` / `SocketException` catch-all verified; `mock_responses.json` covers all 4 cities with `0` unhandled exceptions | **PASS** |
| **Test 5** | 4-City Remote Config x Salt/Isot Prank Matrix | Verified **`12/12`** city x verdict combinations (`berlin`, `gaziantep`, `adana`, `istanbul` x Sweet 5-Star, Salt 1-Star, Isot/Chili 1-Star) | **PASS** |

---

## 2. Automated Widget & Unit Test Coverage (`test/cafe_counter_test.dart`)

All 8 automated tests in [`flutter_client/test/cafe_counter_test.dart`](../flutter_client/test/cafe_counter_test.dart) pass (`8/8`):

1. `3-Layer CityEditionController prioritizes Manual UI Override > Remote Config > Local Fallback`
2. `Serving sweet order gives 5 stars; sneaking stealth Salt shows wink badge & triggers 1-star sabotage`
3. `Switching City Edition in Settings sheet updates flag and customer queue`
4. `Renders and plays cleanly on narrow mobile phone screen (360x780) without overflow`
5. `5-second Turkish Tea Sipping animation plays and auto-completes after 5s`
6. `HTTP 429 room-quota chaos falls back cleanly and Settings sheet RC chips update Priority 2`
7. `Web Audio API Barista Soundboard buttons and Level Up progression trigger coffee grinder, steam, bell, and level-up fanfare`
8. `Desktop 2-column layout enforces 3-station completeness, 1-item-per-category slot replacement, and Round-2 ticket fallback`
