import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/slides/s_ai_studio_pipeline_slide.dart';
import 'package:backyard_barista_deck/slides/s_architecture_recap_slide.dart';
import 'package:backyard_barista_deck/slides/s_bana_ulasin_slide.dart';
import 'package:backyard_barista_deck/slides/s_cost_honest_slide.dart';
import 'package:backyard_barista_deck/slides/s_demo_hiccup_slide.dart';
import 'package:backyard_barista_deck/slides/s_empty_reply_slide.dart';
import 'package:backyard_barista_deck/slides/s_enum_feeds_schema_slide.dart';
import 'package:backyard_barista_deck/slides/s_fallback_rule_slide.dart';
import 'package:backyard_barista_deck/slides/s_five_lessons_slide.dart';
import 'package:backyard_barista_deck/slides/s_forgotten_line_slide.dart';
import 'package:backyard_barista_deck/slides/s_generate_vs_decide_slide.dart';
import 'package:backyard_barista_deck/slides/s_guard_before_after_slide.dart';
import 'package:backyard_barista_deck/slides/s_guard_rule_slide.dart';
import 'package:backyard_barista_deck/slides/s_hall_leaderboard_slide.dart';
import 'package:backyard_barista_deck/slides/s_hall_load_test_slide.dart';
import 'package:backyard_barista_deck/slides/s_hall_plays_slide.dart';
import 'package:backyard_barista_deck/slides/s_how_it_was_built_slide.dart';
import 'package:backyard_barista_deck/slides/s_hybrid_asset_pipeline_slide.dart';
import 'package:backyard_barista_deck/slides/s_key_rule_slide.dart';
import 'package:backyard_barista_deck/slides/s_lesson_recap_slide.dart';
import 'package:backyard_barista_deck/slides/s_live_build_dashboard_slide.dart';
import 'package:backyard_barista_deck/slides/s_meet_antigravity_slide.dart';
import 'package:backyard_barista_deck/slides/s_multi_city_remote_config_slide.dart';
import 'package:backyard_barista_deck/slides/s_order_state_rule_slide.dart';
import 'package:backyard_barista_deck/slides/s_pure_flutter_widgets_slide.dart';
import 'package:backyard_barista_deck/slides/s_real_numbers_cost_slide.dart';
import 'package:backyard_barista_deck/slides/s_real_numbers_latency_slide.dart';
import 'package:backyard_barista_deck/slides/s_room_quota_trap_slide.dart';
import 'package:backyard_barista_deck/slides/s_salt_sugar_mechanic_slide.dart';
import 'package:backyard_barista_deck/slides/s_sealed_order_slide.dart';
import 'package:backyard_barista_deck/slides/s_sweet_or_salty_slide.dart';
import 'package:backyard_barista_deck/slides/s_title_slide.dart';
import 'package:backyard_barista_deck/slides/s_typed_output_rule_slide.dart';
import 'package:backyard_barista_deck/slides/s_wifi_off_gemma_slide.dart';
import 'package:backyard_barista_deck/slides/s_winner_podium_closing_slide.dart';
import 'package:backyard_barista_deck/slides/s_winners_podium_slide.dart';
import 'package:backyard_barista_deck/slides/s_workshop_contract_slide.dart';
import 'package:flutter_deck/flutter_deck.dart';

export 's_ai_studio_pipeline_slide.dart';
export 's_architecture_recap_slide.dart';
export 's_bana_ulasin_slide.dart';
export 's_cost_honest_slide.dart';
export 's_demo_hiccup_slide.dart';
export 's_empty_reply_slide.dart';
export 's_enum_feeds_schema_slide.dart';
export 's_fallback_rule_slide.dart';
export 's_five_lessons_slide.dart';
export 's_forgotten_line_slide.dart';
export 's_generate_vs_decide_slide.dart';
export 's_guard_before_after_slide.dart';
export 's_guard_rule_slide.dart';
export 's_hall_leaderboard_slide.dart';
export 's_hall_load_test_slide.dart';
export 's_hall_plays_slide.dart';
export 's_how_it_was_built_slide.dart';
export 's_hybrid_asset_pipeline_slide.dart';
export 's_key_rule_slide.dart';
export 's_lesson_recap_slide.dart';
export 's_live_build_dashboard_slide.dart';
export 's_meet_antigravity_slide.dart';
export 's_multi_city_remote_config_slide.dart';
export 's_order_state_rule_slide.dart';
export 's_pure_flutter_widgets_slide.dart';
export 's_real_numbers_cost_slide.dart';
export 's_real_numbers_latency_slide.dart';
export 's_room_quota_trap_slide.dart';
export 's_salt_sugar_mechanic_slide.dart';
export 's_sealed_order_slide.dart';
export 's_sweet_or_salty_slide.dart';
export 's_title_slide.dart';
export 's_typed_output_rule_slide.dart';
export 's_wifi_off_gemma_slide.dart';
export 's_winner_podium_closing_slide.dart';
export 's_winners_podium_slide.dart';
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

/// The Turkish main-hall talk (`--dart-define=DECK_LANG=tr`): the hall plays first for a place on the
/// leaderboard, then five rules, each told as one rule slide and one or two code slides, and the podium
/// before the closing slide.
const List<FlutterDeckSlideWidget> talkMainSlides = [
  TitleSlide(),
  SweetOrSaltySlide(),
  HallPlaysSlide(),
  HallLeaderboardSlide(),
  HowItWasBuiltSlide(),
  FiveLessonsSlide(),
  GuardRuleSlide(),
  GuardBeforeAfterSlide(),
  TypedOutputRuleSlide(),
  EnumFeedsSchemaSlide(),
  EmptyReplySlide(),
  OrderStateRuleSlide(),
  ForgottenLineSlide(),
  SealedOrderSlide(),
  FallbackRuleSlide(),
  HallLoadTestSlide(),
  KeyRuleSlide(),
  CostHonestSlide(),
  LessonRecapSlide(),
  WinnersPodiumSlide(),
  BanaUlasinSlide(),
];

/// Backup slides after the closing slide, reachable via PresenterMenuPlugin.
const List<FlutterDeckSlideWidget> workshopBackupSlides = [DemoHiccupSlide(), GenerateVsDecideSlide()];
const List<FlutterDeckSlideWidget> talkBackupSlides = [DemoHiccupSlide(), WifiOffGemmaSlide()];

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
