import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../services/currency_service.dart';
import '../controllers/statistics_controller.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({super.key});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late final CategoryAmount ca;
  late final StatisticsController ctrl;
  List<SubcategoryAmount> _subcats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    ca = Get.arguments as CategoryAmount;
    ctrl = Get.find<StatisticsController>();
    _load();
  }

  Future<void> _load() async {
    if (ca.category == null) {
      setState(() => _loading = false);
      return;
    }
    final result = await ctrl.getSubcategoryBreakdown(ca.category!.id);
    setState(() {
      _subcats = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hPad = context.horizontalPadding;
    final sym = Get.find<CurrencyService>().currencySymbol;
    final color = ca.category != null
        ? ColorHelper.fromHex(ca.category!.colorHex)
        : Colors.grey;

    final txs = ca.category != null
        ? ctrl.getTransactionsByCategory(ca.category!.id)
        : [];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(ca.category?.name ?? 'Uncategorized'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 40),
              children: [
                // Total card
                GlassCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL SPENT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : AppColors.grey400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$sym ${_fmt(ca.amount)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${txs.length} transaction${txs.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Subcategory breakdown
                if (_subcats.isNotEmpty) ...[
                  GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BY SUBCATEGORY',
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
                        ..._subcats.map((s) => _SubcatRow(
                              s: s,
                              color: color,
                              sym: sym,
                              isDark: isDark,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Transaction list
                if (txs.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      'TRANSACTIONS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : AppColors.grey400,
                      ),
                    ),
                  ),
                  GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: txs.map((tx) {
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.expense.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.remove_rounded,
                                color: AppColors.expense, size: 18),
                          ),
                          title: Text(
                            tx.note ?? 'No note',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            _fmtDate(tx.date),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : AppColors.grey400,
                            ),
                          ),
                          trailing: Text(
                            '- $sym ${_fmt(tx.amount)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.expense,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  String _fmt(double v) {
    final absStr = NumberFormat('#,##0').format(v.abs());
    return v < 0 ? '-$absStr' : absStr;
  }

  String _fmtDate(DateTime d) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month]} ${d.year}';
  }
}

class _SubcatRow extends StatelessWidget {
  final SubcategoryAmount s;
  final Color color;
  final String sym;
  final bool isDark;

  const _SubcatRow({
    required this.s,
    required this.color,
    required this.sym,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  s.subcategory?.name ?? 'No subcategory',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.grey900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$sym ${_fmt(s.amount)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${s.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : AppColors.grey400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: s.percentage / 100,
              minHeight: 4,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.grey200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    final absStr = NumberFormat('#,##0').format(v.abs());
    return v < 0 ? '-$absStr' : absStr;
  }
}
