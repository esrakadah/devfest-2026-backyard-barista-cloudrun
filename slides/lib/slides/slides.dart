import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/slides/s_ai_studio_pipeline_slide.dart';
import 'package:backyard_barista_deck/slides/s_architecture_recap_slide.dart';
import 'package:backyard_barista_deck/slides/s_bana_ulasin_slide.dart';
import 'package:backyard_barista_deck/slides/s_demo_hiccup_slide.dart';
import 'package:backyard_barista_deck/slides/s_generate_vs_decide_slide.dart';
import 'package:backyard_barista_deck/slides/s_hybrid_asset_pipeline_slide.dart';
import 'package:backyard_barista_deck/slides/s_live_build_dashboard_slide.dart';
import 'package:backyard_barista_deck/slides/s_meet_antigravity_slide.dart';
import 'package:backyard_barista_deck/slides/s_multi_city_remote_config_slide.dart';
import 'package:backyard_barista_deck/slides/s_pure_flutter_widgets_slide.dart';
import 'package:backyard_barista_deck/slides/s_real_numbers_cost_slide.dart';
import 'package:backyard_barista_deck/slides/s_real_numbers_latency_slide.dart';
import 'package:backyard_barista_deck/slides/s_room_quota_trap_slide.dart';
import 'package:backyard_barista_deck/slides/s_salt_sugar_mechanic_slide.dart';
import 'package:backyard_barista_deck/slides/s_sweet_or_salty_slide.dart';
import 'package:backyard_barista_deck/slides/s_title_slide.dart';
import 'package:backyard_barista_deck/slides/s_winner_podium_closing_slide.dart';
import 'package:backyard_barista_deck/slides/s_workshop_contract_slide.dart';
import 'package:flutter_deck/flutter_deck.dart';

export 's_ai_studio_pipeline_slide.dart';
export 's_architecture_recap_slide.dart';
export 's_bana_ulasin_slide.dart';
export 's_demo_hiccup_slide.dart';
export 's_generate_vs_decide_slide.dart';
export 's_hybrid_asset_pipeline_slide.dart';
export 's_live_build_dashboard_slide.dart';
export 's_meet_antigravity_slide.dart';
export 's_multi_city_remote_config_slide.dart';
export 's_pure_flutter_widgets_slide.dart';
export 's_real_numbers_cost_slide.dart';
export 's_real_numbers_latency_slide.dart';
export 's_room_quota_trap_slide.dart';
export 's_salt_sugar_mechanic_slide.dart';
export 's_sweet_or_salty_slide.dart';
export 's_title_slide.dart';
export 's_winner_podium_closing_slide.dart';
export 's_workshop_contract_slide.dart';

/// The English workshop deck: 16 main slides.
const List<FlutterDeckSlideWidget> workshopMainSlides = [
  TitleSlide(),
  SweetOrSaltySlide(),
  WorkshopContractSlide(),
  AiStudioPipelineSlide(),
  MeetAntigravitySlide(),
  PureFlutterWidgetsSlide(),
  RealNumbersLatencySlide(),
  RealNumbersCostSlide(),
  RoomQuotaTrapSlide(),
  MultiCityRemoteConfigSlide(),
  SaltSugarMechanicSlide(),
  HybridAssetPipelineSlide(),
  LiveBuildDashboardSlide(),
  ArchitectureRecapSlide(),
  WinnerPodiumClosingSlide(),
  BanaUlasinSlide(),
];

/// The Turkish main-hall talk (`--dart-define=DECK_LANG=tr`). It has its own list so the talk can be
/// reordered without touching the workshop.
const List<FlutterDeckSlideWidget> talkMainSlides = [
  TitleSlide(),
  SweetOrSaltySlide(),
  WorkshopContractSlide(),
  AiStudioPipelineSlide(),
  MeetAntigravitySlide(),
  PureFlutterWidgetsSlide(),
  RealNumbersLatencySlide(),
  RealNumbersCostSlide(),
  RoomQuotaTrapSlide(),
  MultiCityRemoteConfigSlide(),
  SaltSugarMechanicSlide(),
  HybridAssetPipelineSlide(),
  LiveBuildDashboardSlide(),
  ArchitectureRecapSlide(),
  WinnerPodiumClosingSlide(),
  BanaUlasinSlide(),
];

/// Backup slides after the closing slide, reachable via PresenterMenuPlugin.
const List<FlutterDeckSlideWidget> workshopBackupSlides = [DemoHiccupSlide(), GenerateVsDecideSlide()];
const List<FlutterDeckSlideWidget> talkBackupSlides = [DemoHiccupSlide(), GenerateVsDecideSlide()];

/// Main presentation order of the deck being built.
const List<FlutterDeckSlideWidget> mainSlides = isTurkishDeck ? talkMainSlides : workshopMainSlides;

/// Backup slides of the deck being built.
const List<FlutterDeckSlideWidget> backupSlides = isTurkishDeck ? talkBackupSlides : workshopBackupSlides;

/// Full running order: main slides, then backup slides.
const List<FlutterDeckSlideWidget> deckSlides = [...mainSlides, ...backupSlides];

/// One-based slide number of [route], as `flutterDeck.goToSlide` counts them.
int? slideNumberForRoute(String route) {
  final index = deckSlides.indexWhere((slide) => slide.configuration?.route == route);
  return index < 0 ? null : index + 1;
}
