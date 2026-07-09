abstract class StorageServce {
  Future<void> saveHasLaunchedBefore(bool value);
  Future<bool> loadHasLaunchedBefore();

  Future<void> saveGlobalEnabled(bool value);
  Future<bool> loadGlobalEnabled();

  Future<void> saveAppVolume(double value);
  Future<double> loadAppVolume();

  Future<void> saveFollowSystemVolume(bool value);
  Future<bool> loadFollowSystemVolume();
}
