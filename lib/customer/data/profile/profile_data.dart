// Mock data for the Profile module.
export 'package:pocket_puja/core/models/profile_models.dart';
import 'package:pocket_puja/core/models/profile_models.dart';

const currentUser = UserProfile(
  name: 'సాయి కిరణ్',
  mobile: '+91 98765 43210',
  city: 'Hyderabad',
  dob: '15 Aug 1995',
  rashi: 'Simha (సింహ)',
  level: 'Level 12 Sadhak',
  seed: 'profile',
);

const addresses = defaultAddresses;

const notificationPrefs = [
  NotificationPref('📿', 'Daily Panchangam', "Today's Tithi & auspicious timings", true),
  NotificationPref('🎉', 'Festival Alerts', 'Upcoming festivals & special poojas', true),
  NotificationPref('📅', 'Booking Updates', 'Assigned Poojari, status changes', true, isLocked: true),
  NotificationPref('📦', 'Order & Delivery Updates', 'Shop order status, dispatch, delivery', true),
  NotificationPref('🎵', 'Audio Recommendations', 'New chants, "Today\'s Focus" picks', false),
  NotificationPref('⭐', 'Subscription & Offers', 'Usage warnings, plan renewal reminders', true),
];

