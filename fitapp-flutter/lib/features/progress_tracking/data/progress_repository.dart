class ProgressRepository {
  static int? _lastSessionVolume;

  static void saveSession(int volume) {
    _lastSessionVolume = volume;
  }

  static int getLastSessionVolume() {
    return _lastSessionVolume ?? 0;
  }
}