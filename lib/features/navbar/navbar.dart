import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/features/cart/cart_controller.dart';
import 'package:ai4bmi/routes/app_routes.dart';

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
        try {
          Get.find<CartController>().loadCart();
        } catch (_) {}
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
    Get.put(CartController(), permanent: true);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Accueil',
                index: 0,
                currentIndex: currentIndex,
                onTap: () => controller.changePage(0),
              ),
              Obx(() {
                final cart = Get.find<CartController>().cart.value;
                final count =
                    cart?.items.fold<int>(0, (s, i) => s + i.quantity) ?? 0;
                return _NavItem(
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag_rounded,
                  label: 'Panier',
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: () => controller.changePage(1),
                  badgeCount: count > 0 ? count : null,
                );
              }),
              _NavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'Commandes',
                index: 2,
                currentIndex: currentIndex,
                onTap: () => controller.changePage(2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profil',
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
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;
  final int? badgeCount;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.badgeCount,
  });

  bool get _isActive => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    final color = _isActive ? AppTheme.primary : const Color(0xFF9CA3AF);
    final showBadge = badgeCount != null && badgeCount! > 0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isActive ? 24 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: _isActive ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(_isActive ? activeIcon : icon, color: color, size: 26),
                if (showBadge)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badgeCount! > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: _isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
