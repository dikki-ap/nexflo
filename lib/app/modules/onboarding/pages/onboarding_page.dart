import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/nexflo_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Stack(
        children: [
          // Ambient teal glow top-right
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealMid.withValues(
                    alpha: isDark ? 0.12 : 0.08),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Step dots indicator
                _StepIndicator(controller),
                // Pages
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _WelcomePage(controller),
                      _CurrencyPage(controller),
                      _CutoffDatePage(controller),
                      _FirstWalletPage(controller),
                      _DonePage(controller),
                    ],
                  ),
                ),
                // Bottom navigation
                _BottomNav(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final OnboardingController ctrl;
  const _StepIndicator(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Obx(() {
        final current = ctrl.currentPage.value;
        return Row(
          children: List.generate(OnboardingController.totalPages, (i) {
            final isActive = i == current;
            final isPast = i < current;
            return AnimatedContainer(
              duration: AppAnimations.normal,
              curve: AppAnimations.easeOutCubic,
              margin: const EdgeInsets.only(right: 6),
              width: isActive ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isPast || isActive
                    ? AppColors.tealMid
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.grey700
                        : AppColors.grey200),
              ),
            );
          }),
        );
      }),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final OnboardingController ctrl;
  const _WelcomePage(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = MediaQuery.of(context).size.width < 360 ? 20.0 : 28.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.tealGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tealGlow,
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.welcomeTitle,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.grey900,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            appTagline,
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.55)
                  : AppColors.grey500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          // Feature highlights
          ...[
            ('account_balance_wallet_rounded', 'Track all your wallets',
                'Multiple wallet types, custom icons and colors'),
            ('bar_chart_rounded', 'Beautiful analytics',
                'Charts, stats, and spending insights'),
            ('cloud_sync_rounded', 'Your data, your Drive',
                'Auto-sync to your own Google Sheets'),
          ].map((f) => _FeatureRow(
                icon: f.$1,
                title: f.$2,
                desc: f.$3,
                isDark: isDark,
              )),
          const Spacer(),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.desc,
    required this.isDark,
  });
  final String icon;
  final String title;
  final String desc;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.tealGlowSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              IconData(
                _iconCode(icon),
                fontFamily: 'MaterialIcons',
              ),
              color: AppColors.tealMid,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.grey900,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _iconCode(String name) => switch (name) {
        'account_balance_wallet_rounded' => 0xef63,
        'bar_chart_rounded' => 0xf164,
        'cloud_sync_rounded' => 0xe1a0,
        _ => 0xe3af,
      };
}

class _CurrencyPage extends StatelessWidget {
  final OnboardingController ctrl;
  const _CurrencyPage(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = MediaQuery.of(context).size.width < 360 ? 20.0 : 28.0;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _PageHeader(
            icon: Icons.currency_exchange_rounded,
            title: 'Base Currency',
            subtitle: AppStrings.selectCurrency,
            isDark: isDark,
          ),
          const SizedBox(height: 28),
          GlassCard(
            padding: const EdgeInsets.all(4),
            borderRadius: 16,
            child: Obx(() => DropdownButtonFormField<String>(
                  value: ctrl.selectedCurrencyCode.value,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Select currency',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: ctrl.currencyCodes
                      .map((code) => DropdownMenuItem(
                            value: code,
                            child: Text(code,
                                style: TextStyle(
                                    color: isDark ? Colors.white : AppColors.grey900)),
                          ))
                      .toList(),
                  onChanged: (v) => ctrl.selectedCurrencyCode.value = v!,
                )),
          ),
        ],
      ),
    );
  }
}

class _CutoffDatePage extends StatelessWidget {
  final OnboardingController ctrl;
  const _CutoffDatePage(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = MediaQuery.of(context).size.width < 360 ? 20.0 : 28.0;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _PageHeader(
            icon: Icons.calendar_today_rounded,
            title: 'Cutoff Date',
            subtitle: AppStrings.cutoffDateHint,
            isDark: isDark,
          ),
          const SizedBox(height: 28),
          GlassCard(
            padding: const EdgeInsets.all(4),
            borderRadius: 16,
            child: Obx(() => DropdownButtonFormField<int>(
                  value: ctrl.selectedCutoffDate.value,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Month starts on day',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: List.generate(28, (i) => i + 1)
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text('Day $d',
                                style: TextStyle(
                                    color: isDark ? Colors.white : AppColors.grey900)),
                          ))
                      .toList(),
                  onChanged: (v) => ctrl.selectedCutoffDate.value = v!,
                )),
          ),
        ],
      ),
    );
  }
}

class _FirstWalletPage extends StatelessWidget {
  final OnboardingController ctrl;
  const _FirstWalletPage(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = MediaQuery.of(context).size.width < 360 ? 20.0 : 28.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _PageHeader(
            icon: Icons.account_balance_wallet_rounded,
            title: 'First Wallet',
            subtitle: AppStrings.createFirstWallet,
            isDark: isDark,
          ),
          const SizedBox(height: 28),
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 20,
            child: Column(
              children: [
                Icon(
                  Icons.add_card_rounded,
                  size: 48,
                  color: AppColors.tealMid.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  'You can add wallets after setup\nfrom your Dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.grey500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonePage extends StatelessWidget {
  final OnboardingController ctrl;
  const _DonePage(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = MediaQuery.of(context).size.width < 360 ? 20.0 : 28.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.income, Color(0xFF16A34A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.income.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 28),
          Text(
            "You're all set!",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.grey900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start tracking your finances\nwith NexFlo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : AppColors.grey500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.tealGlowSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.tealMid.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, color: AppColors.tealMid, size: 26),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.grey900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : AppColors.grey500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  final OnboardingController ctrl;
  const _BottomNav(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width < 360 ? 20.0 : 24.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
      child: Obx(() {
        final isLast =
            ctrl.currentPage.value == OnboardingController.totalPages - 1;
        final isFirst = ctrl.currentPage.value == 0;
        return Row(
          children: [
            if (!isFirst)
              OutlinedButton(
                onPressed: ctrl.previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                ),
                child: const Text(AppStrings.back),
              ),
            const Spacer(),
            NexFloButton(
              label: isLast ? AppStrings.getStarted : AppStrings.next,
              onPressed: isLast
                  ? (ctrl.isLoading.value ? null : ctrl.complete)
                  : ctrl.nextPage,
              isLoading: isLast && ctrl.isLoading.value,
              icon: isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
            ),
          ],
        );
      }),
    );
  }
}
