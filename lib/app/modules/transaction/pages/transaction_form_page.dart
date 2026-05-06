import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/nexflo_button.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../services/currency_service.dart';
import '../../../services/ocr_service.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  late final TransactionController controller;
  late final TransactionEntity? existing;
  late final bool isEdit;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TransactionController>();
    existing = Get.arguments as TransactionEntity?;
    isEdit = existing != null;
    controller.prepareForm(existing);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hPad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'New Transaction'),
        actions: [
          if (!isEdit)
            IconButton(
              icon: const Icon(Icons.document_scanner_outlined),
              tooltip: 'Scan Receipt',
              onPressed: () async {
                final result = await Get.toNamed(AppRoutes.receiptScan);
                if (result is OcrParseResult) {
                  controller.prefillFromReceipt(result);
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _TypeSelector(isDark: isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount card
                  GlassCard(
                    borderRadius: 18,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AMOUNT',
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
                          controller: controller.amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
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
                              padding:
                                  const EdgeInsets.fromLTRB(16, 14, 4, 0),
                              child: Text(
                                Get.find<CurrencyService>().baseCurrency,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.tealMid,
                                ),
                              ),
                            ),
                          ),
                          autofocus: !isEdit,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Wallet / Category card
                  GlassCard(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        // Wallet picker
                        Obx(() {
                          final wallets = controller.wallets;
                          final ids = wallets.map((w) => w.id).toSet();
                          final currentId = ids.contains(
                                  controller.selectedWalletId.value)
                              ? controller.selectedWalletId.value
                              : null;
                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: currentId,
                            items: wallets
                                .map((w) => DropdownMenuItem(
                                    value: w.id, child: Text(w.name)))
                                .toList(),
                            hint: const Text('Select wallet'),
                            onChanged: (v) =>
                                controller.selectedWalletId.value = v,
                            decoration: const InputDecoration(
                              labelText: 'From Wallet',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          );
                        }),
                        // To wallet (transfer only)
                        Obx(() {
                          if (controller.selectedTab.value != 2) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              Divider(
                                height: 1,
                                color: isDark
                                    ? AppColors.glassBorder
                                    : AppColors.grey200,
                              ),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: controller.selectedToWalletId.value,
                                items: controller.wallets
                                    .where((w) =>
                                        w.id !=
                                        controller.selectedWalletId.value)
                                    .map((w) => DropdownMenuItem(
                                        value: w.id,
                                        child: Text(w.name)))
                                    .toList(),
                                hint: const Text('Select wallet'),
                                onChanged: (v) =>
                                    controller.selectedToWalletId.value = v,
                                decoration: const InputDecoration(
                                  labelText: 'To Wallet',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          );
                        }),
                        // Category picker (non-transfer)
                        Obx(() {
                          if (controller.selectedTab.value == 2) {
                            return const SizedBox.shrink();
                          }
                          final isExpense = controller.selectedTab.value == 0;
                          final cats = isExpense
                              ? controller.categories
                                  .where((c) =>
                                      c.type.name == 'expense' ||
                                      c.type.name == 'both')
                                  .toList()
                              : controller.categories
                                  .where((c) =>
                                      c.type.name == 'income' ||
                                      c.type.name == 'both')
                                  .toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                height: 1,
                                color: isDark
                                    ? AppColors.glassBorder
                                    : AppColors.grey200,
                              ),
                              DropdownButtonFormField<String>(
                                value: controller.selectedCategoryId.value,
                                items: cats
                                    .map((c) => DropdownMenuItem(
                                        value: c.id, child: Text(c.name)))
                                    .toList(),
                                onChanged: (v) =>
                                    controller.selectedCategoryId.value = v,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                              // Subcategory chips
                              if (controller.subcategories.isNotEmpty)
                                _SubcategoryChips(isDark: isDark),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date + Note card
                  GlassCard(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        Obx(() => InkWell(
                              onTap: () => _pickDate(context),
                              borderRadius: BorderRadius.circular(14),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  suffixIcon:
                                      Icon(Icons.calendar_today_rounded),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                child: Text(
                                    _formatDate(controller.selectedDate.value)),
                              ),
                            )),
                        Divider(
                          height: 1,
                          color:
                              isDark ? AppColors.glassBorder : AppColors.grey200,
                        ),
                        TextField(
                          controller: controller.noteCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Note (optional)',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  Obx(() => NexFloButton(
                        label: isEdit ? 'Save Changes' : 'Add Transaction',
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.saveTransaction(existing),
                        isLoading: controller.isLoading.value,
                        icon: isEdit
                            ? Icons.check_rounded
                            : Icons.add_rounded,
                        width: double.infinity,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) controller.selectedDate.value = picked;
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_month(d.month)} ${d.year}';

  String _month(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];
}

class _SubcategoryChips extends GetView<TransactionController> {
  final bool isDark;
  const _SubcategoryChips({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final subs = controller.subcategories;
      if (subs.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            height: 1,
            color: isDark ? AppColors.glassBorder : AppColors.grey200,
          ),
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SUBCATEGORY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : AppColors.grey400,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // None chip
                    GestureDetector(
                      onTap: () =>
                          controller.selectedSubcategoryId.value = null,
                      child: AnimatedContainer(
                        duration: AppAnimations.fast,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: controller.selectedSubcategoryId.value == null
                              ? AppColors.tealMid.withValues(alpha: 0.15)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : AppColors.grey100),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                controller.selectedSubcategoryId.value == null
                                    ? AppColors.tealMid
                                    : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'None',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: controller.selectedSubcategoryId.value ==
                                    null
                                ? AppColors.tealMid
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : AppColors.grey500),
                          ),
                        ),
                      ),
                    ),
                    ...subs.map((s) {
                      final hex = s.colorHex.replaceAll('#', '');
                      final color = Color(int.parse('FF$hex', radix: 16));
                      final isSelected =
                          controller.selectedSubcategoryId.value == s.id;
                      return GestureDetector(
                        onTap: () =>
                            controller.selectedSubcategoryId.value = s.id,
                        child: AnimatedContainer(
                          duration: AppAnimations.fast,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.15)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : AppColors.grey100),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(IconMapper.get(s.iconName),
                                  size: 12,
                                  color: isSelected
                                      ? color
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.4)
                                          : AppColors.grey400)),
                              const SizedBox(width: 4),
                              Text(
                                s.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? color
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.5)
                                          : AppColors.grey500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _TypeSelector extends StatelessWidget {
  final bool isDark;
  const _TypeSelector({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.horizontalPadding,
        12,
        context.horizontalPadding,
        4,
      ),
      child: GlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _PillTab('Expense', 0, AppColors.expense),
            _PillTab('Income', 1, AppColors.income),
            _PillTab('Transfer', 2, AppColors.transfer),
          ],
        ),
      ),
    );
  }
}

class _PillTab extends GetView<TransactionController> {
  final String label;
  final int index;
  final Color color;
  const _PillTab(this.label, this.index, this.color);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Obx(() {
        final selected = controller.selectedTab.value == index;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            controller.selectedTab.value = index;
          },
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            curve: AppAnimations.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? color
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
                color: selected
                    ? Colors.white
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : AppColors.grey500),
              ),
            ),
          ),
        );
      }),
    );
  }
}
