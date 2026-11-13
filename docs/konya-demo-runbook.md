# Konya akış kartı: 30 dakika, Türkçe

DevFest Konya, Cumartesi 21 Kasım 2026, 14:30 (İstanbul saati, Berlin'de 12:30), ana salon, Selçuk Üniversitesi Sultan Alparslan Kültür Merkezi. Konuşma: "Backyard Barista on Cloud Run: AI Studio, Antigravity ve Flutter ile Çok Oyunculu AI Kafe Oyunu Yap ve Canlıya Al", 30 dakika.

Bu kart bir taslak: 13-14 Kasım gecesi Esra uyurken hazırlandı. İçindeki hiçbir karar Esra tarafından verilmedi; "Esra'dan önce" bölümündeki maddeler onun.

Kaynaklar, yazıldığı gece okunduğu haliyle:

- Tarih, salon, saat dilimi: [etkinlik sayfası](https://gdg.community.dev/events/details/google-gdg-cloud-konya-presents-devfest-konya26/) (`startDate` 2026-11-21T09:30:00+03:00, salon "Sultan Alparslan Kültür Merkezi"). Sayfanın ajandası boş, Esra konuşmacı listesinde.
- Başlık, 30 dk, 14:30 slotu, 850 kişilik ana salon: `.agents/esra-ops/references/facts.md` satır 292-295 (kaynağı Gmail "DevFest Konya 2026 | CFP Başvuru Sonucu" ve Safa'nın 12 Kas e-postası). Etkinlik sayfasında slot yok.
- Q&A süresi hiçbir kaynakta yok: doğrulanmadı. Bu kart 30 dakikanın tamamını konuşma sayar.

Konuşmacı notları destede Gaziantep'in 80 dakikalık Türkçe metni olarak kalıyor. Konya'da bu kartı kullan: aynı slaytlar, 30 dakikalık saat. Stage Navigator (deste menüsü) her bölüme atlar.

---

## Akış

Perde süreleri `docs/stage-runbook.md` satır 100-106'daki "30 dk ana salon" sütunundan: Hook 3, Tools 4, Gerçek Rakamlar 5, Under the Hood 4, Build & Ship 14 dakika.

| Saat | Slayt | Ne yap | Salon ne yapar |
|---|---|---|---|
| 00:00 | 1 `/title` | Tanıtım, GDE cümlesi | |
| 01:00 | 2 `/sweet-or-salty` | Oylama: A için el, B için el. Cevap: **A şeker, B tuz** (`stage-runbook.md` satır 67) | El kaldırır |
| (atla) | 3 `/workshop-contract` | Konuşmada kimse birlikte kurmuyor; Berlin kartı da atlıyor (`berlin-45-en.md` satır 13) | |
| 03:00 | 4 `/ai-studio-pipeline` | | |
| 04:30 | 5 `/meet-antigravity` | Agent Mode'un çok dosyalı değişikliğini anlat, demoda göreceklerini söyle | |
| 05:45 | 6 `/pure-flutter-widgets` | | |
| 07:00 | 7 `/real-numbers-latency` | | |
| 08:45 | 8 `/real-numbers-cost` | | |
| 10:30 | 9 `/room-quota-trap` | | |
| 12:00 | 10 `/multi-city-remote-config` | "Bugün beşinci şehir Konya, birazdan ekranda" | |
| 13:15 | 11 `/salt-sugar-mechanic` | | |
| 14:30 | 17 `/generate-vs-decide` (Stage Navigator) | Yedek slayt, 60 sn: üretmek mi, karar vermek mi | |
| 15:30 | 13 `/live-build-dashboard` | QR'ı göster, "telefonunuzdan oynayın" | QR ile canlı oyunu açar (Lane C) |
| 16:00 | **Canlı demo, adım 1** | Canlı Cloud Run sekmesi: tatlı tepsi, sonra tuzlu tepsi | Telefonda tepsiye tuz atar |
| 19:00 | **Canlı demo, adım 2** | Konya Edition (aşağıda) | İzler, oynamaya devam eder |
| 24:00 | **Canlı demo, adım 3** | Wi-Fi kapalı, aynı tepsiyi yine gönder | |
| 26:00 | 14 `/architecture-recap` | Dört katman | |
| 28:00 | 15 `/winner-podium-closing` | Podyum yok: QR'ı ve repoyu göster | |
| 29:30 | Bitiş | | |

Slayt 12 (`/hybrid-asset-pipeline`) bu akışta yok; Berlin kartı da geç kalınca ilk onu atlıyor (`berlin-45-en.md` satır 23). Geç kalırsan sırayla şunları kes: önce slayt 17'yi, sonra demo adım 3'ü (Wi-Fi kapalı turu), sonra slayt 6'yı.

Slayt 13'teki ikinci QR canlı oyunu açar: `https://backyard-barista-389486729482.europe-west3.run.app` (`slides/assets/images/backyard_barista_cloudrun_qr.png`, bu gece `zbarimg` ile okundu). Diğer QR GitHub reposunu açar.

### Demo adım 1 (3 dk): canlı oyun, Gemini jürisi

1. Canlı Cloud Run sekmesi (`europe-west3`). Gemini'ı sadece bu adreste göster: `europe-west1` aynasında anahtar yok (`stage-runbook.md` satır 47).
2. Tatlı tepsi: 5 yıldız. Tuzlu tepsi: 1 yıldız. Kartın altındaki rozet hangi jürinin cevap verdiğini söyler (`berlin-45-en.md` satır 22).
3. Canlı adres bugün Konya'yı bilmiyor. `?remote_city=konya` canlı build'de Gaziantep'e düşer (`city_edition_controller.dart`, `CityEditionId.fromCode` bilinmeyen kodu `gaziantep` yapar). Konya canlı adreste ancak bu dal merge edilip deploy edilince görünür; o karar Esra'nın (aşağıda).

### Demo adım 2 (5 dk): Konya Edition

Burada şehir Konya'ya döner. Bu adımda canlı ağa bağımlı tek şey Antigravity'nin modeli; geri kalanı laptopta.

**2a. Antigravity Agent Mode ile tek prompt (2 dk).** Deste bu yeteneği zaten anlatıyor (`s_meet_antigravity_slide.dart` satır 15 ve 71). Prompt, `main` dalının bir kopyasında yazılır (Konya olmayan durum):

```text
flutter_client içine yeni bir şehir ekle: konya. Diğer dört şehir nasıl tanımlıysa aynı dosyalarda aynı alanlarla tanımla: CityEditionId, city_editions.json, mock_responses.json, CustomerOrderTicket.ticketsForCity, BaristaFlameGame şehir rengi, remote_config_template.json. Yeni yemek, şaka ya da kişi uydurma, mevcut menüden seç. Sonra flutter_client içinde flutter analyze ve flutter test çalıştır.
```

Ajan çalışırken bekleme: "Bunu dün gece ben de yaptım, sonucu hazır" de ve 2b'ye geç. Ajanın çıktısı sahnede öngörülemez; sonucu sahnede merge etme.

**2b. Hazır dal (1 dk).** Terminalde, bu reponun `feat/konya-edition-demo` dalında:

```bash
git diff --stat 71a3ed4 adfcb45
```

11 dosya görünür, ikisi test dosyası. `flutter_client` testleri bu gece geçti (32 test, `fvm flutter test`).

**2c. Konya ekranda (2 dk).** Sahneden önce açılmış yerel sekme (komut aşağıda, "Sabah"). Bayrak rozetine tıkla: Ayarlar çekmecesinde beşinci seçenek Konya. Konya'ya geç, başlıkta "DevFest Konya 2026 Edition" görünür. Bir tuzlu tepsi gönder: karar yerel Gemma'dan gelir, gelmezse paketten "Konya: Tepside Tuz Var!".

### Demo adım 3 (2 dk): Wi-Fi kapalı

Wi-Fi'ı kapat, aynı Konya sekmesinde tepsiyi yeniden gönder. Karar yerel Gemma'dan gelir; o da yetişmezse paketlenmiş cevaplardan (`stage-runbook.md` satır 94, README satır 54-59).

### Slayt 17: üretmek mi, karar vermek mi (60 sn)

Yedek slayt, ana sıranın numaralarını bozmasın diye destenin sonunda (17. slayt). Slayt 11'in notunda Konya için bir NEWS satırı ona yönlendiriyor. Söylenecek metin slaytın konuşmacı notunda (SAY satırı).

Slayttaki her bilgi [Decisions API sayfasından](https://aistudio.google.com/docs/decisions-api.md) (13 Kas gecesi okundu): model `gemini-decision-1`; soru tipleri `noul`, `choice`, `score`; istek başına 1 ile 1.000 soru; çıktı tokenı her zaman 0, yalnız girdi faturalanır; SDK sekmeleri Python ve JavaScript (3.2 ve sonrası) ile REST; yalnız `v1beta`. Dart SDK'sı yok, çağrı REST. Decisions API oyuna bağlı değil: yeni ağ çağrısı yok, anahtar yok.

---

## Antigravity Orchestrator olmadan

Teklif (`devfest-talk-updates.md`, K1) adım 2'yi Antigravity Orchestrator ile yapmayı öneriyordu. Orchestrator'ın Esra'nın hesabında açık olup olmadığını kimse kontrol etmedi; ikincil kaynaklar AI Ultra planı diyor (`README.md`, doğrulama tablosu). Bu yüzden yukarıdaki akış Orchestrator'a hiç dayanmıyor:

- 2a Agent Mode ile yapılır (deste zaten anlatıyor). Esra 19 Kasım'dan önce Orchestrator'ın açık olduğunu görürse yalnız 2a'yı değiştirir; süre aynı kalır.
- Antigravity hiç çalışmazsa 2a'yı atla, 2b ve 2c yeterli: dal, diff ve testler, Konya ekranda. Bunların hepsi bu gece bu makinede çalıştı.
- Yedek video (Esra kaydedecek) 2a'nın yerine oynatılabilir.

---

## Hazır olan (repoda bugün çalışan)

- Konya şehir modu `feat/konya-edition-demo` dalında, diğer şehirlerle aynı dosyalarda. Metinler nötr: Konya'ya özgü yemek, şaka ya da kişi yok (uydurulmadı). Testler: `?remote_city=konya` Konya'yı seçer, Ayarlar çekmecesi Konya'ya geçer, 429'da Konya'nın paket cevabı gelir.
- Slayt 17 `/generate-vs-decide`, Stage Navigator'da "Konya: Generate vs Decide".
- `fvm flutter analyze` iki pakette temiz, `fvm flutter test`: `flutter_client` 32, `slides` 33 test geçti. `fvm flutter build web --release` (slides) geçti. Slayt 17'nin PNG'si (`tool/export_slides_test.dart`) gözle kontrol edildi: taşma yok.
- `dart run tool/rehearsal_3g_check.dart`: Test 3, 4 ve 5 (15/15 şehir x karar) geçti. Test 2 bu dalla ilgisiz bir nedenle kaldı: 20 PNG'den 6'sı (`characters/*.png`) repoda yok, araç onları hâlâ arıyor.
- Canlı adres `europe-west3` 14 Kas 00:00 civarında HTTP 200 döndü.

## Esra'dan önce, 19 Kasım'a kadar (en acil olan üstte)

1. Bu dalı (taslak PR) gözden geçir; Konya'nın canlı adreste görünmesi için merge ve deploy gerekir. Merge ve deploy senin kararın; ikisi de bu gece yapılmadı. Deploy olmazsa salon telefonlarda Gaziantep görür, Konya yalnız laptopta görünür.
2. Canlı adreste salonun hangi şehri göreceğine karar ver. İstemcide Firebase Remote Config SDK'sı yok (`flutter_client/pubspec.yaml`'da `firebase` paketi yok): 2. öncelik aslında build sırasındaki `DEFAULT_CITY` (`Dockerfile` satır 7 ve 13) veya URL'deki `?remote_city=`. Seçenekler: deploy'u `DEFAULT_CITY=konya` ile yapmak ya da QR'ı `?remote_city=konya` ekli bir adrese çevirmek. Remote Config konsolunda değiştirilecek bir şey yok.
3. Antigravity Orchestrator hesabında ve planında açık mı, bak. Açık değilse akış zaten Agent Mode ile kurulu.
4. Demo adım 2a'nın yedek videosunu kaydet ve laptopa koy (yerel dosya, ağ gerekmez).
5. Konya'ya özgü metin istiyorsan (alt başlık, imza ürün, şakalar, müşteriler) kendin yaz: bu gece bilerek nötr bırakıldı.
6. Slayt 17'yi konuşmaya alıp almamaya karar ver; almazsan slayt 11'in NEWS satırı yok sayılır, başka bir şey değişmez.
7. Q&A süresini organizatörden öğren (kaynaklarda yok). 10 dk Q&A ayrıysa akış aynı kalır; 30 dk içindeyse "geç kalırsan kes" sırasını baştan uygula.
8. Remote Config şablonuna `devfest_konya_2026` koşulu eklendi; şablonu konsola yüklersen bu koşul konsolda tanımlı olmalı. Diğer dört koşulun konsolda var olup olmadığı doğrulanmadı.

## Sahnede söyleme

- Antigravity Orchestrator için "%24 daha az kota", "%19 daha hızlı": yalnız ikincil kaynakta var (`README.md`, doğrulama tablosu).
- Decisions API gecikmesi ("150-250 ms", "~200 ms"): resmi sayfada rakam yok.
- Decisions API fiyatı slaytta yok. Sorulursa yalnız resmi fiyat sayfasındaki şu: ücretsiz katmanda girdi ücretsiz, ücretli katmanda 1M girdi tokenı $0.10, çıktı yok ([fiyat sayfası](https://aistudio.google.com/docs/pricing.md), "Gemini Decision 1" bölümü, 13 Kas gecesi okundu).
- "Salondaki telefonlarda Wasm deniyoruz": repo Flutter 3.44.9'a sabit (`.github/workflows/ci.yml`), Wasm denenmedi.
- Gemini 4 Hydrogen için "2,5 kat hızlı"; DX'in "%62" ve "%122" rakamları; MCPHallu "%23,2" (`README.md`, "Konuşma önerilerine etkisi").
- Teklif K2'deki "Yıldız = decide, ~150-250 ms, çıktı ücretsiz" satırı: gecikme kaynaksız, "ücretsiz" yerine "çıktı tokenı 0" de.

---

## Kontrol listesi

Komutlar `docs/stage-runbook.md`'den (Flutter komutlarını bu makinede `fvm flutter ...` olarak çalıştır; CI 3.44.9 kullanıyor, `fvm` global sürümü de 3.44.9).

### Önceki akşam (Cuma 20 Kasım, otelde)

1. Deste testleri (`stage-runbook.md` satır 18-22):

   ```bash
   cd slides
   fvm flutter analyze && fvm flutter test
   ```

2. PDF yedeği (satır 24-28), USB'ye ve telefona kopyala:

   ```bash
   cd slides
   fvm flutter test tool/export_slides_test.dart
   ```

   ```bash
   cd slides
   python3 tool/pngs_to_pdf.py
   ```

3. Uygulama testleri (satır 30-34; oradaki `dart run tool/rehearsal_3g_check.dart` bugün Test 2'de kalıyor, nedeni "Hazır olan" bölümünde):

   ```bash
   cd flutter_client
   fvm flutter analyze && fvm flutter test
   ```

4. Canlı adres `200` dönmeli (satır 43-46):

   ```bash
   curl -s -o /dev/null -w '%{http_code}\n' https://backyard-barista-389486729482.europe-west3.run.app
   ```

5. Gemini proxy'si cevap veriyor mu: canlı adreste bir tepsi gönder, kartın altındaki rozet canlı Gemini'ı göstermeli. (Repoda proxy için ayrı bir `curl` komutu yok; bu kontrol bir Gemini çağrısı yapar.)
6. Yerel Gemma modeli indirili mi (satır 48): `ollama list` içinde `gemma4:12b-it-qat`. Yoksa otel Wi-Fi'ında değil, Bozüyük'te hızlı ağda indir.
7. Yedek video laptopta, ağ olmadan açılıyor mu.

### Sabah ve T-10 dakika (Cumartesi 21 Kasım)

1. Yerel jüriyi ısıt (`stage-runbook.md` satır 70-94): `OLLAMA_KEEP_ALIVE 30m`, model yükle, `ollama ps`.
2. Konya sekmesini bu dalın `flutter_client` klasöründe aç. `stage-runbook.md` satır 51'deki komut, şehir Konya olarak:

   ```bash
   fvm flutter run -d chrome --dart-define=DEFAULT_CITY=konya --dart-define=OFFLINE_MODE=true --dart-define=LOCAL_JUDGE_URL=http://localhost:11434/api/chat
   ```

   Gemini anahtarı yok, gerekmez: karar yerel Gemma'dan, o da yoksa paketten gelir. Kendi anahtarını yalnız yerelde kullan, asla deploy etme (satır 61).
3. Çevrimdışı yedek çalışıyor mu: Wi-Fi'ı kapat, Konya sekmesinde tuzlu tepsi gönder, 1 yıldız gelsin. Wi-Fi'ı aç.
4. Açık sekmeler: deste, canlı oyun (`europe-west3`), Konya sekmesi, terminal (`feat/konya-edition-demo`, demo adım 2b), Antigravity (`main` kopyası, adım 2a), PDF yedeği, yedek video.
5. Stage Navigator'ı aç, zamanlayıcıyı sıfırla (satır 66). Telefon hotspot'u hazır (satır 60).

### Bir şey bozulursa

`stage-runbook.md` satır 110-120'deki tablo geçerli. Konya'ya özel olanlar:

| Belirti | Sahnede |
|---|---|
| Antigravity yavaş ya da hata veriyor | 2a'yı bırak, 2b'ye geç ("sonucu dün gece aldım") |
| Konya sekmesi açılmıyor | Canlı adreste kal, Konya'yı 2b'deki diff ve testlerle anlat |
| Wi-Fi tamamen koptu | Slayt 16 (`/demo-hiccup`), sonra Konya sekmesi zaten çevrimdışı çalışıyor |
| Deste dondu | PDF yedeği |
