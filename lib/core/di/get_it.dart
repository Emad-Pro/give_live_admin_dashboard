import 'package:get_it/get_it.dart';

import '../../auth/view_model/auth_cubit.dart';

final getIt = GetIt.instance;

class ServicesLocator {
  static init() async {
    getIt.registerLazySingleton(() => AuthCubit());
  }
}
