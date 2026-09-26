export 'my_schedule_screen.dart';

import 'package:flutter/material.dart';
import 'package:pocket_puja/poojari/screens/schedule/my_schedule_screen.dart';

/// Backwards-compatible alias for MyScheduleScreen (BLOCK 10)
class PoojariScheduleScreen extends StatelessWidget {
  final VoidCallback? onSwitchToCustomer;

  const PoojariScheduleScreen({
    super.key,
    this.onSwitchToCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return MyScheduleScreen(onSwitchToCustomer: onSwitchToCustomer);
  }
}
