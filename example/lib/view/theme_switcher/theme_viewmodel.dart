import 'package:flutter/material.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/theme_mode.dart';

// ViewModel for managing theme switching logic. In this example, it allows switching
// between light, dark, and custom themes using hotswappable LiveData.
// Of course that is not necessary for themes, but it serves as a good example of how to use
// HotswapLiveData in a ViewModel.

class ThemeViewModel extends ViewModel {
  late final _lightTheme = mutable(AppThemes.light());
  late final _darkTheme = mutable(AppThemes.dark());
  late final _customTheme = mutable(AppThemes.custom());

  // HotswapLiveData allows switching reactive data sources without loosing existing subscribers.
  late final HotswapLiveData<ThemeData> currentTheme = _lightTheme.hotswappable(
    scope,
  );

  late final _currentMode = mutable(AppThemeMode.light);
  LiveData<AppThemeMode> get themeMode => _currentMode;

  void switchToLight() {
    // disposeOld: false keeps theme references for reuse
    currentTheme.hotswap(_lightTheme, disposeOld: false);
    _currentMode.value = AppThemeMode.light;
  }

  void switchToDark() {
    currentTheme.hotswap(_darkTheme, disposeOld: false);
    _currentMode.value = AppThemeMode.dark;
  }

  void switchToCustom() {
    currentTheme.hotswap(_customTheme, disposeOld: false);
    _currentMode.value = AppThemeMode.custom;
  }
}
