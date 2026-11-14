# Sahne Günü Runbook'u (Stage-Day Runbook): Backyard Barista on Cloud Run

Bu doküman sahnedeki teknik delivery'nin tek kontrol listesidir: ne zaman ne kontrol edilir, bir şey bozulursa hangi komut çalışır. Konuşma metinleri için [`speaker-drill-cards-tr.md`](speaker-drill-cards-tr.md), katılımcı materyali için Workshop Companion destesine bakın.

| Etkinlik | Tarih | Dil | Format |
|---|---|---|---|
| DevFest Berlin | 14 Kasım 2026 | EN | Barista konuşması yok: 10:00 Room 2 konuşması "Dressing Up AI" (ayrı deste, `esrakadah/modemoiselle_deck`). 11:00-15:00 Vibe Lounge'da katılımcılar Google'ın resmi Barista rehberini izler; bu oyun orada sadece opsiyonel demo ([İngilizce akış kartı](berlin-45-en.md)) |
| DevFest Gaziantep | 15 Kasım 2026 | TR | 80 dk atölye veya 2 x 45 dk Vibe Lounge |
| DevFest Konya | 21 Kasım 2026 | TR | 14:30 ana salon, 30 dk ([Konya akış kartı](konya-demo-runbook.md)) |
| DevFest Adana | 11 Aralık 2026 | TR | 30+10 dk ana salon |
| DevFest İstanbul | 19 Aralık 2026 | TR | 30+10 dk ana salon |

Berlin günü akşamı Gaziantep uçuşu 20:40: Vibe Lounge 15:00'te biter, havalimanı için zamanında çık. Laptopu, USB'deki PDF yedeğini ve NFC etiketlerini el bagajına koy.

---

## T-24 saat: Prova ve Yedekler

