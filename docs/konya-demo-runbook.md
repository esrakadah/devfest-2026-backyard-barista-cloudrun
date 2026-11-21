# DevFest Konya 2026 Akış Kartı: 30 Dakika, Türkçe Ana Salon

- **Tarih ve Saat:** Cumartesi 21 Kasım 2026, **14:30 - 15:00 TR** (Berlin 12:30 - 13:00)
- **Mekân ve Salon:** Selçuk Üniversitesi Sultan Alparslan Kültür Merkezi, **850 kişilik ana salon** (yalnızca HDMI çıkışı: kendi adaptörünü götür, önceki arada test et)
- **Başlık:** *Backyard Barista on Cloud Run: AI Studio, Antigravity ve Flutter ile Çok Oyunculu AI Kafe Oyunu Yap ve Canlıya Al*
- **Format:** 30 dakika tek parça konuşma; salon oyunu konuşmanın 2. dakikasında oynar. Ayrı soru-cevap süresi yok (sorular fuayede).
- **Deste:** Türkçe konuşma destesi, 24 ana + 2 yedek slayt: tanışma ve günün haritası, salon oyunu, beş kural, canlı skor tablosu ve podyum. Mod: `--dart-define=DECK_LANG=tr --dart-define=DECK_THEME=konya`. `DECK_THEME=candle` ve temasız (GDE lacivert) sürümler aynı slaytları açar. 5 Aralık İzmir için `--dart-define=DECK_LANG=tr --dart-define=DECK_CITY=izmir`.
- **İngilizce atölye destesi** (`DECK_LANG` verilmeden) eski 16 slaytlık sırasıyla duruyor; bu kart onu anlatmaz.

Bu sürüm 20 Kasım 2026'da yazıldı (PR 24 - 28). Önceki akış (16 slayt, 10 dakikalık üç adımlı demo) git geçmişinde: `git show 408f1c6:docs/konya-demo-runbook.md`.

---

## 1. Saat Tablosu (plan 29:00'da biter, 1:00 pay)

| Kronometre | Slaytlar | Bölüm | Süre |
|---|---|---|---|
| `00:00 - 02:45` | 1, 2, 3, 4 | **Davet:** selam (30 sn); "Merhaba, ben Esra": fotoğraflar, topluluklar, kitap (45 sn); günün haritası ve "beş hata buldum" (45 sn); şeker-tuz oylaması (45 sn) | 2 dk 45 sn |
| `02:45 - 09:00` | 5, 6, 7, 8, 9 | **Oyun:** üç adımda oyun (30 sn); konuşmacının iki tepsisi (75 sn), sonra salon (QR, kullanıcı adı, 2,5 dk); skor tablosu donar (30 sn); dört araç; beş kural, beş kelime | 6 dk 15 sn |
| `09:00 - 15:30` | 10 - 14 | **Modelin cevabı:** Kural 1 (guard), Kural 2 (enum, boş cevap) | 6 dk 30 sn |
| `15:30 - 25:15` | 15 - 21 | **Uygulamanın kendisi:** Kural 3 (sealed class), Kural 4 (timeout), Kural 5 (proxy, maliyet) | 9 dk 45 sn |
| `25:15 - 29:00` | 22, 23, 24 | **Kapanış:** iki sütunlu özet, "tuzu kim yakalayacak?"; podyum (üç tık, üç ödül, 1 dk 30 sn); teşekkür | 3 dk 45 sn |

Saat damgaları slayt notlarındaki `BEAT` satırlarında durur; `slides/test/deck_manifest_test.dart` damgaların 00:00'dan aralıksız ilerlediğini ve 30 dakikayı aşmadığını kontrol eder.

**Geç kalırsan (telefondaki kronometreye göre):**

