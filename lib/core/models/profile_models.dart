class UserProfile {
  final String name, mobile, city, dob, rashi, level, seed;
  const UserProfile({
    required this.name,
    required this.mobile,
    required this.city,
    required this.dob,
    required this.rashi,
    required this.level,
    required this.seed,
  });
}

class AddressData {
  final String id, label, line, landmark, pincode;
  final bool isDefault;
  const AddressData({
    required this.id,
    required this.label,
    required this.line,
    required this.landmark,
    required this.pincode,
    this.isDefault = false,
  });
}

class NotificationPref {
  final String icon, title, subtitle;
  final bool enabled, isLocked;
  const NotificationPref(
    this.icon,
    this.title,
    this.subtitle,
    this.enabled, {
    this.isLocked = false,
  });
}

const defaultAddresses = [
  AddressData(
    id: 'a1',
    label: 'Home',
    line: 'Flat 402, Sri Sai Residency, Hitech City, Hyderabad - 500081',
    landmark: 'Near Cyber Towers',
    pincode: '500081',
    isDefault: true,
  ),
  AddressData(
    id: 'a2',
    label: 'Office',
    line: '3rd Floor, Cyber Towers, Madhapur, Hyderabad - 500081',
    landmark: 'Opposite Metro Station',
    pincode: '500081',
  ),
];
