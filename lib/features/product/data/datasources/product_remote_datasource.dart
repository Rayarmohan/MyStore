import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSource(this._apiClient);

  Future<List<ProductModel>> getProducts() async {
    final data = await _apiClient.getProducts();
    return data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductModel> getProduct(int id) async {
    final data = await _apiClient.getProduct(id);
    return ProductModel.fromJson(data);
  }
}
