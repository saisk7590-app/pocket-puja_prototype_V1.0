// Mock data for the Shop module.
export 'package:pocket_puja/core/models/product_data.dart';

class CategoryData {
  final String label;
  const CategoryData(this.label);
}

const categories = [
  CategoryData('All'), CategoryData('Agarbatti'), CategoryData('Flowers'),
  CategoryData('Diyas'), CategoryData('Kumkum'), CategoryData('Idols'),
  CategoryData('Puja Kits'), CategoryData('Books'),
];




class KitData {
  final String id, name, tag, desc, seed;
  final int pricePaise;
  const KitData(this.id, this.name, this.tag, this.desc, this.seed, this.pricePaise);
}

const kits = [
  KitData('k1', 'Sarva Devata Puja Kit', 'Essentials', 'Complete ceremonial collection for all major auspicious occasions.', 'pujakit', 129900),
  KitData('k2', 'Ganesh Chaturthi Puja Kit', 'Seasonal', 'Essential Samagri & Murti for Ganesh Chaturthi.', 'kit', 249900),
];

class SeasonalBannerData {
  final String title, seed;
  const SeasonalBannerData(this.title, this.seed);
}

const seasonalBanners = [
  SeasonalBannerData('Ganesh Chaturthi Special', 'seasonal0'),
  SeasonalBannerData('Diwali Puja Bundle', 'seasonal1'),
];

class CartItem {
  final String name, seed;
  final int pricePaise, qty;
  const CartItem(this.name, this.seed, this.pricePaise, this.qty);
}

const sampleCart = [
  CartItem('Ganesh Chaturthi Puja Kit', 'kit', 249900, 1),
  CartItem('Mysore Sandalwood Incense', 'incense2', 45000, 1),
];

class OrderData {
  final String id, date, status;
  final int itemCount, totalPaise;
  final List<String> itemSeeds;
  const OrderData(this.id, this.date, this.status, this.itemCount, this.totalPaise, this.itemSeeds);
}

const orders = [
  OrderData('PP-SH-88291', 'Sep 1, 2026', 'Delivered', 3, 309600, ['kit', 'incense2', 'flowers2']),
  OrderData('PP-SH-77102', 'Aug 12, 2026', 'Dispatched', 2, 44700, ['kumkum2', 'diyas']),
  OrderData('PP-SH-65098', 'Jul 3, 2026', 'Delivered', 1, 39900, ['ghee']),
];
