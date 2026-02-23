import 'package:get/get.dart';

import 'package:ai4bmi/data/models/category_model.dart';
import 'package:ai4bmi/data/models/product_model.dart';
import 'package:ai4bmi/data/services/product_service.dart';
import 'package:ai4bmi/routes/app_routes.dart';

class CatalogController extends GetxController {
  final ProductService _productService = ProductService();

  final loading = true.obs;
  final categories = <CategoryModel>[].obs;
  final products = <ProductModel>[].obs;
  final selectedCategoryId = Rx<int?>(null);
  final searchQuery = ''.obs;

  @override
  void onReady() {
    loadCategories();
    loadProducts();
    super.onReady();
  }

  Future<void> loadCategories() async {
    try {
      final res = await _productService.getCategories(perPage: 50);
      if (res.success && res.data != null) {
        categories.value = res.data!;
      }
    } catch (_) {}
  }

  Future<void> loadProducts() async {
    loading.value = true;
    try {
      final res = await _productService.getProducts(
        categoryId: selectedCategoryId.value,
        search:
            searchQuery.value.isEmpty ? null : searchQuery.value,
        perPage: 50,
      );
      if (res.success && res.data != null) {
        products.value = res.data!;
      }
    } catch (_) {
      products.clear();
    } finally {
      loading.value = false;
    }
  }

  void filterByCategory(int? id) {
    selectedCategoryId.value = id;
    loadProducts();
  }

  void search(String query) {
    searchQuery.value = query;
    loadProducts();
  }

  void openProduct(int productId) {
    Get.toNamed(AppRoutes.productDetail, arguments: productId);
  }
}
