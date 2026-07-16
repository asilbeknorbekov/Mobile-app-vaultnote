import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:anote/core/icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/design_system/glass_surface.dart';
import '../../../../core/design_system/glass_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await prefs.setString('user_name', name);
    }
    
    if (!mounted) return;
    context.go('/home');
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GlassTheme.buildBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    _buildPage(
                      context,
                      icon: LucideIcons.brainCircuit,
                      title: 'Your Second Brain',
                      description: 'VaultNote securely stores your thoughts, documents, and recordings so you never forget a thing.',
                    ),
                    _buildPage(
                      context,
                      icon: LucideIcons.lock,
                      title: 'Bank-Grade Security',
                      description: 'Everything you save is AES-256 encrypted on-device. Not even we can read your notes.',
                    ),
                    _buildNameInputPage(context),
                  ],
                ),
              ),
              _buildBottomControls(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, {required IconData icon, required String title, required String description, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassSurface(
            tier: GlassTier.tier1,
            padding: const EdgeInsets.all(32),
            borderRadius: BorderRadius.circular(48),
            child: Icon(icon, size: 80, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(fontSize: 18, color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
          if (isLast) ...[
            const SizedBox(height: 48),
            GlassSurface(
              tier: GlassTier.tier2,
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Icon(LucideIcons.mic, color: Colors.grey),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text('We need microphone access to record voice notes.', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _completeOnboarding,
            child: const Text('Skip', style: TextStyle(color: Colors.grey)),
          ),
          Row(
            children: List.generate(3, (index) => _buildDot(index)),
          ),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            ),
            child: Text(_currentPage == 2 ? 'Get Started' : 'Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInputPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassSurface(
            tier: GlassTier.tier1,
            padding: const EdgeInsets.all(32),
            borderRadius: BorderRadius.circular(48),
            child: Icon(LucideIcons.user, size: 80, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 48),
          const Text(
            "What's your name?",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'We would love to know what to call you.',
            style: TextStyle(fontSize: 18, color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GlassSurface(
            tier: GlassTier.tier2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: BorderRadius.circular(16),
            child: TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
              ],
              decoration: const InputDecoration(
                hintText: 'e.g. Asilbek',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
