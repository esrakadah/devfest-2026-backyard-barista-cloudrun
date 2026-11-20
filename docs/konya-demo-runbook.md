# DevFest Konya 2026 Akış Kartı: 30 Dakika, Türkçe Ana Salon

- **Tarih ve Saat:** Cumartesi 21 Kasım 2026, **14:30 - 15:00 TR** (Berlin 12:30 - 13:00)
- **Mekân ve Salon:** Selçuk Üniversitesi Sultan Alparslan Kültür Merkezi, **850 kişilik ana salon** (yalnızca HDMI çıkışı: kendi adaptörünü götür, önceki arada test et)
- **Başlık:** *Backyard Barista on Cloud Run: AI Studio, Antigravity ve Flutter ile Çok Oyunculu AI Kafe Oyunu Yap ve Canlıya Al*
- **Format:** 30 dakika tek parça konuşma; salon oyunu konuşmanın 2. dakikasında oynar. Ayrı soru-cevap süresi yok (sorular fuayede).
- **Deste:** Türkçe konuşma destesi, 19 ana + 2 yedek slayt, beş kural. Mod: `--dart-define=DECK_LANG=tr --dart-define=DECK_THEME=konya`. `DECK_THEME=candle` ve temasız (GDE lacivert) sürümler aynı slaytları açar. 5 Aralık İzmir için `--dart-define=DECK_LANG=tr --dart-define=DECK_CITY=izmir`.
- **İngilizce atölye destesi** (`DECK_LANG` verilmeden) eski 16 slaytlık sırasıyla duruyor; bu kart onu anlatmaz.

Bu sürüm 20 Kasım 2026'da yazıldı (PR 24 - 28). Önceki akış (16 slayt, 10 dakikalık üç adımlı demo) git geçmişinde: `git show 408f1c6:docs/konya-demo-runbook.md`.

---

## 1. Saat Tablosu (plan 26:30'da biter, 3:30 pay)

| Kronometre | Slaytlar | Bölüm | Süre |
|---|---|---|---|
| `00:00 - 02:00` | 1, 2 | **Davet:** tanışma, "beş hata buldum", şeker-tuz oylaması | 2 dk |
| `02:00 - 07:45` | 3, 4, 5 | **Oyun:** önce konuşmacının iki tepsisi, sonra salon (QR, 2,5 dk); dört araç; beş kural, beş kelime | 5 dk 45 sn |
| `07:45 - 14:15` | 6 - 10 | **Modelin cevabı:** Kural 1 (guard), Kural 2 (enum, boş cevap) | 6 dk 30 sn |
| `14:15 - 24:00` | 11 - 17 | **Uygulamanın kendisi:** Kural 3 (sealed class), Kural 4 (timeout), Kural 5 (proxy, maliyet) | 9 dk 45 sn |
| `24:00 - 26:30` | 18, 19 | **Kapanış:** iki sütunlu özet, "tuzu kim yakalayacak?", teşekkür | 2 dk 30 sn |

Saat damgaları slayt notlarındaki `BEAT` satırlarında durur; `slides/test/deck_manifest_test.dart` damgaların 00:00'dan aralıksız ilerlediğini ve 30 dakikayı aşmadığını kontrol eder.

**Geç kalırsan (telefondaki kronometreye göre):**

| Kronometre | Durum | Ne kesilir |
|---|---|---|
| `12:30` | Slayt 9 açılmadı | Slayt 9 atlanır. 8'den köprü: "Liste tamam. Peki cevap gelir ama içi boş olursa?" |
| `20:30` | Slayt 15 açılmadı | Slayt 15: yalnızca iki el oylaması ve eve götürülecek cümle, kod yok. |
| `23:45` | Slayt 17 açılmadı | Slayt 17 tek cümle: "En ucuz çağrı, hiç yapmadığınız çağrı: tepsiyi dizerken sıfır, serviste bir. Bir tepsi 322 token; ölçtüm." |
| `26:00` | Nerede olursan ol | Stage Navigator'dan "18. Özet". Slayt 18 ve 19 asla atlanmaz. |