1. **Deck testleri yeşil mi?**
   ```bash
   cd slides
   flutter analyze && flutter test        # manifest, konuşmacı notları, 17 slaytın gerçek fontlarla render'ı
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
   `europe-west1` aynasında Gemini anahtarı yok: `200` döner ama kararlar paketlenmiş cevaplardan gelir. Gemini'ı sahnede sadece `europe-west3` üzerinde göster.
6. **Yerel Gemma jürisi (sadece Ollama'lı laptopta):** model indirilmiş olmalı (`ollama list` içinde `gemma4:12b-it-qat`, 7.2 GB). Yoksa evde, hızlı ağda `ollama pull gemma4:12b-it-qat`; salon Wi-Fi'ında indirme. Sonra bir prova turu:
   ```bash
   cd flutter_client
   flutter run -d chrome --dart-define=DEFAULT_CITY=gaziantep --dart-define=OFFLINE_MODE=true --dart-define=LOCAL_JUDGE_URL=http://localhost:11434/api/chat
   ```
   Tuzlu bir tepsi gönder: karar Türkçe ve 5-8.5 s içinde gelmeli, kaynak `localGemma` olmalı. 15 s'yi geçerse karar paketlenmiş cevaplara düşer.
7. **Git tag kontrolü:** katılımcılar `git checkout step-1 / step-2 / step-3 / final` kullanacak. `final` etiketinin en güncel `main` commit'ini gösterdiğinden emin ol (`git log -1 final`); eski bir commit'i gösteriyorsa Web Audio, yeni sahne görünümü gibi son eklemeler o kontrol noktasında yoktur.

## T-2 saat: Salon Kurulumu

- Projektör çözünürlüğünü öğren. Deck 1920x1080 mantıksal kanvasta tasarlandı ve her ekrana ölçeklenir; 4:3 projektörde üst ve altta siyah bant olur, içerik kaybolmaz.
- Sahne laptopunda: deck (`flutter run -d chrome` veya `build/web`), canlı oyun sekmesi, `ai_studio_lane_a/index.html` (49.5 KB) ve PDF yedeği açık olsun. Lane A dosyasını reponun içinden aç: görselleri `../flutter_client/assets/` yolundan okur, tek başına kopyalanırsa görseller internetten gelir.
- Telefon hotspot'unu hazırla; salon Wi-Fi'ına güvenme.
- Kendi Gemini anahtarını **sadece yerel** çalıştırmada kullan. Asla `--dart-define=GEMINI_API_KEY` ile public bir web build'i Cloud Run'a deploy etme: dart-define değerleri tarayıcının indirdiği JavaScript'e gömülür.
- Ödülleri (piksel gözlükler, Dash) sahneye koy; slayt 3'te gösterilecek.

## T-15 dakika

- Stage Navigator'ı aç (deck menüsü), zamanlayıcıyı sıfırla.
- Slayt 2 (`/sweet-or-salty`) oylaması için cevabı hatırla: **A şeker, B tuz.**
- Canlı oyunda şehir modunu etkinliğe göre ayarla (`?remote_city=gaziantep` vb.).

## T-10 dakika: Yerel Jüriyi Isıt

Soğuk modelin ilk kararı 15 s'yi geçer ve paketlenmiş cevaba düşer, bu yüzden model sahneden önce belleğe yüklenir.

1. Başka bir şey Ollama'yı kullanmıyor olmalı (açık bir eval her isteği kuyruğa sokar). Sadece `LISTEN` satırı görünmeli:
   ```bash
   lsof -nP -iTCP:11434
   ```
2. Modeli konuşma boyunca bellekte tut (varsayılan 5 dk; iki demo arası bunu aşabilir). Sahne günü bir kez:
   ```bash
   launchctl setenv OLLAMA_KEEP_ALIVE 30m
   ```
   ```bash
   brew services restart ollama
   ```
3. Modeli yükle ve ısıt:
   ```bash
   curl -s http://localhost:11434/api/generate -d '{"model":"gemma4:12b-it-qat","prompt":"merhaba","think":false,"stream":false}' > /dev/null
   ```
   ```bash
   ollama ps
   ```
   `ollama ps` modeli `UNTIL` sütununda yaklaşık 30 dakika ile göstermeli.
4. Oyunda bir tepsi gönder, kararın `localGemma`'dan geldiğini gör.
5. Wi-Fi'ı kapat. Gemini çağrısı düşer, karar yerel Gemma'dan gelmeye devam eder.

Etkinlikten sonra varsayılana dön: `launchctl unsetenv OLLAMA_KEEP_ALIVE`, ardından `brew services restart ollama`.

## Sahnede: 5 Perdelik Akış

| Perde | Slaytlar | 80 dk atölye | 45 dk İngilizce akış ([akış kartı](berlin-45-en.md); Berlin'de sadece opsiyonel lounge demosu) | 30 dk ana salon |
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
| Wi-Fi tamamen koptu | Slayt 16 (`/demo-hiccup`), "tam da bunun için tasarladık" | `flutter run -d chrome --dart-define=DEFAULT_CITY=gaziantep --dart-define=OFFLINE_MODE=true --dart-define=LOCAL_JUDGE_URL=http://localhost:11434/api/chat` (karar Gemma'dan, o da yoksa paketten) |
| Yerel jüri yavaş veya `localGemma` gelmiyor | Paketlenmiş cevaplar devrede, oyun durmaz | `lsof -nP -iTCP:11434` ile Ollama'yı tutan süreci bul, `ollama ps` ile model yüklü mü bak, T-10 adım 3'ü tekrarla |
| HTTP 429 | Slayt 9'a atıf, uygulama zaten çevrimdışı jüriye düştü | Eylem gerekmez |
| Deck çöktü veya laptop dondu | PDF yedeğine geç | `build/slides/backyard_barista_deck.pdf` |
| AI Studio yavaş | Lane A referans oyununu aç (`49.5 KB`, 3 yuvalı tepsi + 3 müşteri kuyruğu) | `ai_studio_lane_a/index.html` |
| Katılımcı geride kaldı | Bir sonraki kontrol noktasına atla, eski turu bitirmeye çalışma | `prompts/step-N-*.md` veya `git checkout step-N` (veya `Tur 2 Özel Menü: ON`) |
| Lane B deploy fatura istiyor | Bugün için Lane A deploy'una yönlendir | AI Studio'da "Publish" |

## Sonrası

- Kazanan `.run.app` linklerini topla, etkinlik sonrası paylaşım için not al.
- Sahnede kendi anahtarını kullandıysan AI Studio'da anahtarı döndür (yenisini oluştur, eskisini sil).
