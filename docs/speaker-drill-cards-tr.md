# Sahne Prova Kartları (Drills 1-4): Backyard Barista on Cloud Run

- **Etkinlik Takvimi:**
  - **🇩🇪 DevFest Berlin:** 14 Kasım 2026 (`EN` · 2 x 45 dk Vibe Lounge)
  - **🇹🇷 DevFest Gaziantep:** 15 Kasım 2026 (`TR` · 80 dk Tam Atölye veya 2 x 45 dk Vibe Lounge)
  - **🇹🇷 DevFest Adana:** 11 Aralık 2026 (`TR`)
  - **🇹🇷 DevFest İstanbul:** 19 Aralık 2026 (`TR`)
- **Canlı Cloud Run URL:** `https://backyard-barista-389486729482.europe-west3.run.app`
- **Public GitHub Repo:** `https://github.com/esrakadah/devfest-2026-backyard-barista-cloudrun` (`prompts/step-1-base-cafe.md`, `prompts/step-2-custom-dish.md`, `prompts/step-3-deploy.md`, `ai_studio_lane_a/index.html`, ve uygulama içi `Round 2 AI SVGs` anahtarı)

---

## Drill 1: 60 Saniye Açılış (Cold Open · Slayt 1, Slayt 2 `/sweet-or-salty` ve Slayt 3)

### Türkçe Metin (Gaziantep, Adana, İstanbul)
> "Hoş geldiniz! Bugün burada sıkıcı bir metin sohbet botu yazmayacağız. Yanınızdaki arkadaşınızla tek satır yazı yazmadan, sadece tezgah üzerindeki içecek, tatlı ve baharat kavanozlarına dokunarak oynanan 2 kişilik bir AI Kafe Oyunu kurup Google Cloud Run üzerinde canlıya alacağız: **Backyard Barista on Cloud Run: Tatlı mı Tuzlu mu?**
>
> Oyunun kuralı çok basit: Oyuncu 1 içecekleri hazırlarken ve karakterimiz ince belli bardakta 5 saniye boyunca tavşan kanı çayını yudumlarken, Oyuncu 2 tatlı tabağını kuruyor. Ama tezgahta şeker kavanozunun hemen yanında ikizi gibi duran bir **Tuzluk** ve **İsot Biberi** var! Eğer tatlı siparişe gizlice tuz atarsanız, Gemini yapılandırılmış JSON jürimiz bunu yakalayıp şehre özel 1 yıldızlı komik bir eleştiri basıyor.
>
> Salondaki herkes bilgisayar veya telefon fark etmeksizin 3 kulvardan (`Yol A: Tarayıcıda AI Studio`, `Yol B: Flutter + Antigravity`, `Yol C: Mobil QR`) kendi canlı `.run.app` linkiyle çıkacak. Ve sonunda oyununu canlıya alıp sahnede 60 saniyede gösteren katılımcılarımıza **4 adet Google Renkli Piksel Güneş Gözlüğü (Sarı, Mavi, Yeşil, Kırmızı) ve Flutter Dash** hediye ediyorum! *(45 dk Vibe Lounge turunda 2 kazanan / 80 dk tam atölyede 4 kazanan)*"

### English Script (DevFest Berlin)
> "Welcome everyone! Today we are not building another text-box chatbot. Together with the person sitting next to you, we are building and shipping a zero-typing, 2-player multiplayer AI cafe game on Google Cloud Run: **Backyard Barista on Cloud Run: Sweet or Salty?**
>
> Player 1 pulls the espresso shots and triggers our 5-second Turkish tulip-glass tea sipping animation, while Player 2 plates the pastries. Right next to the sugar jar sits an almost identical **Salt Shaker**! If your partner sneaks salt into a sweet order, our Gemini structured JSON judge catches the sabotage and drops a 1-star Berlin roast.
>
> Whether you are on a browser in Lane A, Flutter and Google Antigravity in Lane B, or on your phone in Lane C, nobody leaves empty-handed. And builders who deploy their `.run.app` link and demo it on stage in 60 seconds win **4 Google-Colored Pixel Sunglasses (Yellow, Blue, Green, Red) and Flutter Dash gifts**! *(2 winners per 45-min Vibe Lounge wave / 4 winners in 80-min workshop)*"

---

## Drill 2: 90 Saniye Kapanış ve 4 Katmanlı Mimari Özeti (Slayt 14 ve Slayt 15)

