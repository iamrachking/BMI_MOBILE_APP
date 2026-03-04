import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/storage/onboarding_storage.dart';
import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/routes/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Marquer comme vu dès l'affichage : au prochain lancement l'onboarding ne réapparaîtra pas.
    OnboardingStorage.setDone();
  }

  static const _pages = [
    _OnboardingSlide(
      imagePath: 'assets/images/onboarding_1.png',
      title: 'Trouvez vos pièces',
      subtitle: 'Parcourez notre vaste catalogue\nde pièces auto et moto.',
    ),
    _OnboardingSlide(
      imagePath: 'assets/images/onboarding_2.png',
      title: 'Commande et livraison faciles',
      subtitle: 'Paiement sécurisé et livraison rapide\njusqu\'à votre porte.',
    ),
    _OnboardingSlide(
      imagePath: 'assets/images/onboarding_3.png',
      title: 'Support expert et communauté',
      subtitle: 'Obtenez l\'aide d\'enthousiastes\net de professionnels.',
    ),
  ];

  Future<void> _finish() async {
    await OnboardingStorage.setDone();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) =>
                    _OnboardingImage(imagePath: _pages[i].imagePath),
              ),
            ),
            _buildIndicators(),
            _buildContent(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _pages.length,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == i ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == i
                  ? AppTheme.primary
                  : AppTheme.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final slide = _pages[_currentPage];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: const Color(0xFF1F2937).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final isLast = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: isLast
          ? FilledButton(
              onPressed: _finish,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('DÉMARRER'),
            )
          : Row(
              children: [
                TextButton(
                  onPressed: () => _finish(),
                  child: const Text(
                    'PASSER',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('SUIVANT'),
                ),
              ],
            ),
    );
  }
}

class _OnboardingSlide {
  final String imagePath;
  final String title;
  final String subtitle;

  const _OnboardingSlide({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

/// Image d’onboarding seule, sans carte — disposition comme sur les maquettes.
class _OnboardingImage extends StatelessWidget {
  final String imagePath;

  const _OnboardingImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
