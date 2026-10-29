# GBU Review Report: Backyard Barista on Cloud Run (Universal Studios Wizarding World Edition)

- **Date:** 2026-10-28
- **Target:** [`flutter_client`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client)
- **Auditor Lens:** Independent read-only `gbu-lens-critic` (`fc5251d1-e762-4b11-91b5-7b7291b284e5`)
- **Verification Gate:** `dart format --line-length 120 lib test` (0 diffs), `flutter analyze` (0 errors), `flutter test` (9/9 passed)

---

## GOOD (8 Items)

1. **Injected Clock Contract in [`CafeJudgeService`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/services/cafe_judge_service.dart#L17-L29) and [`cafe_counter_test.dart`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/test/cafe_counter_test.dart#L12)**
   - `CafeJudgeService` takes `required DateTime Function() clock` instead of calling `DateTime.now()` inside evaluation logic, eliminating midnight-boundary test flakiness.

2. **3-Layer City Edition Priority Hierarchy in [`CityEditionController`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/config/city_edition_controller.dart#L152-L164)**
   - Deterministic priority resolution (`_manualOverrideCityId ?? _remoteConfigCityId ?? _fallbackCityId`) with explicit `CityConfigSourceLayer` reporting and unit test coverage.

3. **Zero-Spoiler Twin Jars (`sugar_jar` vs `salt_shaker`) + Post-Selection Stealth Wink in [`IngredientsCatalog`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/data/ingredients_catalog.dart#L148-L170) and [`_InteractiveWoodenTray`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L2015-L2028)**
   - Counter medallions show no spoiler badges; the `stealth_prank_wink_badge` (`🤫 😉`) only appears on the wooden tray header after a prank item is plated.

4. **Header-Only Gemini API Key Transmission (`x-goog-api-key`) in [`CafeJudgeService`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/services/cafe_judge_service.dart#L160-L162)**
   - Passes `geminiApiKey` in the `x-goog-api-key` HTTP header rather than URL query parameters, keeping keys out of proxy and server access logs.

5. **Custom Vector Flag Badges Preventing Missing Emoji Glyphs on Desktop in [`CityFlagBadge`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/city_settings_drawer.dart#L11-L77)**
   - `CityFlagBadge` and `_CityFlagPainter` render vector Turkish and German flags so desktop `GoogleSans` never falls back to raw `"TR"` or `"DE"` regional-indicator letters.

6. **Round-2 Custom Item Purge & Ticket Soft-Lock Prevention in [`_CafeCounterScreenState._handleRoundTwoToggle`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L150-L160) and [`CustomerOrderTicket.effectiveRequestedIngredientIds`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/models/customer_order_ticket.dart#L59-L68)**
   - Turning off `round_two_custom_items_switch` purges `custom_katmer_roll` and `custom_isot_pepper` from `_selectedTray` and maps ticket requirements back to `baklava` so orders never soft-lock.

7. **3-Station Tray Completeness Gate Before Verdict in [`CafeJudgeService.evaluateOrder`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/services/cafe_judge_service.dart#L47-L79)**
   - Enforces that Drink, Pastry, and Sweet Sugar are all plated before awarding a 5-star review, returning a localized `3/5 · incomplete_tray` verdict when stations are missing.

8. **Automated Widget Test Guard for Infinite Animations in [`isRunningInAutomatedWidgetTest`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_character_animations.dart#L71-L74) and [`CafeCounterScreen`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L71)**
   - Pauses the `SubwayBaristaFlameGame` loop and switches Lottie/breathing controllers to single-shot forwards during `flutter test` so `pumpAndSettle()` never hangs.

---

## UGLY (20 Items - All Fixed)

1. **UGLY 1 (FIXED): Flame Lane Tap / Drag Could Desync `_HarryPotterLaneRunnerAvatar` Alignment**
   - Location: [`cafe_counter_screen.dart:90-100`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L90-L100), [`subway_barista_flame_game.dart:195-210`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/subway_barista_flame_game.dart#L195-L210)
   - Problem: Early return when `itemsInLane.isEmpty` or horizontal drag at lane bounds skipped `setState()`, leaving `_HarryPotterLaneRunnerAvatar` misaligned with `flameGame.activeRunnerLane`.
   - Fix: Added `setState(() {})` before early return in `_handleFlameLaneTapped` and guarded `onDragUpdate` with `_activeRunnerLane > 0` / `_activeRunnerLane < 2`.

2. **UGLY 2 (FIXED): Missing `errorBuilder` on Panoramic Universal Studios Hogsmeade Stage Backdrop**
   - Location: [`cafe_counter_screen.dart:622-637`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L622-L637)
   - Problem: `Image.asset(CafeCharacterAssets.hogsmeadeUniversalStage)` had no `errorBuilder` fallback.
   - Fix: Added an `errorBuilder` rendering a dark Hogsmeade twilight gradient (`0xFF0F172A` to `0xFF1E150F`).

3. **UGLY 3 (FIXED): Missing `errorBuilder` on `_HarryPotterLaneRunnerAvatar`**
   - Location: [`cafe_counter_screen.dart:806-819`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L806-L819)
   - Problem: `Image.asset` inside `_HarryPotterLaneRunnerAvatar` lacked an `errorBuilder`.
   - Fix: Added an `errorBuilder` returning a `ColoredBox(color: Color(0xFF2B1B10))` with `Icons.auto_fix_high_rounded`.

4. **UGLY 4 (FIXED): Identity Collision Between `_HarryPotterLaneRunnerAvatar` (`⚡ Harry`) and Customer Tickets**
   - Location: [`customer_order_ticket.dart:8-17`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/models/customer_order_ticket.dart#L8-L17), [`cafe_counter_screen.dart:808`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L808)
   - Problem: `CafeCharacterAssets.customerLukas` was shared by both the `⚡ Harry` lane runner and customer tickets (`Lukas`, `Burak`, `Kaan`), while `assets/base/customers/*.png` still held pre-Universal-Studios art.
   - Fix: Introduced `CafeCharacterAssets.harryPotterStageRunner` exclusively for `_HarryPotterLaneRunnerAvatar`, routed `customerLukas` to `customer_mustafa.png`, and updated `assets/base/customers/customer_happy.png`, `customer_shocked.png`, and `customer_salty_disgusted.png` with Universal Studios character portraits.

5. **UGLY 5 (FIXED): `CitySettingsSheet` Rendered Light Cream (`0xFFFFFBF7`) Under `Brightness.dark`, Causing Unreadable Text**
   - Location: [`city_settings_drawer.dart:89-243`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/city_settings_drawer.dart#L89-L243)
   - Problem: Light cream cards (`0xFFF5EFEA`) combined with `Brightness.dark` default light text (`0xFFF3E5C8`) made city titles and subtitles nearly invisible.
   - Fix: Restyled `CitySettingsSheet` to the Universal Studios Hogsmeade dark tavern & antique gold palette (`0xFF1E150F` sheet, `0xFF382315` / `0xFF281B12` cards, `0xFFD4AF37` gold borders, `0xFFF3E5C8` parchment text).

6. **UGLY 6 (FIXED): Raw `edition.flagEmoji` in `CitySettingsSheet` and `CafeJudgeService` Headlines**
   - Location: [`city_settings_drawer.dart:11-77, 155, 196`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/city_settings_drawer.dart#L11-L77), [`cafe_judge_service.dart:69-71, 258, 271, 283`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/services/cafe_judge_service.dart#L69-L71)
   - Problem: `Text(edition.flagEmoji)` in `CitySettingsSheet` and `${cityEdition.flagEmoji}` in fallback headlines rendered raw `"TR"` / `"DE"` letters on desktop `GoogleSans`.
   - Fix: Promoted `CityFlagBadge` to a public widget in `city_settings_drawer.dart`, used it in `CitySettingsSheet` (`ListTile.leading` and `ActionChip.avatar`) and `cafe_counter_screen.dart`, and removed raw `flagEmoji` prefixes from `CafeJudgeService` headlines.

7. **UGLY 7 (FIXED): Unused Callback `onSwipeServeRequested` in `SubwayBaristaFlameGame`**
   - Location: [`subway_barista_flame_game.dart:38, 195-215`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/subway_barista_flame_game.dart#L195-L215)
   - Problem: `onSwipeServeRequested` was passed by `CafeCounterScreen` but never called inside `SubwayBaristaFlameGame`.
   - Fix: Added `_verticalDragAccumulator` in `onDragUpdate` so swiping upward (`<= -_swipeThresholdPixels`) when items are plated triggers `onSwipeServeRequested()`.

8. **UGLY 8 (FIXED): Double-Audio Playback on Web (`_playBackyardBaristaWebAudio` + `HTMLAudioElement`)**
   - Location: [`sound_player_web.dart:12-30`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/services/sound_player_web.dart#L12-L30)
   - Problem: `playPlatformCafeCue` called `_playBackyardBaristaWebAudio` and then unconditionally fell through to `HTMLAudioElement().play()`, playing both synth and `.wav` simultaneously.
   - Fix: Checked `final didPlaySynth = _playBackyardBaristaWebAudio(cueName.toJS)?.toDart ?? false; if (didPlaySynth) { return; }`.

9. **UGLY 9 (FIXED): Double Tea-Sip Trigger in `_AnimatedCafeCharacterAvatarState._handleTap`**
   - Location: [`cafe_character_animations.dart:177-184`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_character_animations.dart#L177-L184)
   - Problem: `_handleTap()` called `_triggerFiveSecondTeaSip()` locally and then invoked `widget.onTapCharacter?.call()`, which triggered `didUpdateWidget -> _triggerFiveSecondTeaSip()` a second time.
   - Fix: Delegated to `tapCallback()` when `widget.onTapCharacter != null` and only called `_triggerFiveSecondTeaSip()` directly when `widget.onTapCharacter == null`.

10. **UGLY 10 (FIXED): Coupled Customer and Crew Tea-Sip State (`_triggerFiveSecondTeaSip` Activated All 3 Avatars at Once)**
    - Location: [`cafe_counter_screen.dart:207-241, 412-435`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L207-L241)
    - Problem: Tapping `customer_sip_tea_5s_button` set both `_isCustomerSippingTea = true` and `_isCrewSippingTea = true`, spawning 3 overlapping countdown badges and firing completion 3 times.
    - Fix: Split into `_triggerCustomerTeaSip` / `_handleCustomerTeaSipCompleted` and `_triggerCrewTeaSip` / `_handleCrewTeaSipCompleted`.

11. **UGLY 11 (FIXED): Legacy Mud-Brown / Terracotta Container & Medallion Colors in `_SubwayFlameRunwayStage`**
    - Location: [`cafe_counter_screen.dart:599-610, 718-728, 916-921, 976-978`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L599-L610)
    - Problem: `_SubwayFlameRunwayStage`, `_FlameLanePickupColumn`, and `_InLanePickupMedallion` still used old mud-brown (`0xFF9E6B47`, `0xFF3B281E`) and light cream (`0xFFFAF2E8`) colors.
    - Fix: Restyled to Universal Studios Hogsmeade dark oak (`0xFF1B1410`, `0xFF241912`), antique gold borders (`0xFFC59B27`), aged parchment medallions (`0xFFF2E5C9`), and Hogwarts emerald selected state (`0xFF234231`).

12. **UGLY 12 (FIXED): Conflicting Lane Colors & Duplicate Headers Between Top Runway Pills, Flame Canvas, and Bottom Dock**
    - Location: [`cafe_counter_screen.dart:566-597, 654-692, 853-858`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L566-L597), [`subway_barista_flame_game.dart:368-373`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/subway_barista_flame_game.dart#L368-L373)
    - Problem: Lane 1 and Lane 2 swapped Gold and Green between the Flame canvas and the Flutter overlay pills, and repeated `HAT 1 · KAHVE ☕` verbatim at both top and bottom.
    - Fix: Unified Lane 0 (`0xFFE08E45` Gryffindor Copper), Lane 1 (`0xFFD4AF37` Hufflepuff Gold), and Lane 2 (`0xFF4E9F6E` Slytherin Emerald) across all widgets and gave the bottom dock distinct action headers (`1. İSTASYON · KAHVE SEÇ ☕` / `STATION 1 · PICK DRINK ☕`).

13. **UGLY 13 (FIXED): `_CustomerOrderStage` and `_CustomerReviewCard` Treated `incomplete_tray` (`3/5`) as `sweetCelebration`**
    - Location: [`cafe_counter_screen.dart:1594-1635, 2340-2348`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L1594-L1635)
    - Problem: When `currentReview.isIncompleteTray` was true, `isPrankCaught` was false, causing the customer avatar and review card to celebrate with green borders and `sweetCelebration`.
    - Fix: Handled `currentReview.isIncompleteTray` explicitly with `CafeCharacterMood.talkingOrder`, `currentReview.customerFace.assetPath`, and amber border (`0xFFC59B27`).

14. **UGLY 14 (FIXED): `CafeCrewCharacterStage` Celebrated `"🎉 5-Star Sweet Perfection!"` on `incomplete_tray` (`3/5`)**
    - Location: [`cafe_character_animations.dart:736-845`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_character_animations.dart#L736-L845)
    - Problem: `_baristaMood`, `_pastryChefMood`, `_baristaSpeechLine`, and `_pastryChefSpeechLine` ignored `isIncompleteTray`, and `_pastryChefMood` used `sweetCelebration` even on a prank catch.
    - Fix: Branched on `currentReview.isIncompleteTray` in moods (`idleBreathing`) and speech lines (`🧩 Tepside eksik istasyon var! ... (+15p)`), and returned `CafeCharacterMood.stealthPrankWink` for P2 on prank catch.

15. **UGLY 15 (FIXED): `SubwayBaristaFlameGame._spawnVerdictExplosion` Used Green Victory Burst on `incomplete_tray`**
    - Location: [`subway_barista_flame_game.dart:119-124, 152-174`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/subway_barista_flame_game.dart#L152-L174)
    - Problem: Incomplete trays triggered a green celebration ring across all 3 lanes.
    - Fix: Added `required bool isIncomplete` to `_spawnVerdictExplosion`, using `Color(0xFFD4AF37)` (amber) when `isIncomplete` is true.

16. **UGLY 16 (FIXED): Order Scroll Ticket Checkboxes Remained Unchecked When Selecting an Alternative Item in the Same Station**
    - Location: [`cafe_counter_screen.dart:1805-1848`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L1805-L1848)
    - Problem: Plating `espresso` instead of `menengic_coffee` satisfied the Drink station in `CafeJudgeService` (5 stars) but left the Drink pill unchecked on the order scroll.
    - Fix: Checked both exact ID match and non-prank station category match (`isStationSatisfied`) and displayed the plated item title on the scroll pill.

17. **UGLY 17 (FIXED): `AnimatedCafeCharacterAvatar` Ignored the Passed `badgeEmoji` Value**
    - Location: [`cafe_character_animations.dart:186-212, 396-425`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_character_animations.dart#L186-L212)
    - Problem: `badgeEmoji` was only null-checked (`if (badgeEmoji != null)`) and never read, rendering a generic `Icons.auto_awesome_rounded` on every character.
    - Fix: Added `_resolveBadgeIcon(badgeEmoji, activeMood)` mapping persona tokens (`☕`, `🥐`, `🧂`, `🎤`, `💻`, `👓`) to distinct Material icons and wrapped the badge in `Tooltip(message: badgeEmoji)`.

18. **UGLY 18 (FIXED): Missing `Semantics` and Click `MouseRegion` on `AnimatedCafeCharacterAvatar`**
    - Location: [`cafe_character_animations.dart:235-244`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_character_animations.dart#L235-L244)
    - Problem: Bare `GestureDetector` gave no pointer cursor on desktop/web and no button semantics for accessibility.
    - Fix: Wrapped in `Semantics(button: true, label: ...)` and `MouseRegion(cursor: SystemMouseCursors.click, ...)`.

19. **UGLY 19 (FIXED): Legacy Mud-Brown (`0xFF6D4C41`) Fallback Icons in `_IngredientArtwork` and `AnimatedCafeCharacterAvatar`**
    - Location: [`cafe_counter_screen.dart:1898, 1913`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L1898), [`cafe_character_animations.dart:457`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_character_animations.dart#L457)
    - Problem: Used legacy Material brown (`0xFF6D4C41`).
    - Fix: Updated fallback icon color to Hogsmeade antique gold (`0xFFC59B27`).

20. **UGLY 20 (FIXED): Unused `_RollingTrackToken.accentColor` Field Initialized with Stale Colors**
    - Location: [`subway_barista_flame_game.dart:61-68, 616-623`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/subway_barista_flame_game.dart#L616-L623)
    - Problem: `_RollingTrackToken` stored an unused `accentColor` field initialized with legacy colors.
    - Fix: Removed `accentColor` from `_RollingTrackToken`.

---

## BAD (10 Items - All Fixed)

1. **BAD 1 (FIXED): Magic Numbers in `SubwayBaristaFlameGame` Physics & Rendering Loop**
   - Location: [`subway_barista_flame_game.dart:10-21`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/subway_barista_flame_game.dart#L10-L21)
   - Fix: Extracted `_laneDashJumpVelocity`, `_verdictJumpVelocity`, `_swipeThresholdPixels`, `_maxFrameDeltaSeconds`, `_runnerGravity`, `_horizonHeightRatio`, `_trackBottomHeightRatio`, `_floatingCandleCount`, `_topTrackWidthRatio`, `_bottomTrackWidthRatio`, `_flagstonePlankCount`, and `_runnerPerspectiveDepth`.

2. **BAD 2 (FIXED): Magic Numbers in `_CafeCounterScreenState` and `_SubwayFlameRunwayStage`**
   - Location: [`cafe_counter_screen.dart:23-28, 134, 562, 615, 777`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L23-L28)
   - Fix: Extracted `_wideArenaBreakpoint`, `_wideRunwayStageHeight`, `_compactRunwayStageHeight`, `_wideRunnerAvatarSize`, `_compactRunnerAvatarSize`, and `_pointsPerCrewLevel`.

3. **BAD 3 (FIXED): Single-Letter Loop Variables `x` and `i` in Custom Painters**
   - Location: [`cafe_counter_screen.dart:1106`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L1106), [`subway_barista_flame_game.dart:288`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/subway_barista_flame_game.dart#L288)
   - Fix: Renamed `x` to `stripeOffsetX` and `i` to `candleIndex`.

4. **BAD 4 (FIXED): Nonexistent Ingredient IDs in `_coffeeGrindIds`**
   - Location: [`cafe_counter_screen.dart:136-139`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L136-L139)
   - Fix: Removed nonexistent IDs (`turkish_coffee`, `dibek_coffee`, `oat_flat_white`), keeping `'espresso'` and `'menengic_coffee'`.

5. **BAD 5 (FIXED): Unused `IngredientCategory.localizedTitle`, `CafeIngredient.localizedSubtitle`, and `CafeIngredient.isHotDrink`**
   - Location: [`cafe_character_animations.dart:736-737`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_character_animations.dart#L736-L737), [`cafe_counter_screen.dart:926, 982`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L926)
   - Fix: Wired `ingredient.isHotDrink` into `_hasHotDrinkOnTray`, `category.localizedTitle(languageCode)` into `_FlameLanePickupColumn` tooltips, and `ingredient.localizedSubtitle(languageCode)` into `_InLanePickupMedallion` tooltips.

6. **BAD 6 (FIXED): Missing Tooltip on `_InLanePickupMedallion` Exposing Twin Jar Lid Clues (`2-Hole Rose Lid` vs `3-Hole Silver Lid`)**
   - Location: [`cafe_counter_screen.dart:981-983`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L981-L983)
   - Fix: Wrapped `_InLanePickupMedallion` in `Tooltip(message: '$titleText · $subtitleText', ...)`.

7. **BAD 7 (FIXED): Stale Method Name, Comment, and `offsetHelper: Offset.new` Indirection in `_drawBaristaRunnerWithWoodenTray`**
   - Location: [`subway_barista_flame_game.dart:480-496, 560-601`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/subway_barista_flame_game.dart#L560-L601)
   - Fix: Renamed to `_drawRunnerMagicAuraRing`, removed `offsetHelper: Offset.new`, and updated comments.

8. **BAD 8 (FIXED): Forbidden Anti-Slop Word in `_ScallopedAwningEdge` Doc Comment**
   - Location: [`cafe_counter_screen.dart:1082`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/lib/ui/cafe_counter_screen.dart#L1082)
   - Fix: Replaced the forbidden word with `banner`.

9. **BAD 9 (FIXED): Unverified `CafeSoundController.playedCues` History Buffer**
   - Location: [`cafe_counter_test.dart:343-352`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/test/cafe_counter_test.dart#L343-L352)
   - Fix: Added assertions verifying `CafeSoundController.playedCues` recording and mute gating.

10. **BAD 10 (FIXED): Missing Widget Test Coverage for `incomplete_tray` Crew Speech, `chili_sauce` (`spicy_chaos`) Verdict, and Single-Target Customer Tea Sip**
    - Location: [`cafe_counter_test.dart:107-119, 222-223, 374-376`](file:///Users/esrakadah/Documents/esradev/devfest-2026-backyard-barista-cloudrun/flutter_client/test/cafe_counter_test.dart#L107-L119)
    - Fix: Added widget test assertions for `chili_sauce` (`1/5 · Acı Biber Şoku 🌶️`), `incomplete_tray` crew speech (`🧩 Tepside eksik istasyon var!`), and single-target customer tea-sip countdown badge (`findsOneWidget`).