### Türkçe Metin (Dakika 58 / Vibe Lounge Dakika 35)
> "Harika iş çıkardınız! Şimdi ödüllere geçmeden önce son 90 saniyede bugün kurduğumuz sistemin neden sadece bir oyuncak değil, doğrudan üretime hazır 4 katmanlı bir bulut mimarisi olduğuna bakalım:
>
> 1. **Katman 1 (Sunum ve Hibrit Varlıklar):** Oyun motoru (`Flame`) karmaşası yerine saf Flutter widget'ları (`LayoutBuilder`, `Stack`, `AnimatedScale`, `CustomPaint`) ile masaüstünde 2x2 tezgah ızgarası ve 3 yuvalı ahşap tepsi kurduk. GitHub repomuzdaki **20 hazır 9D stüdyo PNG görselini, 5 Lottie animasyonunu ve 10 ses efektini (Web Audio API + WAV)**, 2. Turda yolda ürettiğimiz vektör çizimlerle birleştirdik.
> 2. **Katman 2 (3 Katmanlı Şehir Konfigürasyonu):** Uygulama yeniden derlenmeden `Berlin`, `Gaziantep`, `Adana` ve `İstanbul` arasında geçiş yapıyor. Öncelik 1 uygulama içi ayar çekmecesi, Öncelik 2 canlı **Firebase Remote Config (`active_city_id` / `?remote_city=`)** yayını ve Öncelik 3 çevrimdışı yerel JSON (`city_editions.json`) yedeklemesi.
> 3. **Katman 3 (Yapay Zeka ve Kota Koruması):** Her buton tıklamasında LLM çağırmak yerine 3 yuvalı tepsi servis edildiğinde sipariş başına tek bir `gemini-3.5-flash-lite` yapılandırılmış JSON (`CafeReview`: `1/5` sabotaj, `3/5` eksik tepsi, `5/5` tatlı mükemmellik) çağrısı yapıyoruz. 1.000 siparişin maliyeti sadece **`$0.0468` USD** ve konferans Wi-Fi'ı kopsa bile `mock_responses.json` **`0.09 ms`** içinde devreye giriyor.
> 4. **Katman 4 (Sunucusuz Dağıtım):** Çok aşamalı `Dockerfile` ve `nginx` ile paketlenen durumsuz konteynerimiz `europe-west3` bölgesinde Google Cloud Run üzerinde **`53.81 ms` p50** sıcak yanıt süresiyle çalışıyor.
>
> Şimdi `.run.app` veya GitHub linkini yayınlayanları 60 saniyelik sahne demosu ve **Google Piksel Gözlük + Dash** ödülleri için sahneye alıyorum!"

---

## Drill 3: 5 Dakika Kesinti Planı (Önceki Oturum Uzarsa Hızlı Sıkıştırma)

Eğer önceki konuşmacı süreyi aşarsa veya salon geç teslim edilirse:

1. **Slayt Bölümü (25 dk -> 17 dk):**
   - Slayt 7 (`Latency`) ve Slayt 8 (`Cost`) üzerinde sadece başlık metriklerini (`53.81 ms` p50 Cloud Run, `$0.0468` / 1.000 sipariş) söyleyip geç.
   - Slayt 10 (`Multi-City`) ve Slayt 11 (`Salt vs Sugar`) demosunu doğrudan canlı uygulama üzerinde tek seferde göster.
2. **Canlı İnşa Bölümü (33 dk -> 25 dk):**
   - Katılımcıları doğrudan hazır referans oyun (`ai_studio_lane_a/index.html` / `flutter_client`) ve uygulama içi **`Round 2 AI SVGs: ON`** anahtarından başlat; 2. Tur ve 3. Tur istemlerini (`prompts/step-2-custom-dish.md` + `prompts/step-3-deploy.md`) tek adımda birleştir.
3. **Sabit Bitiş Kuralı:** Slayt 14 (`Final Architecture Recap`) ve Slayt 15 (`Winner Podium & Pixel Sunglasses`) **asla atlanmaz**; son 7 dakika her zaman mimari özeti ve ödül törenine ayrılır.

---

## Drill 4: Canlı Demo Kurtarma ve 20 Dakika Hızlandırılmış Akış (`Slayt 16: /demo-hiccup`)

Sahnede yaşanabilecek 4 teknik aksilik ve tek saniyelik kurtarma komutları:

| Senaryo | Sahnede Söylenecek Cümle | Tek Komut / Eylem |
|---|---|---|
| **1. Konferans Wi-Fi'ı Tamamen Koptu** | *"İşte bu yüzden üretim mimarisinde her zaman çevrimdışı yedekleme katmanı kuruyoruz; `mock_responses.json` `0.09 ms` içinde devrede!"* | Canlı sekmede oyun kesintisiz devam eder; veya `flutter run -d chrome --dart-define=OFFLINE_MODE=true` |
| **2. Ortak API Anahtarı HTTP `429` Kota Sınırına Takıldı** | *"Slayt 9'da konuştuğumuz 300 kişilik salon kota tuzağını canlı gördük; uygulama çökmeden yerel JSON jürisine düştü!"* | `CafeJudgeService` otomatik olarak `isFromLiveGemini: false` ile 1-yıldız / 5-yıldız yerel kararı gösterir |
| **3. AI Studio Tarayıcı Sekmesi Yavaşladı (3G Darboğazı)** | *"Yol A için hazırladığımız `45.7 KB` tek dosyalık referans oyunumuzu açıyoruz; Slow 3G'de bile `0.96` saniyede yükleniyor!"* | `ai_studio_lane_a/index.html` dosyasını tarayıcıda aç |
| **4. Katılımcı Kodu Bozuldu veya Geride Kaldı** | *"Kimse geride kalmıyor; hemen bir sonraki turun hazır kontrol noktasına geçiyoruz!"* | `prompts/step-1-base-cafe.md` -> `Round 2 AI SVGs: ON` anahtarı (`prompts/step-2-custom-dish.md`) -> `prompts/step-3-deploy.md` (`ai_studio_lane_a/index.html`) |
