import 'package:backyard_barista_cloudrun/models/cafe_review.dart';

/// Where the order on the counter stands. An order is idle, with the jury, or served with its review;
/// no fourth combination can be written.
sealed class OrderState {
  const OrderState();
}

/// Nothing is with the jury and no review is on the counter.
final class OrderIdle extends OrderState {
  const OrderIdle();
}

/// One tray is with the jury. Each serve creates its own instance and a verdict is only accepted while that
/// same instance is still the current state, so this constructor must never become `const`: two `const`
/// instances would be identical, and a late verdict for an old tray could claim a newer order.
final class OrderEvaluating extends OrderState {
  OrderEvaluating();
}

/// The jury answered and the review is on the counter.
final class OrderServed extends OrderState {
  const OrderServed(this.review);

  final CafeReview review;
}
