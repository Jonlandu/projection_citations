import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _settingsBox = 'settings';
const _localeKey = 'locale_code'; // '' => system, 'fr'/'en'/'pt'

final localeControllerProvider =
StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController();
});

class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(null) {
    _load();
  }

  Box get _box => Hive.box(_settingsBox);

  void _load() {
    final code = (_box.get(_localeKey, defaultValue: '') as String).trim();
    if (code.isEmpty) {
      state = null; // system
    } else {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _box.put(_localeKey, '');
    } else {
      await _box.put(_localeKey, locale.languageCode);
    }
  }
}
