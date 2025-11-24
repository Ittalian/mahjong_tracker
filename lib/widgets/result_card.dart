import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mahjong_result.dart';

class ResultCard extends StatelessWidget {
  final MahjongResult result;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ResultCard({
    super.key,
    required this.result,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0", "ja_JP");
    final formattedDate = DateFormat('yyyy/MM/dd').format(result.date);
    final isPositive = result.amount >= 0;
    final amountColor = isPositive ? Colors.green : Colors.red;
    final amountText =
        '${isPositive ? '+' : ''}${currencyFormatter.format(result.amount)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  if (result.memo.isNotEmpty)
                    Text(
                      result.memo,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
              Text(
                amountText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
