import 'package:flutter/material.dart';

/// Poojari bottom navigation tab definitions:
/// Indices, icons, labels, order, and badge map wiring for new assignments.
abstract final class PoojariNavTabs {
  static const int dashboard = 0;
  static const int assignedPoojas = 1;
  static const int schedule = 2;
  static const int earnings = 3;

  static const List<IconData> icons = [
    Icons.dashboard_rounded,
    Icons.assignment_turned_in,
    Icons.event_note,
    Icons.payments_outlined,
  ];

  static const List<String> labels = [
    'Dashboard',
    'Assigned Poojas',
    'Schedule',
    'Earnings',
  ];

  /// Returns the badge mapping for the Assigned Poojas tab (index 1),
  /// hidden when count is zero.
  static Map<int, int>? badgeMapForNewCount(int newCount) {
    return newCount > 0 ? {assignedPoojas: newCount} : null;
  }
}
