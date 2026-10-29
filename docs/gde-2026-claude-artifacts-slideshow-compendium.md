# GDE 2026 Claude Artifacts & Flutter Deck Compendium

**Last updated:** 28 October 2026  
**Author:** Esra Kadah (GDE Flutter & Dart · Tech Lead, Senior Flutter & AI Engineer)

This compendium maps all 12 GDE and conference-speaking Claude Artifacts across Esra's two Claude accounts (`04725fb2` Personal / Antigua and `1e6fba1e` Chargecloud / Team) into the 4 production `flutter_deck` repositories and the unified **GDE Artifacts & Autumn 2026 Tour** slide (`GdeArtifactsTourSlide`, route `'/gde-artifacts-tour'`).

---

## 1. Master Inventory of the 12 GDE Claude Artifacts

| # | Artifact Title | Artifact ID / URL | Account & Session | Core Content Merged into `flutter_deck` | Target Deck & Slide Routes |
|---|---|---|---|---|---|
| 1 | **GDE Speaking Autumn 2026** | `QakeBuJm6hJjMbVrUaaniW` / `bef8a0df-f71f-449b-83e5-90f28ccb2113` | `9309c236` (`gde-speaking.html`) | Oct-Dec 2026 8-stop tour timeline, CFP shelf, date clashes, Worktrips 4-week filing cutoffs | `backyard_barista_deck` (`/gde-artifacts-tour`, `/multi-city-remote-config`) |
| 2 | **Phase 3 Speaker Notes** | `8MdCFYFNpPzY7erVrXpF9L` | Updated `2026-10-20` | BEAT / SAY / HOLD / NEXT stage pacing protocol, 2-sentence GDE opener without reading screen | All 4 decks (`speakerNotes` contract) + `devfest_adana_2026_deck` (`/title`, `/agent-state-architecture`) |
| 3 | **I'm doing a live AI demo on stage. Here's everything that can break.** | `Hyi9MaNLhjZx2jdhQPWSyr` | `7f1ad569` (Updated `2026-10-01`) | 8s hard Gemini timeout, deterministic local replay cache, App Check 1-line mapping, pre-recorded MP4 fallback | `backyard_barista_deck` (`/real-numbers-latency`, `/room-quota-trap`, `/demo-hiccup`), `flutter_soundstage` (`/demo-fallback`), `devfest_adana_2026_deck` (`/agent-state-architecture`) |
| 4 | **SoundStage Capability Ledger** | `RLBYnNhzbaS2sZsPMvdcSN` | `0ed7006f` / `44e55629` (`soundstage-state-of-the-build.html`) | 6 platform-agnostic contracts (`AudioEngine`, `Exporter`, `PeaksSource`, `LyricsTranscriber`, `ClipAligner`, `AudioRecorder`), 632 Dart + 34 Swift tests | `flutter_soundstage/apps/deck` (`/architecture`, `/whats-next`) + `backyard_barista_deck` (`/gde-artifacts-tour`) |
| 5 | **SoundStage Status, 16 September** | `HYgfxuDijdS4oS9e24x6N5` | Updated `2026-09-16` | iOS container UUID path rebinding in `ProjectStore.load` across reinstalls (`make install-device`) | `flutter_soundstage/apps/deck` (`/tech-stack`, `/demo-fallback`) |
| 6 | **SoundStage Night Review** | `BkTGaVt3yc78QAxW16rof4` | Updated `2026-09-16` | `TimeUtils.formatDurationShort` vs `formatTimecodeShort` (44.5s export rounding), high-contrast `MUTE` / `SOLO` pills | `flutter_soundstage/apps/deck` (`/tech-stack`, `/whats-next`) |
| 7 | **Align, Audition, Firebase** | `FtpVX6LjfDP3Mgb8BAURiH` | Updated `2026-09-16` | Two-phase `AlignmentRun` (decode master once for 6 takes), `AlignmentPolicy` (`< 0.30` peak-to-sidelobe hold), `ResilientLyricsTranscriber` | `flutter_soundstage/apps/deck` (`/architecture`, `/demo-fallback`) |
| 8 | **DevFest Editor Build-Up Plan** | `MhsuPnjhtah446xfaiVRYZ` | Updated `2026-09-15` | Pub workspace topology (2 apps + 4 packages, zero native imports in `soundstage_editor` enforced by `no_native_imports_test.dart`) | `flutter_soundstage/apps/deck` (`/tech-stack`) |
| 9 | **modemoiselle x BlocSignal** | `LGjJZGsRq27dgqLfvBM74N` | Updated `2026-08-30` | Sealed union state discipline vs boolean flag bags, emit-after-await guard, defense-in-depth repository validation | `modemoiselle_deck` (`/the-lab`, `/architecture`, `/outfit-validation`, `/conclusion`) + `backyard_barista_deck` (`/gde-artifacts-tour`) |
| 10 | **Flutter & Friends Running Order** | `HRMU3Rz3ifncJtNG5GH3r4` | Updated `2026-08-28` | 27-minute stage budget for a 30-minute slot (leaving 10% air for the room), per-pattern rehearsal marks | `modemoiselle_deck` (`/the-lab`, `/architecture`, `/outfit-validation`, `/conclusion`) |
| 11 | **DevFest Berlin Site Ideas** | `MiaPUdjK57Eh2P1qKNoyWc` | `0b0984ec` (Updated `2026-09-29`) | Vibe Lounge 4x45-min interactive track format, `/agenda/` structure, GDPR map lock | `backyard_barista_deck` (`/workshop-contract`, `/gde-artifacts-tour`) |
| 12 | **Flutter Booth Sync: prep for Anel & Katrielle** | `BjpBEmjQnFp4W1vGUnLYzw` | `c381e305` (Updated `2026-09-29`) | Interactive booth/stage loop, QR onboarding, physical NFC / Pixel sunglasses prize flow | `backyard_barista_deck` (`/salt-sugar-mechanic`, `/winner-podium-closing`, `/gde-artifacts-tour`) |

