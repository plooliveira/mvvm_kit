import 'package:example_playground/view/counter/counter_viewmodel.dart';
import 'package:example_playground/view/form/product_form_viewmodel.dart';
import 'package:example_playground/view/theme_switcher/theme_viewmodel.dart';
import 'package:example_playground/view/todo/todo_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import 'core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register ViewModels using the built-in service locator
  SL.I.registerFactory(() => CounterViewModel());
  SL.I.registerFactory(() => ProductFormViewModel());
  SL.I.registerFactory(() => ThemeViewModel());

  // Register GetIt dependencies for the Todo feature
  await TodosDependencies().setup();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MVVM Kit Playground',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.lightBlue,
          onPrimary: Colors.white,
          secondary: Colors.blueAccent,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),

        useMaterial3: true,
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