## 2. Salon Oyunu (Slayt 3 · 02:00 - 06:00)

1. Slayt 2'den sonra canlı Cloud Run sekmesine geç; 3. slaytı henüz açma. Bir tatlı tepsi (5 yıldız), sonra bir tuzlu tepsi (1 yıldız). Rozette "Canlı Gemini" yazmıyorsa: "Bu kez hazır yanıt geldi; nedenini birazdan anlatacağım."
2. "Sıra sizde" derken 3. slaytı aç. Önce tam ekran QR sekmesi 30 saniye, sonra slayta dön. Okutamayan yanındakinin telefonundan oynasın.
3. Üç görev: tatlı siparişe gizlice tuz at; kartın altındaki jüri rozetini oku; hızlıysan Servis Et'e ve hemen Sıradaki Müşteri'ye bas.
4. `04:00`: "Açabilenler el kaldırsın." Yarıdan azsa "Yanınızdakinin ekranına bakın" de ve `05:00`'te bitir.
5. `05:45`: "Son on beş saniye." Sonra: "Telefonları kilitleyip cebinize koyun."

Canlı adres: `https://backyard-barista-389486729482.europe-west3.run.app/?remote_city=konya` (Cloud Run servisi `backyard-barista`, proje `devfest-backyard-barista-2026`, bölge `europe-west3`).

**Sorun olursa:** oyun konuşmacıda açılmazsa Stage Navigator'dan "Demo aksadı" slaytı; süre kalırsa ya da sorulursa "Yedek: Wi-Fi kapalı, Gemma" slaytı (yalnızca yerel sekme ve Ollama hazırsa).

## 3. Konuşmadaki Dört Salon Sorusu

| Slayt | Soru | Sessizlik ya da beklenmeyen cevap |
|---|---|---|
| 6 | "Kim tuz attı? Kaç yıldız aldınız? Peki o yıldızı kim verdi?" | El kalkmazsa: "Ben attım, gördünüz: bir yıldız." |
| 11 | "Kim Servis Et'e basıp hemen Sıradaki Müşteri'ye bastı?" | "Normal, cevap sizden hızlıydı." Bekleme, devam et. |
| 15 | "Rozetinde Canlı Gemini yazanlar? Yerel JSON Şeması yazanlar?" | İlk grup boşsa: "Demek hepiniz C planına düştünüz; oyun yine de cevap verdi." İkinci grup boşsa: "Bugün sınıra takılmadık." |
| 18 | "Tuzu kim yakalayacak, yapay zeka mı, kod mu?" | 3 saniye bekle; sessizlikse: "Cevap: kod." |

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
5. Arada salonun arkasından hem 3. slayttaki hem tam ekran sayfadaki QR kodu okut.
6. Telefonda kronometre; "Merhaba" derken başlat.
7. Yedekler: PDF (`python3 tool/pngs_to_pdf.py`, önce `flutter test tool/export_slides_test.dart` aynı iki `--dart-define` ile) ve `speaker_notes.md` (`flutter test tool/export_notes_test.dart --dart-define=DECK_LANG=tr`).

## 5. Sahnede Söylenmeyecekler (Doğrulanmış Sınırlar)

- "Model hiç yanılmıyor" deme: koruyucu, yanıldığı durum için var.
- 8 sn, 15 sn ve 250 ms sınırdır, ölçüm değil. Ölçümler: Gemini 1,0 ile 1,8 sn, yerel Gemma 5,0 ile 8,4 sn (12 tepsi, 11 Kasım 2026).
- 322 token tek bir tepsinin ölçümüdür (20 Kasım 2026, canlı oyun, Konya sürümü); ortalama ya da fiyat olarak sunma.
- Proxy'de kimlik kontrolü yok; hız sınırı sunucu kopyası başına tek kovadır ve harcamayı sınırlar, kötüye kullanımı engellemez. Üretimde yol App Check.
- `cafe_counter_screen.dart` hâlâ 2.670 satır ve 22 sınıf; düzelen durum, dosya değil.
- Yerel Gemma yalnızca sahnedeki laptopta çalışır; salonun telefonları ona ulaşamaz.
