import 'package:flutter/material.dart';

/// Customer bottom navigation tab definitions:
/// Order, icons, labels, and index constants.
abstract final class CustomerNavTabs {
  static const int home = 0;
  static const int audio = 1;
  static const int bookings = 2;
  static const int shop = 3;
  static const int calendar = 4;

  static const List<IconData> icons = [
    Icons.home_rounded,
    Icons.headphones,
    Icons.event_available,
    Icons.shopping_bag,
    Icons.calendar_month,
  ];

  static const List<String> labels = [
    'Home',
    'Audio',
    'Bookings',
    'Shop',
    'Calendar',
  ];
}
