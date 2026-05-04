import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Obx(() => LinearProgressIndicator(
                  value: (controller.currentPage.value + 1) /
                      OnboardingController.totalPages,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  minHeight: 3,
                )),
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
            // Navigation buttons
            _BottomNav(controller),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final OnboardingController ctrl;
  const _WelcomePage(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: const Icon(Icons.account_balance_wallet,
                color: Colors.white, size: 52),
          ),
          const SizedBox(height: 32),
          Text(AppStrings.welcomeTitle,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(appTagline,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _CurrencyPage extends StatelessWidget {
  final OnboardingController ctrl;
  const _CurrencyPage(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text('Base Currency',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(AppStrings.selectCurrency,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
          const SizedBox(height: 24),
          Obx(() => DropdownButtonFormField<String>(
                value: ctrl.selectedCurrencyCode.value,
                items: ctrl.currencyCodes
                    .map((code) =>
                        DropdownMenuItem(value: code, child: Text(code)))
                    .toList(),
                onChanged: (v) => ctrl.selectedCurrencyCode.value = v!,
                decoration: const InputDecoration(labelText: 'Currency'),
              )),
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
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text('Cutoff Date',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(AppStrings.cutoffDateHint,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
          const SizedBox(height: 24),
          Obx(() => DropdownButtonFormField<int>(
                value: ctrl.selectedCutoffDate.value,
                items: List.generate(28, (i) => i + 1)
                    .map((d) =>
                        DropdownMenuItem(value: d, child: Text('Day $d')))
                    .toList(),
                onChanged: (v) => ctrl.selectedCutoffDate.value = v!,
                decoration:
                    const InputDecoration(labelText: 'Month starts on day'),
              )),
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
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text('First Wallet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(AppStrings.createFirstWallet,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
          const SizedBox(height: 32),
          // TODO(phase-2): inline wallet creation form
          Center(
            child: Text(
              'Wallet creation will be available\nafter setup. You can add wallets\nfrom the dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5)),
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
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: accent, size: 80),
          const SizedBox(height: 24),
          const Text("You're all set!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            'Start tracking your finances with NexFlo.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final OnboardingController ctrl;
  const _BottomNav(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Obx(() {
        final isLast = ctrl.currentPage.value ==
            OnboardingController.totalPages - 1;
        final isFirst = ctrl.currentPage.value == 0;
        return Row(
          children: [
            if (!isFirst)
              OutlinedButton(
                onPressed: ctrl.previousPage,
                child: const Text(AppStrings.back),
              ),
            const Spacer(),
            if (isLast)
              ElevatedButton(
                onPressed: ctrl.isLoading.value ? null : ctrl.complete,
                child: ctrl.isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(AppStrings.getStarted),
              )
            else
              ElevatedButton(
                onPressed: ctrl.nextPage,
                child: const Text(AppStrings.next),
              ),
          ],
        );
      }),
    );
  }
}
