// Mock data for the Subscription module.

class PlanFeature {
  final String label;
  final bool included;
  const PlanFeature(this.label, this.included);
}

const freeFeatures = [
  PlanFeature('Standard Audio Quality', true),
  PlanFeature('10 Hours Monthly Listening', true),
  PlanFeature('Offline Sacred Library', false),
  PlanFeature('Festival Muhurat Alerts', false),
];

class PremiumFeature {
  final String title, sub;
  const PremiumFeature(this.title, this.sub);
}

const premiumFeatures = [
  PremiumFeature('Unlimited Audio', 'Listen to mantras all day long'),
  PremiumFeature('Offline Downloads', 'Access without internet in temples'),
  PremiumFeature('Festival Alerts', 'Precise Telugu Panchangam timings'),
];

const premiumPriceLabel = '₹49'; // per PRD Section 6
const annualPriceLabel = '₹499'; // ~15% off monthly*12, placeholder
