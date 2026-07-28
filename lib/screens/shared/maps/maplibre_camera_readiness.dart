/// Tracks the two MapLibre callbacks required before camera operations are
/// safe. The callbacks are allowed to arrive in either order on native maps.
class MapLibreCameraReadiness {
  bool _mapCreated = false;
  bool _styleLoaded = false;
  bool _initialCameraPending = true;
  bool _resetPending = false;

  bool get isReady => _mapCreated && _styleLoaded;

  void markMapCreated() {
    _mapCreated = true;
  }

  void markStyleLoaded() {
    _styleLoaded = true;
  }

  /// Resets this instance for a newly-created native map or style.
  void reset() {
    _mapCreated = false;
    _styleLoaded = false;
    _initialCameraPending = true;
    _resetPending = false;
  }

  /// Claims the one-time initial camera operation when the map is ready.
  bool claimInitialCamera() {
    if (!isReady || !_initialCameraPending) return false;
    _initialCameraPending = false;
    return true;
  }

  /// Records a reset request until both MapLibre callbacks have fired.
  bool requestReset() {
    if (!isReady) {
      _resetPending = true;
      return false;
    }
    return true;
  }

  bool takePendingReset() {
    if (!_resetPending) return false;
    _resetPending = false;
    return true;
  }
}
