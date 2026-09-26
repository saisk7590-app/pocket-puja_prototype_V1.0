/// Mutable playlist model — unlike other /data files, these aren't
/// const, since playlists get created and edited by the user.
class Playlist {
  final String id;
  String name;
  final String seed;
  final List<String> trackIds;
  Playlist({required this.id, required this.name, required this.seed, List<String>? trackIds}) : trackIds = trackIds ?? [];
}

/// Seed data — a couple of starter playlists so the screen isn't empty
/// on first open.
List<Playlist> initialPlaylists() => [
      Playlist(id: 'pl_morning', name: 'Morning Chants', seed: 'playlist1', trackIds: ['t1', 't6']),
      Playlist(id: 'pl_festival', name: 'Festival Favorites', seed: 'playlist2', trackIds: ['t3', 't4']),
    ];