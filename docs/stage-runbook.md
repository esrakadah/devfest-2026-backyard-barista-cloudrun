# Sahne Günü Runbook'u (Stage-Day Runbook): Backyard Barista on Cloud Run

Bu doküman sahnedeki teknik delivery'nin tek kontrol listesidir: ne zaman ne kontrol edilir, bir şey bozulursa hangi komut çalışır. Konuşma metinleri için [`speaker-drill-cards-tr.md`](speaker-drill-cards-tr.md), katılımcı materyali için Workshop Companion destesine bakın.

| Etkinlik | Tarih | Dil | Format |
|---|---|---|---|
| DevFest Berlin | 14 Kasım 2026 | EN | 2 x 45 dk Vibe Lounge |
| DevFest Gaziantep | 15 Kasım 2026 | TR | 80 dk atölye veya 2 x 45 dk Vibe Lounge |
| DevFest Adana | 11 Aralık 2026 | TR | 30+10 dk ana salon |
| DevFest İstanbul | 19 Aralık 2026 | TR | 30+10 dk ana salon |

---

## T-24 saat: Prova ve Yedekler

1. **Deck testleri yeşil mi?**
   ```bash
   cd slides
   flutter analyze && flutter test        # manifest, konuşmacı notları, 16 slaytın gerçek fontlarla render'ı
   ```
2. **PDF yedek desteyi üret** (sahne bilgisayarı Flutter çalıştıramazsa herhangi bir makineden sunulur):
   ```bash
   cd slides
   flutter test tool/export_slides_test.dart   # build/slides/NN_route.png (2560x1440)
   python3 tool/pngs_to_pdf.py                 # build/slides/backyard_barista_deck.pdf
   ```
   PDF'i bir USB belleğe ve telefona kopyala.
3. **Uygulama testleri ve kaos provası:**
   ```bash
   cd flutter_client
   flutter analyze && flutter test
   dart run tool/rehearsal_3g_check.dart       # Slow 3G + HTTP 429 + 4 şehir x 3 karar matrisi
   ```
4. **Deck'i web olarak derle** ve yerel sunucudan aç (tarayıcı sekmesi ikinci yedek):
   ```bash
   cd slides
   flutter build web --release
   python3 -m http.server 8000 --directory build/web
   ```
5. **Canlı servisleri kontrol et:** iki Cloud Run adresi de `HTTP 200` dönmeli.
   ```bash
   curl -s -o /dev/null -w '%{http_code}\n' https://backyard-barista-389486729482.europe-west3.run.app
   curl -s -o /dev/null -w '%{http_code}\n' https://backyard-barista-870328613866.europe-west1.run.app
   ```
6. **Git tag kontrolü:** katılımcılar `git checkout step-1 / step-2 / step-3 / final` kullanacak. `final` etiketinin en güncel `main` commit'ini gösterdiğinden emin ol (`git log -1 final`); eski bir commit'i gösteriyorsa Web Audio, 3D karakterler gibi son eklemeler o kontrol noktasında yoktur.

## T-2 saat: Salon Kurulumu

- Projektör çözünürlüğünü öğren. Deck 1920x1080 mantıksal kanvasta tasarlandı ve her ekrana ölçeklenir; 4:3 projektörde üst ve altta siyah bant olur, içerik kaybolmaz.
- Sahne laptopunda: deck (`flutter run -d chrome` veya `build/web`), canlı oyun sekmesi, `ai_studio_lane_a/index.html` (29.6 KB, çevrimdışı açılır) ve PDF yedeği açık olsun.
- Telefon hotspot'unu hazırla; salon Wi-Fi'ına güvenme.
- Kendi Gemini anahtarını **sadece yerel** çalıştırmada kullan. Asla `--dart-define=GEMINI_API_KEY` ile public bir web build'i Cloud Run'a deploy etme: dart-define değerleri tarayıcının indirdiği JavaScript'e gömülür.
- Ödülleri (piksel gözlükler, Dash) sahneye koy; slayt 3'te gösterilecek.

## T-15 dakika

- Stage Navigator'ı aç (deck menüsü), zamanlayıcıyı sıfırla.
- Slayt 2 (`/sweet-or-salty`) oylaması için cevabı hatırla: **A şeker, B tuz.**
- Canlı oyunda şehir modunu etkinliğe göre ayarla (`?remote_city=gaziantep` vb.).

## Sahnede: 5 Perdelik Akış

| Perde | Slaytlar | 80 dk atölye | 45 dk Vibe Lounge | 30 dk ana salon |
|---|---|---|---|---|
| 1 · Hook | 1-3 | 00:00-05:00 | 4 dk | 3 dk |
| 2 · Tools | 4-6 | 05:00-11:30 | 4 dk | 4 dk |
| 3 · Gerçek Rakamlar | 7-9 | 11:30-18:30 | 4 dk | 5 dk |
| 4 · Under the Hood | 10-12 | 18:30-25:00 | 3 dk | 4 dk |
| 5 · Build & Ship | 13-15 | 25:00-80:00 | 30 dk | 14 dk (canlı demo + kapanış) |

Her slaytın sağ üstündeki hikaye şeridi salona nerede olduğumuzu gösterir; geçişlerde perde adını yüksek sesle söyle ("Şimdi gerçek rakamlara geçiyoruz").

## Bir Şey Bozulursa

| Belirti | Sahnede yapılacak | Komut veya eylem |
|---|---|---|
| Wi-Fi tamamen koptu | Slayt 16 (`/demo-hiccup`), "tam da bunun için tasarladık" | `flutter run -d chrome --dart-define=OFFLINE_MODE=true` |
| HTTP 429 | Slayt 9'a atıf, uygulama zaten çevrimdışı jüriye düştü | Eylem gerekmez |
| Deck çöktü veya laptop dondu | PDF yedeğine geç | `build/slides/backyard_barista_deck.pdf` |
| AI Studio yavaş | Lane A referans oyununu aç | `ai_studio_lane_a/index.html` |
| Katılımcı geride kaldı | Bir sonraki kontrol noktasına atla, eski turu bitirmeye çalışma | `prompts/step-N-*.md` veya `git checkout step-N` |
| Lane B deploy fatura istiyor | Bugün için Lane A deploy'una yönlendir | AI Studio'da "Deploy to Cloud Run" |

## Sonrası

- Kazanan `.run.app` linklerini topla, etkinlik sonrası paylaşım için not al.
- Sahnede kendi anahtarını kullandıysan AI Studio'da anahtarı döndür (yenisini oluştur, eskisini sil).
