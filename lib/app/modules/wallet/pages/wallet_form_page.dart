import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/wallet_type.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/nexflo_button.dart';
import '../../../domain/entities/wallet_entity.dart';
import '../../../services/currency_service.dart';

class WalletFormPage extends GetView<WalletController> {
  const WalletFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final existing = Get.arguments as WalletEntity?;
    final isEdit = existing != null;
    final isDark = context.isDarkMode;
    final hPad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(title: Text(isEdit ? 'Edit Wallet' : 'New Wallet')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + Type
            GlassCard(
              borderRadius: 18,
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  TextField(
                    controller: controller.nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Wallet Name',
                      hintText: 'e.g. Main Account',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.glassBorder : AppColors.grey200,
                  ),
                  Obx(() => DropdownButtonFormField<WalletType>(
                        value: controller.selectedType.value,
                        items: WalletType.values
                            .map((t) => DropdownMenuItem(
                                value: t, child: Text(t.label)))
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedType.value = v!,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Initial Balance — prominent card matching transaction amount style
            GlassCard(
              borderRadius: 18,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INITIAL BALANCE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : AppColors.grey400,
                    ),
                  ),
                  TextField(
                    controller: controller.balanceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.grey900,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : AppColors.grey300,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 14, 8, 0),
                        child: Text(
                          Get.find<CurrencyService>().currencySymbol,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tealMid,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Credit limit for credit card type
                  Obx(() {
                    if (controller.selectedType.value !=
                        WalletType.creditCard) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          height: 24,
                          color: isDark
                              ? AppColors.glassBorder
                              : AppColors.grey200,
                        ),
                        Text(
                          'CREDIT LIMIT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.grey400,
                          ),
                        ),
                        TextField(
                          controller: controller.creditLimitCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.grey900,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : AppColors.grey300,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0, 12, 8, 0),
                              child: Text(
                                Get.find<CurrencyService>().currencySymbol,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.tealMid,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Color picker
            _ColorPickerSection(controller, isDark: isDark),
            const SizedBox(height: 16),

            // Icon picker
            _IconPickerSection(controller, isDark: isDark),
            const SizedBox(height: 16),

            // Settings card
            GlassCard(
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Obx(() => SwitchListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(
                      'Exclude from Net Worth',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.grey900,
                      ),
                    ),
                    subtitle: Text(
                      'Savings goals / loans tracked separately',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : AppColors.grey400,
                      ),
                    ),
                    value: controller.isExcludeTotal.value,
                    onChanged: (v) => controller.isExcludeTotal.value = v,
                    activeColor: AppColors.tealMid,
                  )),
            ),
            const SizedBox(height: 28),

            Obx(() => NexFloButton(
                  label: isEdit ? 'Save Changes' : 'Create Wallet',
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.save(existing),
                  isLoading: controller.isLoading.value,
                  icon: isEdit
                      ? Icons.check_rounded
                      : Icons.account_balance_wallet_rounded,
                  width: double.infinity,
                )),
          ],
        ),
      ),
    );
  }
}

class _ColorPickerSection extends StatelessWidget {
  final WalletController ctrl;
  final bool isDark;
  const _ColorPickerSection(this.ctrl, {required this.isDark});

  static const _colors = [
    AppColors.tealMid,
    AppColors.blue,
    AppColors.purple,
    AppColors.green,
    AppColors.orange,
    AppColors.pink,
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFF9E9E9E),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COLOR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : AppColors.grey400,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colors
                    .map((c) => GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ctrl.selectedColor.value = c;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: ctrl.selectedColor.value == c
                                  ? Border.all(
                                      color: AppColors.tealMid,
                                      width: 3,
                                    )
                                  : Border.all(
                                      color: Colors.transparent,
                                      width: 3,
                                    ),
                              boxShadow: ctrl.selectedColor.value == c
                                  ? [
                                      BoxShadow(
                                        color: c.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ))
                    .toList(),
              )),
        ],
      ),
    );
  }
}

class _IconPickerSection extends StatelessWidget {
  final WalletController ctrl;
  final bool isDark;
  const _IconPickerSection(this.ctrl, {required this.isDark});

  static const _icons = [
    'wallet',
    'account_balance',
    'credit_card',
    'savings',
    'monetization_on',
    'payment',
    'local_atm',
    'shopping_bag',
    'work',
    'home',
    'directions_car',
    'flight',
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ICON',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : AppColors.grey400,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _icons
                    .map((name) => GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ctrl.selectedIcon.value = name;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: ctrl.selectedIcon.value == name
                                  ? AppColors.tealGlowSoft
                                  : (isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard),
                              borderRadius: BorderRadius.circular(12),
                              border: ctrl.selectedIcon.value == name
                                  ? Border.all(
                                      color: AppColors.tealMid,
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              IconMapper.get(name),
                              size: 22,
                              color: ctrl.selectedIcon.value == name
                                  ? AppColors.tealMid
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : AppColors.grey500),
                            ),
                          ),
                        ))
                    .toList(),
              )),
        ],
      ),
    );
  }
}
