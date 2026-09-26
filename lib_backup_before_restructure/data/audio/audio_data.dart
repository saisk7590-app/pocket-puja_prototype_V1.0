// Mock data for the Audio module (Chants + Podcasts).

class LyricLine {
  final String telugu, roman, meaning;
  final int repeatCount; // >1 for repeated mantras like 108-name chants
  const LyricLine(
    this.telugu,
    this.roman,
    this.meaning, {
    this.repeatCount = 1,
  });
}

class TrackData {
  final String id, title, deity, duration, seed, artist;
  final List<LyricLine> lyrics;
  const TrackData(
    this.id,
    this.title,
    this.deity,
    this.duration,
    this.seed,
    this.artist, {
    this.lyrics = const [],
  });
}

const sampleLyrics = [
  LyricLine(
    'త్వమేవ ప్రత్యక్షం తత్త్వమసి',
    'Tvameva pratyaksham tattvamasi',
    'You alone are the visible truth',
  ),
  LyricLine(
    'శుక్లాంబరధరం విష్ణుం',
    'Shuklambaradharam Vishnum',
    'Clad in white garments, Vishnu',
  ),
  LyricLine('ఓం', 'Om', 'The primordial sound', repeatCount: 108),
];

const tracks = [
  TrackData(
    't1',
    'లలితా సహస్రనామ...',
    'Devi',
    '22:45',
    'lalita',
    'M.S. Subbulakshmi',
    lyrics: sampleLyrics,
  ),
  TrackData(
    't2',
    'శివ అష్టోత్తర శతనా...',
    'Shiva',
    '12:10',
    'shiva',
    'S.P. Balasubrahmanyam',
    lyrics: sampleLyrics,
  ),
  TrackData(
    't3',
    'గణేశ పంచరత్నం',
    'Ganesha',
    '08:32',
    'ganesha',
    'Ravi Shankar',
    lyrics: sampleLyrics,
  ),
  TrackData(
    't4',
    'శ్రీ విష్ణు సహస్రనామ...',
    'Vishnu',
    '28:15',
    'vishnu',
    'M.S. Subbulakshmi',
    lyrics: sampleLyrics,
  ),
  TrackData(
    't5',
    'మహాలక్ష్మి అష్టకం',
    'Devi',
    '05:50',
    'lakshmi',
    'Ravi Shankar',
    lyrics: sampleLyrics,
  ),
  TrackData(
    't6',
    'హనుమాన్ చాలీసా',
    'Hanuman',
    '09:12',
    'hanuman',
    'S.P. Balasubrahmanyam',
    lyrics: sampleLyrics,
  ),
  TrackData(
    't7',
    'సాయి బాబా ఆరతి',
    'Sai Baba',
    '06:40',
    'saibaba',
    'Suresh Wadkar',
    lyrics: sampleLyrics,
  ),
];

class TodaysMantra {
  final String title, duration, seed;
  const TodaysMantra(this.title, this.duration, this.seed);
}

/// Always-free, even at 100% usage block.
const todaysMantra = TodaysMantra('Gayatri Mantra', '2:30', 'gayatri');

class PodcastData {
  final String id, title, host, duration, seed, showNotes, publishDate;
  const PodcastData(
    this.id,
    this.title,
    this.host,
    this.duration,
    this.seed,
    this.showNotes,
    this.publishDate,
  );
}

const podcasts = [
  PodcastData(
    'p1',
    'Bhagavad Gita Explained',
    'Swami Chinmayananda',
    'Ep 12 • 35 min',
    'podcast1',
    'A deep dive into Chapter 2 — the nature of the eternal soul and why Krishna urges Arjuna to act without attachment to results.',
    'Sep 1, 2026',
  ),
  PodcastData(
    'p2',
    'Stories from the Puranas',
    'Dr. Radhika Iyer',
    'Ep 8 • 28 min',
    'podcast2',
    'The story of Markandeya and his devotion to Shiva — a tale of faith overcoming even death itself.',
    'Aug 28, 2026',
  ),
  PodcastData(
    'p3',
    'Understanding Vedic Rituals',
    'Pandit Krishnamurthy',
    'Ep 4 • 42 min',
    'podcast3',
    'Why we perform Sandhyavandanam three times a day, and the science behind the timing.',
    'Aug 20, 2026',
  ),
];

/// Usage state — shared pool across chants + ashtothram + shathanamalu +
/// namalu + podcasts, per PRD Section 6.
class UsageState {
  final int usedMinutes, totalMinutes, daysUntilReset;
  const UsageState(this.usedMinutes, this.totalMinutes, this.daysUntilReset);

  double get fraction => usedMinutes / totalMinutes;
  bool get isWarning => fraction >= 0.8 && fraction < 1.0;
  bool get isBlocked => fraction >= 1.0;
}

const currentUsage = UsageState(320, 600, 9); // 600 min = 10 hrs per PRD
TrackData? trackById(String id) {
  try {
    return tracks.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
}
