import 'package:flutter/material.dart';

/// Mock data for the Booking module.

class OccasionData {
  final String emoji, name;
  final List<PoojaTypeData> poojas;
  const OccasionData(this.emoji, this.name, this.poojas);
}

class PoojaTypeData {
  final IconData icon;
  final String name, telugu;
  const PoojaTypeData(this.icon, this.name, this.telugu);
}

const occasions = [
  OccasionData('🏠', 'Housewarming', [PoojaTypeData(Icons.auto_awesome, 'Gruhapravesham', 'గృహప్రవేశం')]),
  OccasionData('🚗', 'New Vehicle', [PoojaTypeData(Icons.directions_car, 'Vehicle Pooja', 'వాహన పూజ')]),
  OccasionData('🙏', 'General Worship', [
    PoojaTypeData(Icons.self_improvement, 'Ganesha Pooja', 'వినాయక పూజ'),
    PoojaTypeData(Icons.temple_hindu, 'Satyanarayana Vratam', 'సత్యనారాయణ వ్రతం'),
  ]),
  OccasionData('✨', 'Life Events', [PoojaTypeData(Icons.celebration, 'Naming Ceremony', 'నామకరణం')]),
];

class PanditData {
  final String name, title, seed, arrivalTime;
  final double rating;
  final int poojaCount;
  const PanditData(this.name, this.title, this.seed, this.arrivalTime, this.rating, this.poojaCount);
}

const panditVenkataRamana = PanditData('Shri Venkata Ramana', 'Senior Vedic Scholar', 'pandit1', '08:30 AM', 4.9, 128);
const panditSubramanyam = PanditData('Shri Subramanyam Sharma', 'Homam Specialist', 'pandit2', '07:00 AM', 4.8, 96);
const panditRaghava = PanditData('Shri Raghava Acharya', 'Vastu & Vratam Expert', 'pandit3', '09:15 AM', 4.7, 210);

class BookingData {
  final String ref, poojaName, status, date;
  final int feePaise;
  final PanditData? pandit; // null while PENDING (not yet assigned)
  final int? myRating; // set only when status == RATED
  final String? cancelReason; // set only when status == CANCELLED
  const BookingData(this.ref, this.poojaName, this.status, this.date, this.feePaise, {this.pandit, this.myRating, this.cancelReason});
}

const activeBookings = [
  BookingData('PP-A1B2C3D4', 'గణపతి హోమం', 'ASSIGNED', 'Jun 15, 2026 • 9:00 AM', 150000, pandit: panditVenkataRamana),
  BookingData('PP-E5F6G7H8', 'సత్యనారాయణ వ్రతం', 'PENDING', 'Jun 20, 2026 • 10:00 AM', 200000),
  BookingData('PP-Q1R2S3T4', 'రుద్రాభిషేకం', 'CONFIRMED', 'Jun 25, 2026 • 7:00 AM', 175000, pandit: panditSubramanyam),
];

const completedBookings = [
  BookingData('PP-I9J0K1L2', 'రుద్రాభిషేకం', 'COMPLETED', 'May 10, 2026', 180000, pandit: panditVenkataRamana),
  BookingData('PP-M3N4O5P6', 'వాస్తు శాంతి', 'RATED', 'Apr 28, 2026', 200000, pandit: panditRaghava, myRating: 5),
  BookingData('PP-U5V6W7X8', 'నామకరణం', 'DONE', 'Apr 12, 2026', 220000, pandit: panditRaghava),
];

const cancelledBookings = [
  BookingData('PP-Z9Y8X7W6', 'సత్యనారాయణ వ్రతం', 'CANCELLED', 'Mar 3, 2026', 190000, cancelReason: 'Cancelled by you'),
  BookingData('PP-K2L3M4N5', 'గృహప్రవేశం', 'CANCELLED', 'Feb 18, 2026', 210000, cancelReason: 'No Poojari available for this date'),
];

class ItemData {
  final String nameTe, nameEn, desc, seed;
  final bool inShop;
  final int? pricePaise;
  const ItemData(this.nameTe, this.nameEn, this.desc, this.seed, this.inShop, this.pricePaise);
}

const poojaItems = [
  ItemData('కుంకుమ', 'Kumkum', 'SAFFRONIZED VERMILION', 'kumkum', true, 5000),
  ItemData('పువ్వులు', 'Flowers', 'FRESH SEASONAL BLOOMS', 'flowers', true, 9900),
  ItemData('దీపం నూనె', 'Diya Oil', 'PURE SESAME/GHEE', 'oil', true, 15000),
  ItemData('అగరుబత్తీలు', 'Incense', 'SANDALWOOD AROMA', 'incense', true, 14900),
  ItemData('మామిడి ఆకులు', 'Mango Leaves', 'FOR TORANAM', 'leaves', false, null),
];