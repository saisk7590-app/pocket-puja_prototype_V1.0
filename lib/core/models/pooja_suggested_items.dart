import 'package:pocket_puja/customer/data/shop/shop_data.dart';

/// BLOCK 9 — Suggested items mapping for Vedic Rituals.
/// Maps every Pooja Name / Type to `List<ItemId>` referencing the exact same
/// ProductData catalog in `lib/customer/data/shop/shop_data.dart`.
const Map<String, List<String>> poojaSuggestedItemIds = {
  // Ganesha Pooja / Ganapathi Homam
  'Ganesha Pooja': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr15', 'pr10', 'pr5'],
  'వినాయక పూజ': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr15', 'pr10', 'pr5'],
  'Ganapathi Homam': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr10', 'pr13', 'pr14', 'pr5'],
  'గణపతి హోమం': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr10', 'pr13', 'pr14', 'pr5'],
  'Ganesha Homam': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr10', 'pr13', 'pr14', 'pr5'],

  // Satyanarayana Vratam
  'Satyanarayana Vratam': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr10', 'pr11', 'pr12', 'pr14', 'pr5'],
  'సత్యనారాయణ వ్రతం': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr10', 'pr11', 'pr12', 'pr14', 'pr5'],

  // Gruhapravesham (Housewarming)
  'Gruhapravesham': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr10', 'pr11', 'pr13', 'pr14', 'pr3', 'pr5'],
  'గృహప్రవేశం': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr10', 'pr11', 'pr13', 'pr14', 'pr3', 'pr5'],

  // Vehicle Pooja
  'Vehicle Pooja': ['pr4', 'pr7', 'pr1', 'pr2', 'pr10', 'pr5'],
  'వాహన పూజ': ['pr4', 'pr7', 'pr1', 'pr2', 'pr10', 'pr5'],

  // Rudrabhishekam
  'Rudrabhishekam': ['pr1', 'pr2', 'pr5', 'pr9', 'pr12', 'pr11', 'pr10', 'pr3'],
  'రుద్రాభిషేకం': ['pr1', 'pr2', 'pr5', 'pr9', 'pr12', 'pr11', 'pr10', 'pr3'],

  // Naming Ceremony
  'Naming Ceremony': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr10', 'pr11', 'pr15', 'pr5'],
  'నామకరణం': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr10', 'pr11', 'pr15', 'pr5'],

  // Vastu Shanti
  'Vastu Shanti': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr10', 'pr13', 'pr14', 'pr5'],
  'వాస్తు శాంతి': ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr10', 'pr13', 'pr14', 'pr5'],
};

/// Default fallback suggested item IDs for any unspecified ritual
const List<String> defaultPoojaSuggestedItemIds = [
  'pr4', // Organic Kumkum
  'pr7', // Turmeric
  'pr1', // Premium Agarbatti
  'pr2', // Sacred Flowers
  'pr10', // Coconuts (Pack of 2)
  'pr9', // Pure Cow Ghee
  'pr5', // Camphor Pack
];

/// Resolves a pooja name into a list of ProductData items from the Shop catalog.
List<ProductData> getSuggestedProductsForPooja(String poojaName) {
  final cleanName = poojaName.trim();
  // Check direct match or contains
  List<String>? ids = poojaSuggestedItemIds[cleanName];

  if (ids == null) {
    for (final entry in poojaSuggestedItemIds.entries) {
      if (cleanName.toLowerCase().contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(cleanName.toLowerCase())) {
        ids = entry.value;
        break;
      }
    }
  }

  ids ??= defaultPoojaSuggestedItemIds;

  return ids.map((id) => findProductById(id)).whereType<ProductData>().toList();
}

/// Finds a ProductData item from the shared Shop catalog by ID.
ProductData? findProductById(String id) {
  try {
    return products.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
