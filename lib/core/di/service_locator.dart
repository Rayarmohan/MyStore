import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../database/app_database.dart';
import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/product/data/repositories/product_repository.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/bloc/product_bloc.dart';
import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/data/repositories/cart_repository.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/bloc/cart_bloc.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSource(sl<AppDatabase>()),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductRemoteDataSource>()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartLocalDataSource>()),
  );

  sl.registerLazySingleton<ProductBloc>(
    () => ProductBloc(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<CartBloc>(
    () => CartBloc(sl<CartRepository>()),
  );
}
