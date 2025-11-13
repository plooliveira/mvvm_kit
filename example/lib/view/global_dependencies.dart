import 'package:example_playground/core/routes/app_dependencies.dart';
import 'package:example_playground/objectbox.g.dart';
import 'package:get_it/get_it.dart';

class GlobalDependencies extends AppDependencies {
  @override
  Future<void> setup() async {
    GetIt.I.registerSingletonAsync<Store>(() async {
      return await openStore();
    });

    await GetIt.I.isReady<Store>();
  }
}
