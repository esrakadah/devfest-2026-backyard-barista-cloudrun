import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/demo_hiccup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class DemoHiccupSlide extends FlutterDeckSlideWidget {
  const DemoHiccupSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/demo-hiccup',
            title: isTurkishDeck ? 'Yedek: demo aksarsa, çevrimdışı mod' : 'Backup: Demo Hiccup & Offline Mode',
            speakerNotes: isTurkishDeck
                ? "BEAT  [YEDEK] Salon Wi-Fi'ı kesilirse cankurtaran slaytı.\n"
                    'SAY   "Wi-Fi kısa bir çay molası verdi. Sorun değil, mimariyi tam bu an için kurduk. Hazırladığım yerel sekmeye geçiyorum: kod aynı, sadece bulut kapalı. Kararı bu laptoptaki Gemma 4 veriyor; o da yetişmezse paketteki hazır yanıtlar devreye giriyor. Oyuna kaldığımız yerden devam ediyoruz."\n'
                    'HOLD  Sakin kal, gülümse, sahneden önce açtığın yerel çevrimdışı sekmeye geç. Sahnede komut çalıştırma. Bittiğinde canlı demo slaytına (/live-build-dashboard) geri dön.\n'
                    'NEXT  "Kaldığımız yerden devam edelim."'
                : 'BEAT  [BACKUP] Konferans Wi-Fi Bağlantısı Kesildiğinde Cankurtaran Slaydı.\n'
                    'SAY   "Konferans Wi-Fi ağımız şu an 300 kişinin yüklenmesiyle kısa bir mola verdi; ama mimarimizi tam da bu an için tasarladık! Şimdi uygulamayı OFFLINE_MODE=true ile çalıştırıyorum: Gemini atlanıyor, kararı bu laptoptaki Gemma 4 veriyor, o da yetişmezse paketteki mock_responses.json devreye giriyor. 4 şehrin tamamında şaka testlerimize kesintisiz devam ediyoruz."\n'
                    'HOLD  Sakin kal, gülümse ve yerel sekmedeki çevrimdışı çalışan Flutter Web örneğine geç.\n'
                    'NEXT  "Canlı inşa panosuna (/live-build-dashboard) geri dön."',
          ),
        );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => const DemoHiccupScreen(
        ground: !isKonyaTheme,
        message: isTurkishDeck
            ? "Salon Wi-Fi'ı çay molası verdi!\n"
                'Çevrimdışı yedeğe geçiyoruz:\n'
                'yerel sekme hazır\n'
                'Gemma 4 + 250 ms paket'
            : 'Conference Wi-Fi took a coffee break!\n'
                'Switch to offline fallback:\n'
                'flutter run -d chrome --dart-define=OFFLINE_MODE=true --dart-define=DEFAULT_CITY=gaziantep',
      ),
    );
  }
}
