# Gerçek Rakamlar (Real Numbers) Telemetry & Benchmark Report

- **Date Measured:** 2026-10-24 (`Europe/Berlin`)
- **Benchmark Harness:** [`flutter_client/tool/benchmark_gaziantep.dart`](../flutter_client/tool/benchmark_gaziantep.dart)
- **Live Cloud Run Target (`europe-west3` Frankfurt):** `https://backyard-barista-389486729482.europe-west3.run.app` (`devfest-backyard-barista-2026`)
- **Live Cloud Run Mirror (`europe-west1` Belgium):** `https://backyard-barista-870328613866.europe-west1.run.app` (`soundstage-dea29`)

---

## 1. Live Cloud Run & Offline Fallback Latency (`50` Iterations + `3` Warm-Up)

| Surface / Path | First Call (Cold / TLS) | Warm `p50` | Warm `p95` | Warm `p99` | Payload Size | Success Rate |
|---|---:|---:|---:|---:|---:|---:|
| **Cloud Run Index HTML (`europe-west3`)** | `528.95 ms` | **`53.81 ms`** | **`75.52 ms`** | `96.55 ms` | `0.5 KB` | `50/50` (`100%`) |
| **Cloud Run 9D Studio PNG (`espresso.png`)** | `260.02 ms` | **`139.03 ms`** | **`187.70 ms`** | `191.26 ms` | `372.6 KB` | `15/15` (`100%`) |
| **Cloud Run Audio Cue (`tea_sip.wav`)** | `121.26 ms` | **`52.20 ms`** | **`57.06 ms`** | `62.76 ms` | `145.6 KB` | `15/15` (`100%`) |
| **Offline Conference Fallback (`mock_responses.json`)** | `6.79 ms` | **`0.09 ms`** | **`0.43 ms`** | `0.46 ms` | `3.9 KB` | `50/50` (`100%`) |

### Key Takeaways for Stage ("Gerçek Rakamlar" Block, Minutes 10 - 18)
1. **Sub-100ms Warm Cloud Run Delivery (`53.81 ms` p50 / `75.52 ms` p95):**
   - Because the multi-stage [`Dockerfile`](../flutter_client/Dockerfile) compiles Flutter Web at build time and serves static assets from `nginx:alpine` on `PORT=8080`, warm HTTP/2 responses from `europe-west3` complete in **`53.81 ms` p50** and **`75.52 ms` p95**, and even the initial TLS + cold request completes in **`528.95 ms`**.
2. **Bounded Timeout Guardrails in `CafeJudgeService`:**
   - Live Gemini JSON call timeout: **`8,000 ms`** (`_geminiRequestTimeout = Duration(seconds: 8)` in [`cafe_judge_service.dart:11`](../flutter_client/lib/services/cafe_judge_service.dart)).
   - Offline conference bundle load timeout: **`250 ms`** (`_offlineBundleLoadTimeout = Duration(milliseconds: 250)` in [`cafe_judge_service.dart:12`](../flutter_client/lib/services/cafe_judge_service.dart)).
3. **Sub-Millisecond Offline Fallback (`0.09 ms` p50):**
   - If conference Wi-Fi drops completely or a shared NAT hits HTTP `429`, `CafeJudgeService` falls back to `assets/offline_fallback/mock_responses.json` in **`0.09 ms` p50** (`90 microseconds`), keeping the 60fps UI and city-specific salt-vs-sugar roasts working with zero interruption.

---

## 2. Token Footprint & Cost Math (`gemini-3.5-flash-lite`)

| Metric | Measured / Verified Value | Notes |
|---|---:|---|
| **Tokens Spent During Tray Assembly** | **`0 tokens`** | Tapping drinks, pastries, twin jars, and the 5s tea sip runs 100% locally at 60fps |
| **Prompt Input Tokens on `Serve Order!`** | **`~152 tokens`** | System instructions + active City Edition + selected tray list + prank flags |
| **Structured JSON Output Tokens (`CafeReview`)** | **`~118 tokens`** | `ratingStars`, `tasteVerdict`, `customerFace`, `headline`, `customerReaction`, `cityBonusTip` |
| **Total Tokens per Completed Order** | **`~270 tokens`** | 1 single REST / `firebase_ai` call per served tray |
| **Cost per `1,000` Cafe Orders** | **`\$0.0468 USD`** | Less than 5 cents for a 300-attendee hall playing 3+ rounds each |
| **Cost per `100,000` Cafe Orders** | **`\$4.68 USD`** | Based on `gemini-3.5-flash-lite` standard pricing (`\$0.075/1M` in, `\$0.30/1M` out) |

---

## 3. Reproducing This Benchmark

```bash
cd flutter_client
dart run tool/benchmark_gaziantep.dart --iterations=50
```
