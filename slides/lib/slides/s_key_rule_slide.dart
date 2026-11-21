import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:backyard_barista_deck/widgets/lesson_diagrams.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 5, first slide: the API key stays on the server, and two checks prove it.
class KeyRuleSlide extends FlutterDeckSlideWidget {
  const KeyRuleSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/key-rule',
            title: '20. Kural 5: anahtar sunucuda kalır',
            speakerNotes:
                'BEAT  [22:30 - 24:00] Kural 5, güvenlik. Yeni kelime: proxy. Anahtarı ve iki kanıtı göster.\n'
                'SAY   "Beşinci kural. Gemini\'yi çağırmak için bir API anahtarı gerekiyor; anahtar, faturanızın şifresi gibi: kimde varsa sizin hesabınıza harcar. Web uygulamasının içine koyarsanız herkes tarayıcıdan okuyabilir. Yeni kelime proxy: tarayıcı ile Gemini arasındaki aracı sunucu. Telefonunuz bizim sunucuya soruyor; sarı satırda sunucu anahtarı ekleyip Gemini\'ye iletiyor. Anahtar telefonunuza hiç inmiyor. Bunu söylemek kolay, o yüzden iki kanıt var. Bir test, giden istekte anahtar olmadığını kontrol ediyor. CI, yani her değişiklikte otomatik çalışan kontrol, derlenen pakette anahtara benzeyen bir şey arıyor. Eve götüreceğiniz cümle: tarayıcıya giden her şeyi herkes okur."\n'
                'HOLD  Önce soldaki iki şerit: YANLIŞ, sonra OYUNDA. Sonra sağdaki sarı satır, en son alttaki iki kanıt. Alttaki "İleri seviye" satırını okuma; sorulursa: proxy\'de kimlik kontrolü yok, üretimde yol App Check.\n'
                'NEXT  "Anahtar güvende. Peki onu ne sıklıkla kullanıyoruz?"',
          ),
        );

  static const double _gap = 18;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KURAL 5 / 5',
          title: 'Anahtar sunucuda kalır',
          act: StoryAct.underTheHood,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NewWordCard(
                word: 'Proxy',
                definition: 'Tarayıcı ile Gemini arasındaki aracı sunucu. API anahtarını isteğe o ekler.',
              ),
              SizedBox(height: _gap),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: KeyProxyDiagram()),
                    SizedBox(width: _gap),
                    Expanded(
                      child: LessonCodeCard(
                        label: 'SUNUCU · ANAHTARI BURASI EKLER',
                        filePathLabel: 'nginx/default.conf.template · sadeleştirildi',
                        accentColor: DeckColors.googleGreen,
                        lines: [
                          CodeLine('location = /api/gemini/generate {'),
                          CodeLine('  limit_req zone=gemini_all burst=20;'),
                          CodeLine('  proxy_pass https://...googleapis.com/...;'),
                          CodeLine.pointAt('  proxy_set_header x-goog-api-key'),
                          CodeLine(r'      "${GEMINI_API_KEY}";'),
                          CodeLine('}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: _gap),
              Row(
                children: [
                  Expanded(child: ProofChip(label: 'TEST', text: 'Tarayıcıdan giden istekte anahtar yok.')),
                  SizedBox(width: _gap),
                  Expanded(child: ProofChip(label: 'CI', text: 'Pakette anahtar kalıbı arar; sahtesini yakaladı.')),
                ],
              ),
              SizedBox(height: _gap),
              AdvancedNote(
                "proxy'de kimlik kontrolü yok, isteyen bu adrese istek atabilir; üretimde yol App Check, bu demoda yok",
              ),
            ],
          ),
        );
      },
    );
  }
}
