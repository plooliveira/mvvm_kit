import 'package:example_playground/core/widgets/simple_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import 'package:provider/provider.dart';
import 'theme_viewmodel.dart';
import '../../core/theme/theme_mode.dart';

part 'widgets/_theme_preview.dart';

// Here an example that uses Provider package to provide the ViewModel to the View.
class ThemeRoute extends GoRoute {
  ThemeRoute()
    : super(
        path: '/theme',
        name: 'theme',
        builder: (context, state) =>
            // You can isolate the ViewModel to be used only within this widget subtree
            Provider(create: (_) => ThemeViewModel(), child: const ThemeView()),
      );
}

class ThemeView extends StatefulWidget {
  const ThemeView({super.key});

  @override
  State<ThemeView> createState() => _ThemeViewState();
}

class _ThemeViewState extends ViewState<ThemeViewModel, ThemeView> {
  // Override createViewModel() to plug a
  // different injection strategy. In this case, Provider.
  @override
  ThemeViewModel createViewModel() => context.read<ThemeViewModel>();

  @override
  Widget build(BuildContext context) {
    // Reactive Watch that rebuilds when current theme changes
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

                    // Separate Watch to optimize rebuilds only for buttons
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
