import 'package:ai4bmi/data/models/category_model.dart';
import 'package:ai4bmi/data/models/product_model.dart';
import 'package:ai4bmi/data/services/product_service.dart';
import 'package:get/get.dart';

class CatalogController extends GetxController {
  final ProductService _productService = ProductService();

  final isLoadingCategories = true.obs;
  final isLoadingProducts = true.obs;
  final isLoadingMore = false.obs;
  final currentPage = 1.obs;
  final hasMorePages = true.obs;

  final categories = <CategoryModel>[].obs;
  final products = <ProductModel>[].obs;
  final selectedCategoryIndex = 0.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      final response = await _productService.getCategories();
      if (response.data != null) {
        categories.value = response.data!;
      }
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible de charger les catégories');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchProducts({bool reset = true}) async {
    if (reset) {
      currentPage.value = 1;
      hasMorePages.value = true;
      products.clear();
    }
    try {
      isLoadingProducts.value = true;
      int? categoryId;
      if (selectedCategoryIndex.value > 0 && categories.isNotEmpty) {
        categoryId = categories[selectedCategoryIndex.value - 1].id;
      }
      final response = await _productService.getProducts(
        categoryId: categoryId,
        search: searchQuery.value.trim().isNotEmpty
            ? searchQuery.value.trim()
            : null,
        perPage: 20,
        page: currentPage.value,
      );
      if (response.data != null) {
        if (reset) {
          products.value = response.data!;
        } else {
          products.addAll(response.data!);
        }
        hasMorePages.value = response.data!.length == 20;
      }
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible de charger les produits');
    } finally {
      isLoadingProducts.value = false;
      isLoadingMore.value = false;
    }
  }

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    fetchProducts();
  }

  void onSearch(String query) {
    searchQuery.value = query;
    fetchProducts();
  }

  Future<void> loadMore() async {
    if (!hasMorePages.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    currentPage.value++;
    await fetchProducts(reset: false);
  }

  @override
  Future<void> refresh() async {
    await Future.wait([fetchCategories(), fetchProducts()]);
  }
}
