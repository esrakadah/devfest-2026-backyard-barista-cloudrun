# ⚡ DevFest 2026 Vibe Lounge & Workshop Challenge Landing Page
## Backyard Barista on Cloud Run: Tatlı mı Tuzlu mu? ☕🥐🧂☁️

- **Speaker & Host:** Esra Kadah (Tech Lead, Senior Flutter & AI Engineer at Antigua Mobile Berlin · Flutter & Dart GDE)
- **Live Cloud Run Reference App (`europe-west3`):** https://backyard-barista-389486729482.europe-west3.run.app
- **Live Cloud Run Mirror (`europe-west1`):** https://backyard-barista-870328613866.europe-west1.run.app
- **Starter GitHub Repository:** https://github.com/esrakadah/devfest-2026-backyard-barista-cloudrun
- **Official Vibe Lounge Badge:** https://goo.gle/devfest26-vibe-lounge

---

## 🇹🇷 Türkçe Sürüm (Gaziantep 15 Kasım · Adana 11 Aralık · İstanbul 19 Aralık)

**Süre:** 45 Dakika (Vibe Lounge) / 80 Dakika (Tam Atölye) | **Seviye:** Başlangıçtan İleriye (Kodlama deneyimi şart değil!)
**Araçlar:** Google AI Studio (`aistudio.google.com`), Google Antigravity (`antigravity.google`), Flutter (`package:http` Gemini REST / `firebase_ai`, `firebase_remote_config`) & Google Cloud Run
**Ödüller:** Toplam **4 Adet Google Renkli Pixel Gözlük (Sarı, Mavi, Yeşil, Kırmızı) + Flutter Dash Hediyesi!** (45 dk Vibe Lounge turunda 2 kazanan / 80 dk tam atölyede 4 kazanan) 🕶️🐦

Hoş geldin! Bugün klavyeyle uzun mesajlar yazılan klasik bir sohbet botu değil; yanındaki arkadaşınla butonlara tıklayarak içecek ve tatlı hazırladığın, karakterlere **5 saniye boyunca ince belli bardakta çay yudumlattığın (`🫖 5sn Çay Yudumlat`)** ve **Şeker (`Tatlı Şeker`) yerine gizlice Tuz (`Tuzluk`) atarsan Gemini'dan 1 yıldızlı komik bir eleştiri yediğin** 2 kişilik bir Kafe Oyunu kurup **Google Cloud Run (`.run.app`)** üzerinde canlıya alacaksın!

### 🚀 Adım Adım Görevler (3 Turda Canlıya Çık!)

#### Seviye 1: Hazır Kafe Görsellerini Çek & Şehir Modunu Seç (1. Tur · 10 Dakika)
1. **Yol A (Tarayıcı / Sıfır Kurulum):** `https://aistudio.google.com` -> **Build** modunu aç. Başlangıç repomuzdaki (`github.com/esrakadah/devfest-2026-backyard-barista-cloudrun`) [`prompts/step-1-base-cafe.md`](../prompts/step-1-base-cafe.md) metnini yapıştır (veya hızlı başlangıç için [`ai_studio_lane_a/index.html`](../ai_studio_lane_a/index.html) dosyasını aç).
2. **Yol B (Flutter + Antigravity):** Başlangıç reposunda `cd flutter_client && flutter run -d chrome --dart-define=DEFAULT_CITY=gaziantep` çalıştır.
3. Üst bardaki **Şehir Seçici (`City Edition`)** menüsünden bulunduğumuz şehri (**🇩🇪 Berlin**, **🇹🇷 Gaziantep**, **🇹🇷 Adana** veya **🇹🇷 Istanbul**) seç ve **🫖 5sn Çay Yudumlat** butonuna basarak karakterlerin ince belli bardakta çay yudumladığını doğrula!