---

## 2. What Landed Across the 4 `flutter_deck` Repos Today (28 Oct 2026)

### A. `backyard_barista_deck` (`devfest-2026-backyard-barista-cloudrun/slides`)
- **Slide 6 (`PureFlutterWidgetsSlide`, `/pure-flutter-widgets`):** Updated from "Pure Flutter Widgets (No Flame Engine)" to **Hybrid Flame Engine + Flutter HUD Architecture**, reflecting commit `e5d905e` (`BaristaFlameGame` 60fps 3-lane arcade stage, warm walnut cafe palette `#1E130C` / `#F4E4CE`, Hogsmeade backdrop) paired with reactive Flutter Overlay HUD cards (2x2 counter grid + 3-slot wooden tray).
- **Slide 11 (`SaltSugarMechanicSlide`, `/salt-sugar-mechanic`) & Slide 14 (`ArchitectureRecapSlide`, `/architecture-recap`):** Updated with today's merged **Web NFC Edition (`PR #2`, `3973acb`)**: `WebNfcService` via `dart:js_interop` and Chrome Android `NDEFReader` (inspired by Lukas Klingsbo's `badge_hack`) so tapping a physical NFC sticker on stage drops `salt_shaker` onto the tray, with a 1-tap `simulateTap()` fallback on desktop/iOS.
- **Slide 15 (`GdeArtifactsTourSlide`, `/gde-artifacts-tour`):** New unified slide merging all 12 GDE Claude Artifacts and the 8-stop Autumn 2026 Tour (`Stockholm 22 Oct`, `Gaziantep 8 Nov`, `Berlin 14 Nov`, `Adana 21 Nov`, `Hatay 28 Nov`, `Atyrau 29 Nov`, `Karlsruhe 5 Dec`, `Istanbul 6 Dec`) into the slideshow.

### B. `modemoiselle_deck` (`/Users/esrakadah/Documents/esradev/modemoiselle_deck`)
- **Slides `/the-lab`, `/architecture`, `/outfit-validation`, `/conclusion`:** Updated with today's merged **`modemoiselle#52` Looks Feature L1 Port** (66 files, 34 new widget/unit tests bringing the suite to **672** automated tests, `LooksCubit`, `LookComposerCubit`, multi-garment outfit canvas slots, and `TryOnView` integration), plus the `modemoiselle x BlocSignal` (`LGjJZGsRq27dgqLfvBM74N`) and `Flutter & Friends Running Order` (`HRMU3Rz3ifncJtNG5GH3r4`) artifacts.

### C. `devfest_adana_2026_deck` (`/Users/esrakadah/Documents/esradev/devfest_adana_2026_deck`)
- **Slides `/title`, `/agent-anatomy`, `/agent-state-architecture`, `/key-takeaways`:** Updated to the locked DevFest Adana 2026 topic (**"Real AI Features in Production: Flutter, Gemini and Firebase AI Logic"**, `firebase_ai` client lane + `Genkit Dart` server lane on Cloud Run) and today's published `dev.to/gde` articles on **Genkit Dart Human-in-the-Loop & `interruptRestart` namespaced MCP tools (`PR #658` / `issue #657`)**, plus `Phase 3 Speaker Notes` (`8MdCFYFNpPzY7erVrXpF9L`) and `Live AI Demo Risks` (`Hyi9MaNLhjZx2jdhQPWSyr`).

### D. `soundstage_deck` (`flutter_soundstage/apps/deck`)
- **Slides `/architecture`, `/tech-stack`, `/demo-fallback`, `/whats-next`:** Enriched with the 5 SoundStage Claude Artifacts (`RLBYnNhzbaS2sZsPMvdcSN`, `HYgfxuDijdS4oS9e24x6N5`, `BkTGaVt3yc78QAxW16rof4`, `FtpVX6LjfDP3Mgb8BAURiH`, `MhsuPnjhtah446xfaiVRYZ`), `Live AI Demo Risks` (`Hyi9MaNLhjZx2jdhQPWSyr`), and the G3 iPhone 17 Pro 6-take stage checklist (`make build-device` + `make install-device` over LAN before the Fri 6 Nov freeze).
