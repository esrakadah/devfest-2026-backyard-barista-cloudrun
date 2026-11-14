import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class ArchitectureRecapSlide extends FlutterDeckSlideWidget {
  const ArchitectureRecapSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/architecture-recap',
            title: isTurkishDeck
                ? '14. Bugün ne kurduk? (mimari özeti)'
                : '14. En Son Mimaride Ne Yaptık? (Architecture Recap)',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [60:00 - 65:00] Ödüllerden önce mimari özeti: bugün ne kurduk?\n'
                    'SAY   "Bugün bir oyun yaptık ama aslında dört katmanlı gerçek bir mimari kurduk. Bir, sahne: Flame ile çizilen 3 şeritli sahne, Flutter tezgah ve NFC ile sahne şakası. İki, ayar: CityEditionController ve Remote Config sayesinde uygulamayı yeniden derlemeden şehir değiştirdik. Üç, AI ve güvenlik ağı: gemini-3.5-flash-lite şemalı JSON döndürüyor, 8 saniyede cevap gelmezse yedek devreye giriyor. Dört, bulut: durum tutmayan bir container\'ı, yani uygulamayı taşıyan hazır paketi, Cloud Run\'da canlı bir .run.app adresine ve GitHub\'a taşıdık. Bu dört katmanı yarın kendi projenizde de kullanabilirsiniz."\n'
                    'HOLD  4 katmanı yukarıdan aşağıya say, her bantta bir nefes al. Sağdaki sonuç sütununu ritim olarak kullan. "60fps" [HEDEF], "1 çağrı ≈ 270 token" [YAKLAŞIK HESAP].\n'
                    'NEWS  [Bu hafta, yalnız sözlü, ödev] "Bizim jüri aslında bir karar veriyor: tatlı mı tuzlu mu, kaç yıldız? Bu hafta duyurulan Gemini Decisions API tam bunu metin üretmeden yapıyor: soruları puanlıyor ve olasılık döndürüyor. Atölyeden sonra deneyebileceğiniz bir ödev. Şimdilik Dart SDK\'sı yok, REST ile çağrılıyor." [Olgu (aistudio.google.com/docs/decisions-api, 11 Kasım 2026): model gemini-decision-1; evet/hayır, seçim ve puan soruları; istek başına en fazla 1.000 soru; 0 çıktı tokenı; SDK: Python, JavaScript, REST. Gecikme ve fiyat söyleme].\n'
                    'NEXT  "Şimdi sahne sizin: linkini yayınlayanları 60 saniyelik demolar için sahneye alıyoruz!"'
                : 'BEAT  [60:00 - 65:00] "En Son Mimaride Ne Yaptık?" (Ödül Töreni Öncesi Tam Mimari Özeti).\n'
                    'SAY   "Ödüllerimizi dağıtmadan önce herkesin ekrana bakmasını istiyorum: bugün eğlenceli bir kafe oyunu yaptık ama aslında arkada dört katmanlı, gerçek bir prodüksiyon bulut mimarisi kurduk! 1. Katmanda BaristaFlameGame 60fps 3-koridorlu sahnemizi, 2x2 Flutter Overlay HUD tezgahımızı ve NfcTagController (NDEFReader, masaüstünde kart dokunuşu) sahne tetikleyicimizi birleştirdik. 2. Katmanda 3 öncelikli CityEditionController ve Firebase Remote Config şablonu ile uygulamamızı yeniden derlemeden farklı DevFest şehirlerine uyarladık. 3. Katmanda gemini-3.5-flash-lite ve yapılandırılmış JSON şeması (CafeReview) ile deterministik bir jüri kurup çevrimdışı yedeklemeyle koruduk. 4. Katmanda ise durumsuz konteynerimizi Google Cloud Run üzerinde canlı bir .run.app adresine ve GitHub\'a taşıdık!"\n'
                    'HOLD  4 katmanı yukarıdan aşağıya, her bant için bir nefes vererek say; sağdaki sonuç sütununu (60fps + Web NFC, 0 yeniden derleme, 1 çağrı, 0 sunucu durumu) ritim olarak kullan.\n'
                    'NEWS  [Bu hafta, yalnız sözlü, ödev] "Bizim jüri aslında bir karar veriyor: tatlı mı tuzlu mu, kaç yıldız? Bu hafta duyurulan Gemini Decisions API tam bunu metin üretmeden yapıyor: soruları puanlıyor ve olasılık döndürüyor. Atölyeden sonra deneyebileceğiniz bir ödev. Şimdilik Dart SDK\'sı yok, REST ile çağrılıyor." [Fact (aistudio.google.com/docs/decisions-api, 11 Nov 2026): model gemini-decision-1, yes/no + choice + score questions, up to 1,000 per request, 0 output tokens; SDKs: Python, JavaScript, REST. Gecikme ve fiyat söyleme].\n'
                    'NEXT  "Şimdi sahne sizin: canlı linkini yayınlayanları 60 saniyelik demoları ve Google piksel gözlük ödülleri için sahneye alıyoruz!"',
          ),
        );

  static const double _gap = 16;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck ? 'BUGÜN NE KURDUK?' : 'EN SON MİMARİDE NE YAPTIK?',
          title: isTurkishDeck
              ? 'Bugün kurduğumuz: 4 katmanlı production mimarisi'
              : 'What We Just Built: A 4-Layer Production Architecture',
          act: StoryAct.buildAndShip,
          subtitle: isTurkishDeck
              ? 'Bugün yayınladığınız her katman gerçek bir Flutter ve Cloud ürününde aynen kullanılır'
              : 'Every layer you shipped today transfers directly to a real Flutter and Cloud product',
          accentColor: DeckColors.halftoneBlue,
          child: Column(
            children: [
              Expanded(
                child: _LayerBand(
                  number: 1,
                  name: isTurkishDeck ? 'SAHNE VE WEB NFC' : 'STAGE & WEB NFC',
                  color: DeckColors.googleBlue,
                  chips: [
                    if (isTurkishDeck) 'BaristaFlameGame 60fps 3 şerit' else 'BaristaFlameGame 60fps 3-Lane',
                    if (isTurkishDeck) '2x2 arayüz + 3 gözlü tepsi' else '2x2 HUD + 3-Slot Tray',
                    'NfcTagController (NDEFReader)',
                    if (isTurkishDeck) 'Karta dokunma yedeği' else 'Card-Tap Fallback',
                    if (isTurkishDeck) '14 PNG · 5 Lottie · 10 WAV' else '14 PNGs · 5 Lottie · 10 WAV',
                  ],
                  outcome: isTurkishDeck ? '60fps hedefi\n+ Web NFC' : '60fps + Web NFC',
                ),
              ),
              SizedBox(height: _gap),
              Expanded(
                child: _LayerBand(
                  number: 2,
                  name: isTurkishDeck ? 'AYAR' : 'CONFIG',
                  color: DeckColors.googleYellow,
                  chips: [
                    if (isTurkishDeck) '1 · Uygulama içi seçim' else '1 · In-app override',
                    '2 · Remote Config active_city_id',
                    '3 · city_editions.json',
                  ],
                  outcome: isTurkishDeck ? '4 şehir,\n0 derleme' : '4 cities, 0 rebuilds',
                ),
              ),
              SizedBox(height: _gap),
              Expanded(
                child: _LayerBand(
                  number: 3,
                  name: isTurkishDeck ? 'AI VE KORUMALAR' : 'AI & GUARDRAILS',
                  color: DeckColors.googleGreen,
                  chips: [
                    'gemini-3.5-flash-lite',
                    if (isTurkishDeck) 'CafeReview JSON şeması' else 'CafeReview JSON schema',
                    if (isTurkishDeck) '8 sn timeout' else '8 s timeout',
                    if (isTurkishDeck) 'yerel Gemma 15 sn' else 'local Gemma 15 s',
                    if (isTurkishDeck) '250 ms çevrimdışı yedek' else '250 ms offline fallback',
                  ],
                  outcome: isTurkishDeck ? '1 çağrı\n≈ 270 token' : '1 call ≈ 270 tokens',
                ),
              ),
              SizedBox(height: _gap),
              Expanded(
                child: _LayerBand(
                  number: 4,
                  name: isTurkishDeck ? 'SUNUCUSUZ BULUT' : 'SERVERLESS CLOUD',
                  color: DeckColors.googleRed,
                  chips: [
                    if (isTurkishDeck) 'Çok aşamalı Dockerfile' else 'Multi-stage Dockerfile',
                    'nginx:alpine :8080',
                    'Cloud Run *.run.app',
                    if (isTurkishDeck) 'GitHub eşitleme' else 'GitHub sync',
                  ],
                  outcome: isTurkishDeck ? 'Sunucuda\n0 durum' : '0 server state',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One horizontal band of the layer stack: name on the left, components in the middle, outcome on the right.
class _LayerBand extends StatelessWidget {
  const _LayerBand({
    required this.number,
    required this.name,
    required this.color,
    required this.chips,
    required this.outcome,
  });

  static const double _labelWidth = 330;
  static const double _outcomeWidth = 340;
  static const double _chipGap = 12;

  final int number;
  final String name;
  final Color color;
  final List<String> chips;
  final String outcome;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      padding: EdgeInsets.zero,
      borderColor: color.withValues(alpha: 0.5),
      child: Row(
        children: [
          Container(
            width: _labelWidth,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(19)),
              border: Border(left: BorderSide(color: color, width: 8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTurkishDeck ? 'KATMAN $number' : 'LAYER $number',
                  style: TextStyle(
                    fontFamily: DeckFonts.mono,
                    fontSize: DeckTypeScale.bodySmall,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: DeckTypeScale.bodyLarge,
                    fontWeight: FontWeight.w700,
                    color: DeckColors.offWhite,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: _chipGap,
                runSpacing: _chipGap,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final chip in chips)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: DeckColors.surfaceInset,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DeckColors.outlineLight),
                      ),
                      child: Text(
                        chip,
                        style: const TextStyle(
                          fontFamily: DeckFonts.mono,
                          fontSize: DeckTypeScale.code,
                          color: DeckColors.offWhite,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            width: _outcomeWidth,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerRight,
            child: Text(
              outcome,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: DeckFonts.sans,
                fontSize: DeckTypeScale.subtitle,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