| Kronometre | Durum | Ne kesilir |
|---|---|---|
| `13:45` | Slayt 13 açılmadı | Slayt 13 atlanır. 12'den köprü: "Liste tamam. Peki cevap gelir ama içi boş olursa?" |
| `21:45` | Slayt 19 açılmadı | Slayt 19: yalnızca iki el oylaması ve eve götürülecek cümle, kod yok. |
| `25:00` | Slayt 21 açılmadı | Slayt 21 tek cümle: "En ucuz çağrı, hiç yapmadığınız çağrı: tepsiyi dizerken sıfır, serviste bir. Bir tepsi 322 token; ölçtüm." |
| `26:45` | Nerede olursan ol | Stage Navigator'dan "22. Özet". Slayt 22, 23 (podyum, söz verilen ödüller) ve 24 asla atlanmaz. |

## 2. Salon Oyunu ve Skor Tablosu (Slayt 5, 6 ve 7 · 02:45 - 07:30)

1. Slayt 5'ten ("Üç adımda bir tepsi") sonra canlı Cloud Run sekmesine geç; 6. slaytı henüz açma. Bir tatlı tepsi (5 yıldız), sonra bir tuzlu tepsi (1 yıldız). Rozette "Canlı Gemini" yazmıyorsa: "Bu kez hazır yanıt geldi; nedenini birazdan anlatacağım."
2. "Sıra sizde" derken 6. slaytı aç. Önce tam ekran QR sekmesi 30 saniye, sonra slayta dön. Okutamayan yanındakinin telefonundan oynasın.
3. Üç görev: tatlı siparişe gizlice tuz at; kartın altındaki jüri rozetini oku; hızlıysan Servis Et'e ve hemen Sıradaki Müşteri'ye bas.
4. `05:00`: "Açabilenler el kaldırsın." Yarıdan azsa "Yanınızdakinin ekranına bakın" de ve `06:00`'da bitir.
5. `06:45`: "Son on beş saniye."
6. `07:00`: 7. slaytı aç ("Kim önde?"). Tablo canlıdır; "Süre doldu" derken ileri tuşuna bir kez bas, başlık "SÜRE DOLDU" olur ve tablo donar. Sonra: "Telefonları kilitleyip cebinize koyun." Ödüller kapanışta, 23. slaytta: her tık bir basamağı açar (üçüncü, ikinci, birinci).

**Skor tablosu nasıl çalışır:** oyun açılınca kullanıcı adı sorar ("İsimsiz oyna" tabloya yazmaz). İlk servis edilen tepsiden sonra oyuncunun 3 dakikası vardır; puan iki rozetin toplamıdır (doğru tepsi 100, şaka ya da eksik tepsi 30) ve her turdan sonra Firestore'a yazılır (`events/<etkinlik>/players`, proje `devfest-backyard-barista-2026`). Yazma arka planda gider; düşerse oyun aynen çalışır, deste son gördüğü tabloyu gösterir. Kurallar `firestore/firestore.rules` dosyasında.

**Prova:** oyunu ve desteyi `board=prova` ile aç; sahne tablosu (`konya-2026`) temiz kalır.
- Oyun: `https://backyard-barista-389486729482.europe-west3.run.app/?remote_city=konya&board=prova`
- Deste: `http://127.0.0.1:8106/?board=prova#/hall-leaderboard`

**Sıfırlama** (provadan sonra ya da tablo garipleşirse; kaç oyuncu silineceğini gösterir, etkinlik adını yazmadan silmez):
```bash
python3 tool/reset_leaderboard.py prova
```
```bash
python3 tool/reset_leaderboard.py konya-2026
```
Hâlâ oynayan telefonlar bir sonraki tepside sıfırlandığını fark eder ve yeni 3 dakikaya başlar; süresi dolmuş oyuncu sayfayı yeniler.

**Bilinen sınırlar:** kullanıcı adı serbest metindir; kısa bir kelime listesi uygunsuz adı `***` yapar, gerisi için sahneye çağırmadan önce adı kendin oku. Puanı tarayıcı gönderir; kurallar tur başına en çok 100 puana ve 3 saniyede bir tura izin verir, yani meraklı bir geliştirici bu sınır kadar hile yapabilir. Sayfayı yenileyen oyuncu aynı satıra yazar ve yerelde sıfırdan sayar: tablodaki puanını geçene kadar tablo değişmez.

