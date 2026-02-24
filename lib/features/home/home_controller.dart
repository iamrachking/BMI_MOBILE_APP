import 'package:ai4bmi/data/models/category_model.dart';
import 'package:ai4bmi/data/models/product_model.dart';
import 'package:ai4bmi/data/services/product_service.dart';
import 'package:get/get.dart';

class BannerModel {
  final String title;
  final String subtitle;
  final String disclaimer;
  final String imageUrl;

  BannerModel({
    required this.title,
    required this.subtitle,
    required this.disclaimer,
    required this.imageUrl,
  });
}


class HomeController extends GetxController {

  final isLoadingCategories = true.obs;
  final isLoadingProducts= true.obs;
  final isLoadingMore = false.obs;
  final currentPage = 1.obs;
  final hasMorePages = true.obs;

  final banners = <BannerModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final products = <ProductModel>[].obs;
  
  final selectedCategory = 0.obs;
  final searchQuery = ''.obs;

  final ProductService _Products = ProductService();

  @override
  void onInit() {
    super.onInit();
    _loadBanner();
    fetchCategories();
    fetchProducts();
  }

  void _loadBanner() {
    banners.value = [
      BannerModel(
        title: 'BMI',
        subtitle: 'Bénin Moto Industry',
        disclaimer: 'Des pièces conçues par la précision industrielle.',
        imageUrl: 'assets/images/pieces.png',
      ),
    ];
  }
  
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      final response = await _Products.getCategories();

      if (response.data != null) {
        categories.value = response.data!;
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les catégories');
      print('fetchCategories error: $e');
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
      final catIndex = selectedCategory.value;
      if (catIndex > 0 && categories.isNotEmpty) {
        categoryId = categories[catIndex - 1].id;
      }

      final response = await _Products.getProducts(
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
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les produits');
      print('fetchProducts error: $e');
    } finally {
      isLoadingProducts.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreProducts() async {
    if (!hasMorePages.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    currentPage.value++;
    await fetchProducts(reset: false);
  }

  void selectCategory(int index) {
    selectedCategory.value = index;
    fetchProducts();
  }

  void onSearch(String query) {
    searchQuery.value = query;
    fetchProducts();
  }

  Future<void> refresh() async {
    await Future.wait([fetchCategories(), fetchProducts()]);
  }
}

  