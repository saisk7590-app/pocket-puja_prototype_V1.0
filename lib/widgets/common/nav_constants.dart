import 'package:flutter/material.dart';
//import 'glass.dart';
import '../../services/audio_controller.dart';

/// Shared layout constants so every screen agrees on the same numbers —
/// nothing computed independently, nothing drifting out of sync.
const double kNavBarHeight = 84;       // pill nav bar + its own margin
const double kMiniPlayerHeight = 72;   // mini-player bar + its own margin
const double kFloatingGap = 12;        // visible breathing room between stacked floating elements
const double kCartBarHeight = 64;      // Shop's StickyCartBar
const double kFabHeight = 56;          // Booking's FloatingActionButton.extended

/// Base clearance for a tab's scrollable content: always clears the nav
/// bar, and ONLY adds mini-player clearance if a track is actually
/// playing right now — no static leftover gap when nothing's playing.
double tabBottomPadding(BuildContext context) {
  final controller = AudioControllerScope.of(context);
  final hasMiniPlayer = controller.currentTrack != null;
  return kNavBarHeight + (hasMiniPlayer ? kMiniPlayerHeight + kFloatingGap : 0) + 16;
}

/// For tabs with an EXTRA floating element on top of the mini-player
/// stack (Shop's cart bar, Booking's FAB) — content needs to clear that
/// element too, plus a visible gap above it.
double extraFloatingElementPadding(BuildContext context, double elementHeight) {
  return tabBottomPadding(context) + elementHeight + kFloatingGap;
}

/// Where that extra floating element itself should sit — directly above
/// the nav/mini-player stack, with the same gap already baked in via
/// tabBottomPadding's own +16, so it never touches what's below it.
double floatingElementBottomOffset(BuildContext context) {
  return tabBottomPadding(context);
}