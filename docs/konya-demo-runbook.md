# DevFest Konya 2026 Akış Kartı: 30 Dakika, Türkçe Ana Salon

- **Tarih ve Saat:** Cumartesi 21 Kasım 2026, **14:30 - 15:00 TR** (Berlin 12:30 - 13:00)
- **Mekân ve Salon:** Selçuk Üniversitesi Sultan Alparslan Kültür Merkezi, **850 kişilik ana salon** (yalnızca HDMI çıkışı: kendi adaptörünü götür, önceki 15 dk arada test et)
- **Başlık:** *Backyard Barista on Cloud Run: AI Studio, Antigravity ve Flutter ile Çok Oyunculu AI Kafe Oyunu Yap ve Canlıya Al*
- **Format:** 30 dakika tek parça konuşma ve canlı sahne demosu; salonda ayrı soru-cevap süresi yok (sorular konuşma bitiminde fuayede)
- **Deste Modu:** `--dart-define=DECK_LANG=tr --dart-define=DECK_THEME=candle` (Konya'nın büyücü okulu temasına uygun mum ışığı sürümü; `DECK_THEME` verilmezse standart GDE lacivert deste açılır. `DECK_CITY` varsayılanı `konya`; 5 Aralık İzmir için `--dart-define=DECK_LANG=tr --dart-define=DECK_CITY=izmir`)
- **Etkinlik kimliği sürümü (isteğe bağlı):** `--dart-define=DECK_LANG=tr --dart-define=DECK_THEME=konya` aynı slaytları etkinliğin kendi görsel diliyle açar (parşömen zemin, bordo mürekkep Konya silüeti ve sur, gotik başlıklar; içerik koyu kartlarda kalır). Slayt sırası ve konuşmacı notları `candle` sürümüyle aynıdır.

---

## 1. 30 Dakikalık Saat Tablosu (Hedef Bütçe: 28 dk 45 sn + 1 dk 15 sn Tampon)

| Saat | Slayt | Rota | Odak ve Eylem |
|---|---|---|---|
| `00:00 - 01:15` | 1 | `/title` | "Merhaba Konya!", rol + GDE tanıtımı, Google adına konuşmama cümlesi |
| `01:15 - 02:30` | 2 | `/sweet-or-salty` | Salon el oylaması: **A şeker, B tuz**; Gemini şemalı JSON jürisi fikri |
| `02:30 - 03:15` | 3 | `/workshop-contract` | 3 deneyim katmanı (AI Studio, Flutter + Antigravity, gerçek rakamlar + canlı QR sözü) |
| `03:15 - 04:30` | 4 | `/ai-studio-pipeline` | Prompt -> önizleme -> GitHub -> kartsız Cloud Run (`GEMINI_API_KEY` sunucuda) |
| `04:30 - 05:45` | 5 | `/meet-antigravity` | Agent Mode ile çok dosyalı değişiklik ve `CustomPainter` vektör üretimi |
| `05:45 - 07:00` | 6 | `/pure-flutter-widgets` | 3 şeritli `BaristaFlameGame` sahnesi + Flutter widget'larıyla 3 raf ve 3 gözlü tepsi |
| `07:00 - 08:30` | 7 | `/real-numbers-latency` | 8 sn Gemini / 15 sn Gemma / 250 ms paket sınırları; 53,81 ms p50, 1,4 sn ort. Gemini |
| `08:30 - 10:00` | 8 | `/real-numbers-cost` | Tepside 0 token, serviste ~270 token (~4,7 sent / 1.000 sipariş); Ekim 2026 `2.5` kısıtı |
| `10:00 - 11:30` | 9 | `/room-quota-trap` | GCP projesi başına 5-15 RPM tuzağı, nginx `10r/s` sınırı ve 429'da 250 ms yerel yedek |
| `11:30 - 12:45` | 10 | `/multi-city-remote-config` | `CityEditionController` 3 katmanlı öncelik; 5 şehir (bugün: Alaaddin Kahve & Tatlı Durağı) |
| `12:45 - 14:00` | 11 | `/salt-sugar-mechanic` | Android Chrome `NDEFReader` Web NFC + `_verdictMatchesPranks` Dart doğrulaması |
| `14:00 - 15:00` | 12 | `/hybrid-asset-pipeline` | Pakette 14 PNG + 5 Lottie + 9 ses, uzantılarda `CustomPainter` kodu |
| `15:00 - 25:30` | 13 | `/live-build-dashboard` | **3 adımlı canlı sahne demosu** (aşağıda) + 850 kişiye canlı QR oyunu |
| `25:30 - 27:00` | 14 | `/architecture-recap` | 4 katmanlı üretim mimarisi özeti |
| `27:00 - 28:15` | 15 | `/winner-podium-closing` | Eve götürülecek 4 mühendislik kuralı + açık kaynak repo QR'ı |
| `28:15 - 28:45` | 16 | `/bana-ulasin` | `esratech.com` QR kodu, fuaye daveti, "Çok teşekkürler Konya!" |
| *(Yedek)* | 17 | `/demo-hiccup` | Wi-Fi tamamen kesilirse şakalı geçiş ekranı |
| *(Yedek, 45 sn)* | 18 | `/generate-vs-decide` | Süre 13:30 altındaysa Slayt 11'den uğranır (`gemini-decision-1`: `noul`, `choice`, `score`) |

**Geç kalırsan kesme sırası (saat, sahnedeki sayaca göre):**
| Sayaç | Durum | Ne kesilir |
|---|---|---|
| `13:30` | Slayt 11'desin | Slayt 18 (`/generate-vs-decide`) açılmaz. |
| `15:00` | Demo başlamadı | Slayt 12 tek cümleyle (15 sn) geçilir, salonun QR süresi 90 saniyeye iner. |
| `20:00` | Hâlâ Adım 1'desin | Adım 2'de `git show` atlanır, yalnızca bayrak rozetinden şehir geçişi gösterilir. |
| `24:00` | Adım 3 bitmedi | Adım 3 30 saniyede gösterilir ya da Slayt 17 üzerinden anlatılır. |
| `26:00` | Slayt 14'e yeni geldin | Slayt 14 tek cümle. **Slayt 15 ve Slayt 16 asla atlanmaz.** |

---

## 2. Canlı Sahne Demosu (Slayt 13 · 15:00 - 25:30)

### Adım 1 (5 dk): Canlı Cloud Run ve Gemini Jürisi + Salon Oynuyor
1. Canlı `europe-west3` sekmesine geç (`Alaaddin Kahve & Tatlı Durağı` başlığını göster). QR henüz ekranda değil: canlı Gemini kanıtı senin iki tepsin.
2. `Espresso` + `Fıstıklı Baklava` + `Şeker` diz ve **Servis Et**: 5 yıldız ve kart altındaki `Canlı Gemini 3.5 Flash-Lite` rozetini göster.
3. `Şeker` yerine `Tuz` koyup **Servis Et**: 1 yıldız ve *"Alaaddin Tepesi'nde misafire böyle ikram olmaz!"* yanıtını göster.
4. Tam ekran QR sekmesine geç (`konya-qr-2026-11-21.html`, tek büyük QR). Salona 2 dakika ver. Slayt 13'teki QR arka sıralar için küçük kalır, o yüzden ana yol tam ekran sekmedir.
5. Söyle: rozet `Canlı Gemini` yerine `Yerel JSON Şeması` diyorsa bir şey bozulmadı, 850 kişi tek anahtarı zorladı ve son önlem çalışıyor. Salondan bir yorumu sesli oku, "Tamam, devam" de.

### Adım 2 (2 dk): Konya Sürümü (AI Ajanıyla 11 Dosya + Şehir Geçişi)
1. Sahnede canlı kod üretimi beklemek yerine terminal sekmesinde Konya sürümü farkını tek ekranda göster. Terminal sahneden önce açık olsun: yazı boyutu en az 24 punto, komut yazılmış ve Enter bekliyor.
   ```bash
   cd ~/Documents/esradev/devfest-2026-backyard-barista-cloudrun-konya-theme && clear && git show --stat --format='%h %s' adfcb45
   ```
2. Canlı Cloud Run sekmesinde üst bardaki bayrak rozetine tıkla: `CitySettingsSheet` çekmecesinden tek bir şehir geçişini canlı göster (örneğin `Konya` -> `Berlin` -> `Konya`).

### Adım 3 (3 dk): Wi-Fi Kapalı Kaos Testi (Yerel Gemma 4 + 250 ms Paket)
1. macOS üst menüden Wi-Fi'ı kapat.
2. Yerel sekmede (`http://localhost:8104`, release build, `OFFLINE_MODE=true` + `LOCAL_JUDGE_URL=http://localhost:11434/api/chat`) tuzlu tepsiyi servis et. Sekmeyi sahnede yenileme.
3. Yanıtın 5-8 saniyede bu laptoptaki `gemma4:12b-it-qat` modelinden (rozet: `Yerel Gemma 4 (çevrimdışı)`) geldiğini, Ollama kapalıysa bile `250 ms` içinde `mock_responses.json` paketinin devraldığını göster.
4. Wi-Fi'ı tekrar aç ve Slayt 14'e dön.

### Sorun olursa (her satır tek hamle)
| Ne oldu | Ne yap |
|---|---|
| Salon Wi-Fi'ı gitti | Slayt 17, sonra hazır yerel çevrimdışı sekme. Sahnede komut çalıştırma. |
| Canlı sekme 8 saniyeden uzun bekliyor | "8 saniyelik sınırımız tam bunun için var" de, yedek yanıtı göster, devam et. |
| Gemma 15 saniyede dönmedi | Paket yanıtı ekrana gelir: "Üçüncü katman devraldı" de. |
| QR arkadan okunmuyor | Tam ekran QR sekmesi; adresi sesli söyleme, çok uzun. |
| HDMI görüntüsü kırpık | Önceki arada 1920x1080 ve 16:9 kontrolü; sahnede ise tarayıcıyı tam ekran yap (Cmd+Ctrl+F). |
| Süre 24:00'ü geçti | Adım 3'ü 30 saniyede göster, slayt 14'e dön. |
| Sunum penceresi tek ekranda kaldı | Sistem Ayarları > Ekranlar: "Ekranı genişlet" seç. Olmazsa notları telefondaki `speaker_notes.md` üzerinden oku. |

---

## 3. Sabah ve Sahne Öncesi Komutları (Cumartesi 21 Kasım)

### 0. Sahneye Çıkmadan (T-30 dk, sırayla)
1. Şarj aleti takılı, HDMI adaptörü yanında. Laptop internete **telefonun hotspot'undan** bağlı (salon Wi-Fi'ını 850 telefon paylaşıyor).
2. Sistem Ayarları > Ekranlar: **Ekranı genişlet** (yansıtma değil). Slayt penceresi projektörde, Presenter View laptopta.
3. Odak > **Rahatsız Etme** açık.
4. Laptop uyumasın:
```bash
caffeinate -dimsu &
```
5. Sekme sırası: deste (`localhost:8103`), canlı Cloud Run, tam ekran QR, yerel oyun (`localhost:8104`), terminal (24 punto, `git show` yazılı).
6. PDF deste ve `speaker_notes.md` telefonda açık.