#### Seviye 2: Kendi Özel Tabağını Üret & "Tuz mu Şeker mi?" AI Jürisini Bağla (2. Tur · 15 Dakika)
1. **Kendi İmza Tabağını Üret:** [`prompts/step-2-custom-dish.md`](../prompts/step-2-custom-dish.md) ile Gemini veya Antigravity'den senin kafene özel **1 yeni tatlı (`Fıstıklı Katmer Sarma` vb.)** ve **1 yeni şaka malzemesi (`İsot Biberi` vb.)** üretmesini iste ve tezgaha ekle.
2. **JSON Kafe Eleştirmeni (`CafeReview`):** Oyuncu 3 yuvalı ahşap tepsiyi (`1. İçecek + 2. Tatlı + 3. Kavanoz`) dizip **"Siparişi Servis Et!"** butonuna bastığında `gemini-3.5-flash-lite` seçilen malzemeleri kontrol etsin; eğer tatlı siparişe **Tuz** veya **İsot** karıştıysa `1/5 · Tuzlu Sabotaj 🧂`, eksik istasyon varsa `3/5 · Eksik Tepsi 🧩`, 3 istasyon da tatlıysa `5/5 · Tatlı Mükemmellik ✨` ve `+40` bahşiş döndürsün!

#### Seviye 3: Google Cloud Run (`.run.app`) ve GitHub'da Canlıya Al! (3. Tur · 10 Dakika)
1. [`prompts/step-3-deploy.md`](../prompts/step-3-deploy.md) adımlarını izleyerek AI Studio sağ üst köşedeki **Deploy to Cloud Run** butonuna bas (kredi kartsız Starter Tier) veya Flutter'da `gcloud run deploy backyard-barista --source .` çalıştırarak `.run.app` canlı oyun linkini oluştur.
2. **Sync to GitHub** ile kodu kendi GitHub hesabına gönder ve sahnede 60 saniyelik demoya katıl!

---

## 🇩🇪🇬🇧 English Version (DevFest Berlin · 14 November 2026)

**Duration:** 45 Minutes (Vibe Lounge) / 80 Minutes (Full Workshop) | **Level:** Beginner to Intermediate (Zero coding experience required for Lane A!)
**Tools:** Google AI Studio (`aistudio.google.com`), Google Antigravity (`antigravity.google`), Flutter (`package:http` Gemini REST / `firebase_ai`, `firebase_remote_config`) & Google Cloud Run
**Prizes:** **4 Google-Colored Pixel Sunglasses (Yellow, Blue, Green, Red) + Flutter Dash Gifts** for builders who publish to Cloud Run (`.run.app`) or GitHub and demo live in 60 seconds! (`2` winners per 45-min Vibe Lounge wave / `4` winners in 80-min workshop) 🕶️🐦

### 🚀 3 Progressive Levels

1. **Level 1 (Base Cafe Counter + 4-City Edition Switcher · 10 Min):**
   - **Lane A (Browser / Zero Install):** Open `https://aistudio.google.com` -> **Build** mode and paste [`prompts/step-1-base-cafe.md`](../prompts/step-1-base-cafe.md) (or open [`ai_studio_lane_a/index.html`](../ai_studio_lane_a/index.html)).
   - **Lane B (Flutter + Antigravity):** Run `cd flutter_client && flutter run -d chrome --dart-define=DEFAULT_CITY=berlin`.
   - Switch between **🇩🇪 Berlin**, **🇹🇷 Gaziantep**, **🇹🇷 Adana**, and **🇹🇷 Istanbul**, and tap **`🫖 Sip Tea (5s)`** to watch the characters sip hot Turkish tea for 5 seconds!
2. **Level 2 (Custom AI Dish + Gemini Structured JSON Salt-vs-Sugar Judge · 15 Min):**
   - Paste [`prompts/step-2-custom-dish.md`](../prompts/step-2-custom-dish.md) to generate your own custom signature pastry and stealth prank condiment, wired to `gemini-3.5-flash-lite` structured JSON (`CafeReview`).
3. **Level 3 (Deploy to Google Cloud Run `.run.app` & Sync to GitHub · 10 Min):**
   - Follow [`prompts/step-3-deploy.md`](../prompts/step-3-deploy.md) to click **Deploy to Cloud Run** (no credit card required on AI Studio Starter Tier) or run `gcloud run deploy backyard-barista --source .`, then demo your live `.run.app` URL on stage!
