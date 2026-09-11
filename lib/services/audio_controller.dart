import 'package:flutter/material.dart';
import '../data/audio/audio_data.dart';
import '../data/audio/playlist_data.dart';

enum RepeatMode { off, all, one }

/// Global playback + library state — shared across every screen via
/// [AudioControllerScope].
class AudioController extends ChangeNotifier {
  TrackData? currentTrack;
  bool isPlaying = false;
  bool isShuffle = false;
  RepeatMode repeatMode = RepeatMode.off;
  double progress = 0.32;
  int activeLineIndex = 0;
  int repeatOccurrence = 1;

  final ValueNotifier<int> playEvents = ValueNotifier(0);

  // --- Favorites (liked tracks) ---
  final Set<String> _likedTrackIds = {};
  bool isTrackLiked(String trackId) => _likedTrackIds.contains(trackId);
  void toggleLikeForTrack(String trackId) {
    if (_likedTrackIds.contains(trackId)) {
      _likedTrackIds.remove(trackId);
    } else {
      _likedTrackIds.add(trackId);
    }
    notifyListeners();
  }
  List<TrackData> get likedTracks => tracks.where((t) => _likedTrackIds.contains(t.id)).toList();

  // --- Playlists ---
  final List<Playlist> playlists = initialPlaylists();

  Playlist createPlaylist(String name) {
    final p = Playlist(id: 'pl_${DateTime.now().millisecondsSinceEpoch}', name: name, seed: 'playlist_new');
    playlists.add(p);
    notifyListeners();
    return p;
  }

  void addTrackToPlaylist(String playlistId, TrackData track) {
    final p = playlists.firstWhere((p) => p.id == playlistId);
    if (!p.trackIds.contains(track.id)) p.trackIds.add(track.id);
    notifyListeners();
  }

  void removeTrackFromPlaylist(String playlistId, String trackId) {
    final p = playlists.firstWhere((p) => p.id == playlistId);
    p.trackIds.remove(trackId);
    notifyListeners();
  }

  List<TrackData> tracksInPlaylist(Playlist p) => p.trackIds.map((id) => trackById(id)).whereType<TrackData>().toList();

  // --- Playback ---
  void playTrack(TrackData track) {
    currentTrack = track;
    isPlaying = true;
    progress = 0.0;
    activeLineIndex = 0;
    repeatOccurrence = 1;
    playEvents.value++;
    notifyListeners();
  }

  void togglePlay() { isPlaying = !isPlaying; notifyListeners(); }
  void toggleShuffle() { isShuffle = !isShuffle; notifyListeners(); }
  void cycleRepeat() { repeatMode = RepeatMode.values[(repeatMode.index + 1) % RepeatMode.values.length]; notifyListeners(); }
  void seek(double value) { progress = value; notifyListeners(); }
  void setActiveLine(int index) { activeLineIndex = index; repeatOccurrence = 1; notifyListeners(); }
  void stop() { currentTrack = null; isPlaying = false; notifyListeners(); }

  @override
  void dispose() {
    playEvents.dispose();
    super.dispose();
  }
}

class AudioControllerScope extends InheritedNotifier<AudioController> {
  const AudioControllerScope({super.key, required AudioController controller, required super.child}) : super(notifier: controller);
  static AudioController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AudioControllerScope>();
    assert(scope != null, 'No AudioControllerScope found in context');
    return scope!.notifier!;
  }
}