### A. Yerel Gemma Jürisini Isıt (T-30 dk; 2 saat bellekte kalır)
```bash
launchctl setenv OLLAMA_KEEP_ALIVE 2h
```
```bash
brew services restart ollama
```
```bash
curl -s http://localhost:11434/api/generate -d '{"model":"gemma4:12b-it-qat","prompt":"merhaba","think":false,"stream":false}' > /dev/null
```
Sahneye çıkmadan hemen önce modelin hâlâ yüklü olduğunu doğrula (`UNTIL` sütunu 1 saatten fazla göstermeli):
```bash
ollama ps
```

### B. Desteyi Çevrimdışı Release Build Üzerinden Aç (Ana Yol, İnternetsiz Çalışır)
```bash
python3 -m http.server 8103 --bind 127.0.0.1 --directory ~/Documents/esradev/devfest-2026-backyard-barista-cloudrun-konya-theme/slides/build/web
```
Chrome'da `http://localhost:8103` adresini aç -> sağ alt üç nokta menüsünden **Presenter View**'a tıkla (notlar ve sayaç senkronize olur).

### C. Yerel Çevrimdışı Konya Oyun Sekmesini Aç (Release Build, CDN'siz)
```bash
python3 -m http.server 8104 --bind 127.0.0.1 --directory ~/Documents/esradev/devfest-2026-backyard-barista-cloudrun-konya-theme/flutter_client/build/web
```
Chrome'da `http://localhost:8104` adresini aç, Wi-Fi açıkken bir tepsi servis et (sekme ısınsın), sonra sekmeye dokunma. Build yoksa ya da kod değiştiyse yeniden üret:
```bash
cd ~/Documents/esradev/devfest-2026-backyard-barista-cloudrun-konya-theme/flutter_client && fvm flutter build web --release --no-web-resources-cdn --dart-define=DEFAULT_CITY=konya --dart-define=OFFLINE_MODE=true --dart-define=LOCAL_JUDGE_URL=http://localhost:11434/api/chat
```

### D. Yedek Dosyalar (Herhangi Bir Bilgisayardan Sunulabilir)
- PDF deste (18 sayfa): `slides/build/slides/backyard_barista_deck.pdf`
- Konuşmacı notları: `slides/build/slides/speaker_notes.md`
- Görselli sahne kartı: `~/Documents/esradev/konya-sahne-karti-2026-11-21.html`
- Arka sıralar için tam ekran QR: `~/Documents/esradev/konya-qr-2026-11-21.html`

---

## 4. Sahnede Söylenmeyecekler (Doğrulanmış Sınırlar)

- Decisions API için gecikme rakamı ("150-250 ms") söyleme: resmi dokümanda gecikme sayısı yok; yalnızca `0 çıktı token'ı` ve `v1beta` REST söyle.
- Antigravity Orchestrator yüzdeleri ("%24 daha az kota", "%19 daha hızlı") ikincil kaynaktan geldiği için sahnede telaffuz etme.
- `60fps` ölçüm değil tasarım hedefidir ("60fps hedefimiz"); `270 token` ve `1.000 sipariş ≈ 4,7 sent` yaklaşık hesaptır.
