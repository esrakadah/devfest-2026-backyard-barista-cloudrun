# Backyard Barista on Cloud Run: Tatlı mı Tuzlu mu? ☕🥐🧂☁️

**DevFest 2026 Hands-On Workshop & Vibe Lounge Starter Repository**
- **Author:** Esra Kadah (Flutter & Dart GDE, Senior Flutter & AI Engineer)
- **City Editions Included:**
  - `berlin` (🇩🇪 DevFest Berlin, 14 Nov 2026)
  - `gaziantep` (🇹🇷 DevFest Gaziantep, 15 Nov 2026)
  - `adana` (🇹🇷 DevFest Adana, 11 Dec 2026)
  - `istanbul` (🇹🇷 DevFest Istanbul, 19 Dec 2026)

---

## What You Build Today

A zero-typing, tap-to-serve 2-player AI Cafe Game where players assemble **Drinks** (`Espresso`, `Milk`, `Menengiç Kahvesi`) and **Simple Foods** (`Croissant`, `San Sebastian Cheesecake`, `Baklava`) by tapping ingredients on the counter.

Right next to the **Sugar (`Şeker`)** jar sits a deceptive **Salt (`Tuz`)** shaker and **Chili Sauce (`Acı Sos`)**! If a player sneaks Salt into a sweet order, **Gemini (`gemini-3.5-flash-lite` via `firebase_ai` or Google Cloud Run)** catches the sabotage in its structured JSON review (`ratingStars: 1`, `tasteVerdict: "salty_sabotage"`, `customerReaction`) and roasts the barista with a city-specific joke.

---

## Choose Your Workshop Lane

### Lane A: Zero-Install Browser Path (Google AI Studio Build Mode -> Cloud Run + GitHub)
1. Open [Google AI Studio](https://aistudio.google.com) -> **Build** mode.
2. Copy and paste [`prompts/step-1-base-cafe.md`](prompts/step-1-base-cafe.md) to generate the 2-player Cafe Counter with our 12 base menu items and the 4-City Edition switcher (`Berlin`, `Gaziantep`, `Adana`, `Istanbul`).
3. Copy and paste [`prompts/step-2-custom-dish.md`](prompts/step-2-custom-dish.md) to generate your own **Custom Signature Dish SVG** and **Custom Prank Ingredient SVG** on the fly, wired to the Gemini JSON customer judge.
4. Follow [`prompts/step-3-deploy.md`](prompts/step-3-deploy.md) to click **Deploy to Cloud Run** (`.run.app`, no credit card required on AI Studio Starter Tier) and **Sync to GitHub**.

### Lane B: Flutter + `firebase_ai` + Google Antigravity IDE -> Cloud Run + GitHub
```bash
cd flutter_client
flutter pub get
flutter run -d chrome --dart-define=DEFAULT_CITY=gaziantep --dart-define=GEMINI_API_KEY=your_key_here
```
- **Offline Conference Wi-Fi Fallback:** Pass `--dart-define=OFFLINE_MODE=true` (or leave `GEMINI_API_KEY` empty) to use deterministic city-specific responses from `flutter_client/assets/offline_fallback/mock_responses.json`.
- **Switch City Editions:** Click the flag badge in the top bar (`🇩🇪 Berlin` / `🇹🇷 Gaziantep` / `🇹🇷 Adana` / `🇹🇷 Istanbul`) to open the Settings drawer, or update `active_city_id` in Firebase Remote Config (`flutter_client/remote_config_template.json`).

### Lane C: Phone Play-Tester
Scan any classmate's deployed `.run.app` QR code on the stage screen to test their cafe on your phone and slip Salt (`Tuz`) into a sweet order!

---

## Repository Structure

```text
devfest-2026-backyard-barista-cloudrun/
├── README.md
├── prompts/
│   ├── step-1-base-cafe.md    # AI Studio Build mode seed prompt (Base Cafe + 4-City Switcher)
│   ├── step-2-custom-dish.md  # On-the-fly custom SVG dish + prank icon + Gemini JSON judge
│   └── step-3-deploy.md       # One-click Cloud Run (.run.app) & GitHub sync guide
├── slides/                    # 14-slide flutter_deck presentation + Stage Navigator + Turkish speaker notes
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── theme.dart
│   │   ├── plugins/presenter_menu_plugin.dart
│   │   └── slides/            # Slides 1..14 + /demo-hiccup backup slide
│   └── test/
│       └── deck_manifest_test.dart
└── flutter_client/            # Self-contained Flutter Web app & Cloud Run build context
    ├── pubspec.yaml
    ├── Dockerfile             # Multi-stage Cloud Run container (PORT=8080)
    ├── remote_config_template.json
    ├── assets/
    │   ├── audio/             # 6 cafe sound effects (tap_pop, stealth_wink, serve_bell, sweet_fanfare, salty_buzzer, next_chime)
    │   ├── base/              # 14 studio 9D PNG cafe assets (512x512)
    │   │   ├── drinks/        # espresso.png, milk.png, menengic_coffee.png
    │   │   ├── foods/         # croissant.png, san_sebastian.png, baklava.png, katmer_roll.png
    │   │   ├── toppings_pranks/ # sugar_jar.png, salt_shaker.png, chili_sauce.png, isot_pepper.png
    │   │   └── customers/     # customer_happy.png, customer_shocked.png, customer_salty_disgusted.png
    │   ├── fonts/             # Bundled GoogleSans-Regular, Medium, SemiBold, Bold (.ttf)
    │   ├── editions/
    │   │   └── city_editions.json
    │   └── offline_fallback/
    │       └── mock_responses.json
    └── lib/
        ├── main.dart
        ├── config/
        │   └── city_edition_controller.dart
        ├── data/
        │   ├── ingredients_catalog.dart
        │   └── custom_svg_items.dart
        ├── models/
        │   ├── cafe_review.dart
        │   └── customer_order_ticket.dart
        ├── services/
        │   ├── cafe_judge_service.dart
        │   ├── cafe_sound_controller.dart
        │   ├── sound_player_io.dart
        │   ├── sound_player_stub.dart
        │   └── sound_player_web.dart
        └── ui/
            ├── cafe_counter_screen.dart
            └── city_settings_drawer.dart
```

---

## Full Production Architecture ("En Son Mimaride Ne Yaptık?")

1. **Layer 1 (Presentation & Hybrid Assets):** Pure Flutter Declarative Widgets (`Stack`, `AnimatedScale`, `AnimatedSwitcher`, `SvgPicture`) combining 12 pre-generated PNGs (`assets/base/`) with on-the-fly Gemini-generated inline SVGs (`custom_svg_items.dart`).
2. **Layer 2 (3-Layer Multi-City Configuration):**
   - **Priority 1:** In-App Settings Switcher Override (`city_settings_drawer.dart`)
   - **Priority 2:** Firebase Remote Config (`active_city_id` in `remote_config_template.json`)
   - **Priority 3:** Bundled local fallback (`assets/editions/city_editions.json`)
3. **Layer 3 (AI & Guardrails):** Structured JSON output (`CafeReview`) evaluated by `gemini-3.5-flash-lite` (via `firebase_ai` / Gemini API) with deterministic offline fallback (`mock_responses.json`).
4. **Layer 4 (Serverless Cloud & Source Control):** Stateless container deployed via `gcloud run deploy backyard-barista --source .` to **Google Cloud Run (`*.run.app`)** and synced to **GitHub**.
