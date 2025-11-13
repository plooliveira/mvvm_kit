import 'package:example_playground/core/widgets/simple_button.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import 'theme_viewmodel.dart';
import '../../core/theme/theme_mode.dart';

part 'widgets/_theme_preview.dart';

class ThemeView extends ViewWidget<ThemeViewModel> {
  ThemeView({super.key}) : super(viewModel: ThemeViewModel());

  @override
  State<ThemeView> createState() => _ThemeViewState();
}

class _ThemeViewState extends ViewState<ThemeViewModel, ThemeView> {
  @override
  Widget build(BuildContext context) {
    return Watch(
      viewModel.currentTheme,
      builder: (context, theme) {
        return Theme(
          data: theme,
          child: Scaffold(
            appBar: AppBar(title: const Text('Theme Switcher Example')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _ThemePreview(),

                    const SizedBox(height: 40),

                    Watch(
                      viewModel.themeMode,
                      builder: (context, mode) {
                        return Text(
                          'Current Theme: ${mode.name.toUpperCase()}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    Watch(
                      viewModel.themeMode,
                      builder: (context, currentMode) {
                        return Column(
                          children: [
                            SimpleButton(
                              label: 'Light Theme',
                              icon: Icons.light_mode,
                              isSelected: currentMode == AppThemeMode.light,
                              onPressed: viewModel.switchToLight,
                            ),
                            const SizedBox(height: 12),
                            SimpleButton(
                              label: 'Dark Theme',
                              icon: Icons.dark_mode,
                              isSelected: currentMode == AppThemeMode.dark,
                              onPressed: viewModel.switchToDark,
                            ),
                            const SizedBox(height: 12),
                            SimpleButton(
                              label: 'Custom Theme',
                              icon: Icons.palette,
                              isSelected: currentMode == AppThemeMode.custom,
                              onPressed: viewModel.switchToCustom,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
