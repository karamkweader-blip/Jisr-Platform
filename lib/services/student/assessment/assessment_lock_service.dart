import 'package:flutter/services.dart';

class AssessmentLockService {
  static const MethodChannel _channel = MethodChannel(
    'jisr_platform/assessment_lock',
  );

  Future<void> startLock() async {
    try {
      await _channel.invokeMethod('startLockTaskMode');
    } catch (_) {}
  }

  Future<void> stopLock() async {
    try {
      await _channel.invokeMethod('stopLockTaskMode');
    } catch (_) {}
  }

  Future<bool> isLocked() async {
    try {
      final result = await _channel.invokeMethod<bool>('isInLockTaskMode');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