Canlı adres: `https://backyard-barista-389486729482.europe-west3.run.app/?remote_city=konya` (Cloud Run servisi `backyard-barista`, proje `devfest-backyard-barista-2026`, bölge `europe-west3`).

**Sorun olursa:** oyun konuşmacıda açılmazsa Stage Navigator'dan "Demo aksadı" slaytı; süre kalırsa ya da sorulursa "Yedek: Wi-Fi kapalı, Gemma" slaytı (yalnızca yerel sekme ve Ollama hazırsa).

## 3. Konuşmadaki Dört Salon Sorusu

| Slayt | Soru | Sessizlik ya da beklenmeyen cevap |
|---|---|---|
| 10 | "Kim tuz attı? Kaç yıldız aldınız? Peki o yıldızı kim verdi?" | El kalkmazsa: "Ben attım, gördünüz: bir yıldız." |
| 15 | "Kim Servis Et'e basıp hemen Sıradaki Müşteri'ye bastı?" | "Normal, cevap sizden hızlıydı." Bekleme, devam et. |
| 19 | "Rozetinde Canlı Gemini yazanlar? Yerel JSON Şeması yazanlar?" | İlk grup boşsa: "Demek hepiniz C planına düştünüz; oyun yine de cevap verdi." İkinci grup boşsa: "Bugün sınıra takılmadık." |
| 22 | "Tuzu kim yakalayacak, yapay zeka mı, kod mu?" | 3 saniye bekle; sessizlikse: "Cevap: kod." |

## 4. Sahne Öncesi (T-30 dk)

1. Şarj aleti, HDMI adaptörü; laptop telefonun hotspot'unda.
2. Ekranı genişlet: slaytlar projektörde, Presenter View laptopta. Rahatsız Etme açık.
3. Çevrimdışı deste (repo kökünden derle, sonra herhangi bir statik sunucuyla aç):
```bash
cd slides && flutter build web --release --no-web-resources-cdn --base-href / --dart-define=DECK_LANG=tr --dart-define=DECK_THEME=konya
```
```bash
python3 -m http.server 8106 --bind 127.0.0.1 --directory slides/build/web
```
4. Canlı Cloud Run sekmesinde bir tatlı tepsi servis et, rozeti oku, sekmenin sesini kapat. Bir kez de Servis Et ve hemen Sıradaki Müşteri: boş tepside kart çıkmamalı.
5. Arada salonun arkasından hem 6. slayttaki hem tam ekran sayfadaki QR kodu okut.
6. Sahne tablosunu boşalt (`python3 tool/reset_leaderboard.py konya-2026`), telefonundan bir tepsi servis et ve 7. slaytta adının göründüğünü gör; sonra tabloyu yeniden boşalt.
7. Telefonda kronometre; "Merhaba" derken başlat.
8. Yedekler: PDF (`python3 tool/pngs_to_pdf.py`, önce `flutter test tool/export_slides_test.dart` aynı iki `--dart-define` ile) ve `speaker_notes.md` (`flutter test tool/export_notes_test.dart --dart-define=DECK_LANG=tr`).

## 5. Sahnede Söylenmeyecekler (Doğrulanmış Sınırlar)

- "Model hiç yanılmıyor" deme: koruyucu, yanıldığı durum için var.
- 8 sn, 15 sn ve 250 ms sınırdır, ölçüm değil. Ölçümler: Gemini 1,0 ile 1,8 sn, yerel Gemma 5,0 ile 8,4 sn (12 tepsi, 11 Kasım 2026).
- 322 token tek bir tepsinin ölçümüdür (20 Kasım 2026, canlı oyun, Konya sürümü); ortalama ya da fiyat olarak sunma.
- Proxy'de kimlik kontrolü yok; hız sınırı sunucu kopyası başına tek kovadır ve harcamayı sınırlar, kötüye kullanımı engellemez. Üretimde yol App Check.
- `cafe_counter_screen.dart` hâlâ 2.670 satır ve 22 sınıf; düzelen durum, dosya değil.
- Yerel Gemma yalnızca sahnedeki laptopta çalışır; salonun telefonları ona ulaşamaz.
