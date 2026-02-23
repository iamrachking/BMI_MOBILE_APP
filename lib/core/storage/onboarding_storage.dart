import 'package:get_storage/get_storage.dart';

class OnboardingStorage {
  OnboardingStorage._();

  static final _box = GetStorage();
  static const _keyDone = 'onboarding_done';

  static bool get isDone => _box.read<bool>(_keyDone) ?? false;

  static Future<void> setDone() => _box.write(_keyDone, true);
}
