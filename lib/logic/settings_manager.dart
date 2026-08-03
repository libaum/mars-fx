import 'package:flutter/foundation.dart';
import 'package:mars_fx/data/local_storage_service.dart';
import 'package:mars_fx/services/service_locator.dart';

class SettingsManager {
  final _storage = getIt<LocalStorageService>();

  late final ValueNotifier<bool> showLongNameNotifier;

  SettingsManager() {
    showLongNameNotifier = ValueNotifier(_storage.getShowLongName());
  }

  void setShowLongName(bool v) {
    showLongNameNotifier.value = v;
    _storage.setShowLongName(v);
  }
}
