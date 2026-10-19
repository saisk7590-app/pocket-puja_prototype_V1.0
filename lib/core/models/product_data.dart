class ProductData {
  final String id, name, seed, category;
  final int pricePaise, mrpPaise;
  final bool isEssential;

  const ProductData(
    this.id,
    this.name,
    this.seed,
    this.category,
    this.pricePaise,
    this.mrpPaise, {
    this.isEssential = false,
  });
}

const products = [
  ProductData('pr1', 'Premium Agarbatti', 'agarbatti', 'Agarbatti', 14900, 19900, isEssential: true),
  ProductData('pr2', 'Sacred Flowers', 'flowers2', 'Flowers', 9900, 12900, isEssential: true),
  ProductData('pr3', 'Handcrafted Diyas', 'diyas', 'Diyas', 29900, 39900),
  ProductData('pr4', 'Organic Kumkum', 'kumkum2', 'Kumkum', 5000, 6500, isEssential: true),
  ProductData('pr5', 'Camphor Pack (100g)', 'camphor', 'Agarbatti', 14900, 19900, isEssential: true),
  ProductData('pr6', 'Ghee Lamp Set', 'ghee', 'Diyas', 39900, 49900),
  ProductData('pr7', 'Turmeric (250g)', 'turmeric', 'Kumkum', 8900, 12900),
  ProductData('pr8', 'Brass Idol - Ganesha', 'idol1', 'Idols', 149900, 199900),
  ProductData('pr9', 'Pure Cow Ghee (500g)', 'ghee', 'Diyas', 32000, 36000, isEssential: true),
  ProductData('pr10', 'Sacred Coconuts (Pack of 2)', 'coconut', 'Essentials', 6000, 8000, isEssential: true),
  ProductData('pr11', 'Betel Leaves & Supari Set', 'leaves', 'Essentials', 4500, 5500),
  ProductData('pr12', 'Panchamrutham Samagri Pack', 'honey', 'Essentials', 12500, 15000),
  ProductData('pr13', 'Homa Samidhalu & Dry Wood', 'wood', 'Puja Kits', 16000, 19000),
  ProductData('pr14', 'Navadhanyam (9 Sacred Grains)', 'grains', 'Essentials', 9900, 12000),
  ProductData('pr15', 'Dry Fruits & Modak Prasadam', 'modak', 'Essentials', 18000, 22000),
];
