# Round 3 Guide: Publish to Google Cloud Run (`.run.app`) & GitHub

## Path A: From Google AI Studio Build Mode (No Credit Card Required)
1. Click **"Deploy to Cloud Run"** in the top-right bar of Google AI Studio.
   - AI Studio Starter Tier provisions a managed HTTPS `https://*.run.app` service and stores your `GEMINI_API_KEY` server-side.
2. Click **"Sync to GitHub"** in the top-right bar of Google AI Studio to push your complete web game to your personal GitHub account.
3. Open your live `.run.app` URL on your phone, switch the City Edition to **Gaziantep 🇹🇷** (or **Berlin 🇩🇪**), sneak **Salt (`Tuz`)** into a Baklava + Espresso order, and raise your hand to demo on stage for the **Google Pixel Sunglasses + Dash** prize!

---

## Path B: From Flutter + Google Antigravity (`flutter_client/`)
```bash
cd flutter_client

# 1. Verify static analysis and widget tests pass locally
flutter analyze
flutter test

# 2. Deploy the containerized Flutter Web app to Google Cloud Run from source
# Note: flutter_client/Dockerfile bakes DEFAULT_CITY and GEMINI_MODEL at Docker build time via --dart-define
# and runs in deterministic offline mode unless GEMINI_API_KEY is supplied at build time (whereas Path A's
# AI Studio Cloud Run service proxies GEMINI_API_KEY server-side).
gcloud run deploy backyard-barista \
  --source . \
  --region europe-west1 \
  --allow-unauthenticated
```
