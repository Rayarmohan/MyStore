import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ProductModel>> getProducts() async {
    return await _remoteDataSource.getProducts();
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    return await _remoteDataSource.getProduct(id);
  }
}
