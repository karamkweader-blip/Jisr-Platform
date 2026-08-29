import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AssessmentLockService {
  static const MethodChannel _channel = MethodChannel(
    'jisr_platform/assessment_lock',
  );

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Starts Android screen pinning / lock-task mode and hides the system bars.
  ///
  /// On a normal personal device Android uses screen pinning. If the device is
  /// managed and this package is allow-listed, Android promotes the same call
  /// to the stronger kiosk (lock-task) mode automatically.
  Future<bool> startLock() async {
    if (!_isAndroid) return false;

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    try {
      await _channel.invokeMethod<Map<Object?, Object?>>('startLockTaskMode');
      return true;
    } on MissingPluginException {
      // Keep the Flutter back-navigation protection active even when the
      // native Android side has not been installed yet.
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> stopLock() async {
    if (!_isAndroid) return;

    try {
      await _channel.invokeMethod('stopLockTaskMode');
    } on MissingPluginException {
      // Nothing native to release.
    } on PlatformException {
      // The activity may already have left lock-task mode (for example after
      // the process was recreated). Restoring Flutter's system UI is enough.
    } finally {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> refreshLock() async {
    if (!_isAndroid) return;

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    try {
      await _channel.invokeMethod('refreshLockTaskMode');
    } on MissingPluginException {
      // Flutter immersive mode and PopScope still protect accidental exits.
    } on PlatformException {
      // Do not interrupt an active assessment because of an OEM UI failure.
    }
  }

  Future<bool> isLocked() async {
    if (!_isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('isInLockTaskMode');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
