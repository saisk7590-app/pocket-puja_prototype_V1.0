// Mock data for the Calendar module — Panchangam, Festivals, Rashi.

class FestivalData {
  final int day, month;
  final String name, type; // type: pournami, amavasya, ekadasi, major
  const FestivalData(this.day, this.month, this.name, this.type);
}

const festivals = [
  FestivalData(11, 9, 'Pola Amavasya', 'amavasya'),
  FestivalData(21, 9, 'Narasimha Jayanti', 'major'),
  FestivalData(23, 9, 'Buddha Purnima', 'pournami'),
  FestivalData(4, 9, 'Ekadasi', 'ekadasi'),
];

class PanchangamDetail {
  final String vaaram, tithi, nakshatram, yogam, karanam, sunrise, sunset;
  final String amruthaGadiyalu, abhijitMuhurtham;
  final String rahuKalam, yamagandam, gulikaKalam, durmuhurtham;
  const PanchangamDetail({
    required this.vaaram, required this.tithi, required this.nakshatram,
    required this.yogam, required this.karanam, required this.sunrise, required this.sunset,
    required this.amruthaGadiyalu, required this.abhijitMuhurtham,
    required this.rahuKalam, required this.yamagandam, required this.gulikaKalam, required this.durmuhurtham,
  });
}

const samplePanchangam = PanchangamDetail(
  vaaram: 'శుక్రవారం (Friday)',
  tithi: 'అమావాస్య ఉ. 8:58 వరకు, తరువాత పాడ్యమి',
  nakshatram: 'పూర్వ ఫల్గుని మ. 1:15 వరకు, తరువాత ఉత్తర ఫల్గుని',
  yogam: 'సాధ్య సా. 4:58 వరకు',
  karanam: 'నాగవ ఉ. 8:58 వరకు, తరువాత స్తుమ్నుమ రా. 8:21 వరకు',
  sunrise: '6:07 AM',
  sunset: '6:18 PM',
  amruthaGadiyalu: 'ఉ. 7:03 - ఉ. 8:36',
  abhijitMuhurtham: 'ఉ. 11:48 - మ. 12:37',
  rahuKalam: 'ఉ. 10:41 - మ. 12:12',
  yamagandam: 'మ. 3:15 - సా. 4:46',
  gulikaKalam: 'ఉ. 7:38 - ఉ. 9:09',
  durmuhurtham: 'ఉ. 8:33 - ఉ. 9:22, మ. 12:37 - మ. 1:25',
);

class RashiSign {
  final String name, telugu, symbol;
  const RashiSign(this.name, this.telugu, this.symbol);
}

const rashiSigns = [
  RashiSign('Mesha', 'మేష', '♈'), RashiSign('Vrishabha', 'వృషభ', '♉'),
  RashiSign('Mithuna', 'మిథున', '♊'), RashiSign('Karka', 'కర్క', '♋'),
  RashiSign('Simha', 'సింహ', '♌'), RashiSign('Kanya', 'కన్య', '♍'),
  RashiSign('Tula', 'తుల', '♎'), RashiSign('Vrischika', 'వృశ్చిక', '♏'),
  RashiSign('Dhanu', 'ధను', '♐'), RashiSign('Makara', 'మకర', '♑'),
  RashiSign('Kumbha', 'కుంభ', '♒'), RashiSign('Meena', 'మీన', '♓'),
];

const sampleRashiPrediction = 'Financial gains are likely today. A good day for new beginnings in career matters. Family harmony is favored in the evening hours.';
