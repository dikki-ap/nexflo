import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/wallet_entity.dart';

class TransactionTile extends StatelessWidget {
  final TransactionEntity tx;
  final CategoryEntity? category;
  final WalletEntity? wallet;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.tx,
    this.category,
    this.wallet,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.type == TransactionType.expense;
    final isTransfer = tx.type == TransactionType.transfer;
    final amountColor = isTransfer
        ? AppColors.transfer
        : isExpense
            ? AppColors.expense
            : AppColors.income;
    final sign = isExpense ? '-' : isTransfer ? '' : '+';

    final catColor = category != null
        ? ColorHelper.fromHex(category!.colorHex)
        : Colors.grey;
    final catIcon = category != null ? IconMapper.get(category!.iconName) : Icons.swap_horiz;

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete?.call();
        return false; // controller handles removal
      },
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(catIcon, color: catColor, size: 20),
        ),
        title: Text(
          category?.name ?? (isTransfer ? 'Transfer' : 'Uncategorized'),
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tx.note != null && tx.note!.isNotEmpty)
              Text(tx.note!,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5))),
            Text(
              wallet?.name ?? '',
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4)),
            ),
          ],
        ),
        trailing: Text(
          '$sign${_fmt(tx.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: amountColor,
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
