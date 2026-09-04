/// Mock data for the Home module. In a real app this would come from
/// a backend; here it's just static sample data for the UI prototype.

class DeityDay {
  final String dayName;
  final List<String> deities;
  const DeityDay(this.dayName, this.deities);
}

/// Day-of-week → deity mapping, drives the "Today's Focus" carousel.
const weekdayDeities = [
  DeityDay('Sunday', ['Surya', 'Vishnu']),
  DeityDay('Monday', ['Shiva']),
  DeityDay('Tuesday', ['Hanuman']),
  DeityDay('Wednesday', ['Vishnu', 'Ganesha']),
  DeityDay('Thursday', ['Sai Baba', 'Guru/Vishnu']),
  DeityDay('Friday', ['Lakshmi', 'Durga']),
  DeityDay('Saturday', ['Shani', 'Venkateswara']),
];

class HeroPanchangamData {
  final String tithi, nakshatram, dateDay, dateMonth, calloutLabel, calloutValue;
  final bool isFestival;
  const HeroPanchangamData({
    required this.tithi,
    required this.nakshatram,
    required this.dateDay,
    required this.dateMonth,
    required this.calloutLabel,
    required this.calloutValue,
    this.isFestival = false,
  });
}

const todayPanchangam = HeroPanchangamData(
  tithi: 'Ekadasi (ఏకాదశి)',
  nakshatram: 'Magha (మఘ)',
  dateDay: '24',
  dateMonth: 'OCTOBER',
  calloutLabel: 'RAHU KALAM',
  calloutValue: '1:30 PM - 3:00 PM',
);

class RashiInsight {
  final String sign, signTelugu, oneLiner;
  const RashiInsight(this.sign, this.signTelugu, this.oneLiner);
}

/// Null-able in real use — only shown if user has set their DOB.
const currentUserRashi = RashiInsight('Simha', 'సింహ', 'Financial gains likely today.');

class ActiveBookingSummary {
  final String poojaName, status, note;
  const ActiveBookingSummary(this.poojaName, this.status, this.note);
}

/// Null when there's no active booking — Home hides this card entirely.
const activeBooking = ActiveBookingSummary('Ganesha Homam', 'Assigned', 'Poojari arriving 8:30 AM');

class UpcomingFestivalBanner {
  final String name, daysAway;
  const UpcomingFestivalBanner(this.name, this.daysAway);
}

/// Null when nothing is within the 5-7 day window.
const upcomingFestival = UpcomingFestivalBanner('Ganesh Chaturthi', '3 days');

class DailyWisdom {
  final String teluguQuote, englishMeaning;
  const DailyWisdom(this.teluguQuote, this.englishMeaning);
}

const dailyWisdom = DailyWisdom(
  '"ధర్మమే జయం, సత్యమే శివం."',
  'Dharma alone triumphs; Truth is the ultimate auspiciousness.',
);
