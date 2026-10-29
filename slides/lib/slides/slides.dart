import 'package:backyard_barista_deck/slides/s_ai_studio_pipeline_slide.dart';
import 'package:backyard_barista_deck/slides/s_architecture_recap_slide.dart';
import 'package:backyard_barista_deck/slides/s_demo_hiccup_slide.dart';
import 'package:backyard_barista_deck/slides/s_gde_artifacts_tour_slide.dart';
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
export 's_demo_hiccup_slide.dart';
export 's_gde_artifacts_tour_slide.dart';
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

/// Main 16-slide workshop & Vibe Lounge presentation order.
const List<FlutterDeckSlideWidget> mainSlides = [
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
  GdeArtifactsTourSlide(),
  WinnerPodiumClosingSlide(),
];

/// Backup slides after the closing slide, reachable via PresenterMenuPlugin.
const List<FlutterDeckSlideWidget> backupSlides = [
  DemoHiccupSlide(),
];

/// Full running order (16 main slides + 1 backup slide).
const List<FlutterDeckSlideWidget> deckSlides = [
  ...mainSlides,
  ...backupSlides,
];

/// One-based slide number of [route], as `flutterDeck.goToSlide` counts them.
int? slideNumberForRoute(String route) {
  final index = deckSlides.indexWhere((slide) => slide.configuration?.route == route);
  return index < 0 ? null : index + 1;
}
