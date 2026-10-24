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

# 2. Store your Gemini API key once in Secret Manager (it never goes into the web build)
printf '%s' "$GEMINI_API_KEY" | gcloud secrets create gemini-api-key --data-file=-
gcloud secrets add-iam-policy-binding gemini-api-key \
  --member="serviceAccount:$(gcloud projects describe "$(gcloud config get-value project)" --format='value(projectNumber)')-compute@developer.gserviceaccount.com" \
  --role=roles/secretmanager.secretAccessor

# 3. Deploy the containerized Flutter Web app to Google Cloud Run from source
# The nginx in flutter_client/Dockerfile serves the game and proxies /api/gemini/generate to Gemini, adding the key
# from the secret server-side (like Path A's AI Studio service). Without the secret the game uses the offline roasts.
gcloud run deploy backyard-barista \
  --source . \
  --region europe-west1 \
  --allow-unauthenticated \
  --set-secrets GEMINI_API_KEY=gemini-api-key:latest \
  --max-instances 3
```

`GEMINI_RATE_LIMIT` (default `10r/s`, burst 20, per instance) caps how fast the whole room can spend the key; a
request over the cap gets a 429 and that tray falls back to the offline roast.
