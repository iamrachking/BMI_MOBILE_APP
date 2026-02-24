import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai4bmi/routes/app_routes.dart';

// Controller du menu 

class NavbarController extends GetxController {
  final currentIndex = 0.obs;

  void goToCatalog() => Get.toNamed(AppRoutes.catalog);
  void goToCart() => Get.toNamed(AppRoutes.cart);
  void goToOrders() => Get.toNamed(AppRoutes.orders);
  void goToProfile() => Get.toNamed(AppRoutes.profile);


  void changePage(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0:
        Get.toNamed('/home');
        break;
      case 1:
        Get.toNamed('/cart');
        break;
      case 2:
        Get.toNamed('/orders');
        break;
      case 3:
        Get.toNamed('/profile');
        break;
    }
  }
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavbarController(), permanent: true);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        )
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                index: 0,
                currentIndex: currentIndex,
                onTap: () => controller.changePage(0),
                isHighlighted: currentIndex == 0,
              ),
              _NavItem(
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                index: 1,
                currentIndex: currentIndex,
                onTap: () => controller.changePage(1),
              ),
              _NavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                index: 2,
                currentIndex: currentIndex,
                onTap: () => controller.changePage(2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                index: 3,
                currentIndex: currentIndex,
                onTap: () => controller.changePage(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.isHighlighted = false,
  });

  bool get _isActive => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    if (isHighlighted && _isActive) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF57C2B),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              Icon(activeIcon, color: Colors.white, size: 22),
              const SizedBox(width: 6),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isActive ? activeIcon : icon,
            color: _isActive
                ? const Color(0xFFF57C2B)
                : const Color(0xFFAAAAAA),
            size: 26,
          ),
        ],
      ),
    );
  }
}