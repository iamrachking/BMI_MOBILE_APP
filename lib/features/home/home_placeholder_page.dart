import 'package:ai4bmi/data/models/category_model.dart';
import 'package:ai4bmi/data/models/product_model.dart';
import 'package:ai4bmi/features/navbar/navbar.dart';
import 'package:ai4bmi/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'home_controller.dart';
import 'package:get/get.dart';

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBF8),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD8CCF0),
              Color(0xFFE8D8F0),
              Color(0xFFF0DCE8),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFFF57C2B),
            onRefresh: controller.refresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scroll) {
                if (scroll.metrics.pixels >=
                    scroll.metrics.maxScrollExtent - 300) {
                  controller.loadMoreProducts();
                }
                return false;
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [

                  //Barre de recherche 
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: TextField(
                                onChanged: controller.onSearch,
                                decoration: const InputDecoration(
                                  hintText: 'Search products',
                                  hintStyle: TextStyle(
                                      color: Color(0xFFAAAAAA), fontSize: 14),
                                  prefixIcon: Icon(Icons.search,
                                      color: Color(0xFFAAAAAA), size: 22),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  SliverToBoxAdapter(
                    child: Obx(() {
                      if (controller.banners.isEmpty) return const SizedBox();
                      return _PromoBanner(banner: controller.banners.first);
                    }),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  SliverToBoxAdapter(
                    child: Obx(() {
                      if (controller.isLoadingCategories.value) {
                        return _CategoriesSkeleton();
                      }

                      final List<CategoryModel> allCategories = [
                        CategoryModel(id: 0, name: 'Tous', description: ''),
                        ...controller.categories,
                      ];


                      return SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: allCategories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final cat = allCategories[index];
                            return Obx(() {
                              final isSelected =
                                  controller.selectedCategory.value == index;
                              return GestureDetector(
                                onTap: () => controller.selectCategory(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.08),
                                              blurRadius: 10,
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? const Color(0xFF1A1A2E)
                                          : const Color(0xFF888899),
                                    ),
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      );
                    }),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            'Produits',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 36,
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE84C1E),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  //Grille des produits 
                  Obx(() {
                    if (controller.isLoadingProducts.value &&
                        controller.products.isEmpty) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (_, __) => _ProductCardSkeleton(),
                            childCount: 6,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.75,
                          ),
                        ),
                      );
                    }

                    if (controller.products.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Text(
                              'Aucun produit trouvé',
                              style: TextStyle(
                                  color: Color(0xFF888899), fontSize: 15),
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _ProductCard(
                              product: controller.products[index]),
                          childCount: controller.products.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.75,
                        ),
                      ),
                    );
                  }),

                  SliverToBoxAdapter(
                    child: Obx(() {
                      if (!controller.isLoadingMore.value) {
                        return const SizedBox(height: 24);
                      }
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF57C2B),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  final BannerModel banner;
  const _PromoBanner({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 108, 57, 167), Color.fromARGB(255, 71, 31, 134)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (banner.imageUrl.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(204, 110, 61, 167), Color.fromARGB(0, 24, 24, 24)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    banner.subtitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner.disclaimer,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.productDetail, arguments: product),
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              child: Center(
                child: product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.contain,
                          width: 130,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_outlined,
                                  size: 60, color: Color(0xFFCCCCCC)),
                        ),
                      )
                    : const Icon(Icons.image_outlined,
                        size: 60, color: Color(0xFFCCCCCC)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 37, 37, 38),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$ ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 19, 19, 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  chargement

class _CategoriesSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(32),
          ),
        ),

      ),
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => Container(
          width: 170,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}