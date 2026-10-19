export 'package:pocket_puja/poojari/screens/availability/availability_calendar_screen.dart';

import 'package:flutter/material.dart';
import 'package:pocket_puja/poojari/screens/availability/availability_calendar_screen.dart';

/// Backwards compatibility wrapper for [AvailabilityCalendarScreen].
class PoojariAvailabilityScreen extends StatelessWidget {
  final bool? showBack;
  const PoojariAvailabilityScreen({super.key, this.showBack});

  @override
  Widget build(BuildContext context) {
    return AvailabilityCalendarScreen(showBack: showBack);
  }
}
