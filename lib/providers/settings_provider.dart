import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final String defaultAlgorithm;
  final bool isDarkMode;

  SettingsState({
    this.defaultAlgorithm = 'BFS',
    this.isDarkMode = false,
  });

  SettingsState copyWith({
    String? defaultAlgorithm,
    bool? isDarkMode,
  }) {
    return SettingsState(
      defaultAlgorithm: defaultAlgorithm ?? this.defaultAlgorithm,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SharedPreferences? _prefs;

  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      defaultAlgorithm: _prefs?.getString('defaultAlgorithm') ?? 'BFS',
      isDarkMode: _prefs?.getBool('isDarkMode') ?? false,
    );
  }

  void toggleDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
    _prefs?.setBool('isDarkMode', value);
  }

  void setDefaultAlgorithm(String algorithm) {
    state = state.copyWith(defaultAlgorithm: algorithm);
    _prefs?.setString('defaultAlgorithm', algorithm);
  }
}
