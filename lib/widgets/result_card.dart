import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/horse_racing_result.dart';
import '../models/boat_racing_result.dart';
import '../models/auto_racing_result.dart';
import '../models/keirin_result.dart';

class ResultCard extends StatelessWidget {
  final dynamic result;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ResultCard({
    super.key,
    required this.result,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0", "ja_JP");
    final formattedDate = DateFormat('yyyy/MM/dd').format(result.date);
    final isPositive = result.amount >= 0;
    final amountColor = isPositive ? Colors.green : Colors.red;
    final amountText =
        '${isPositive ? '+' : ''}${currencyFormatter.format(result.amount)}';

    String? betType;
    if (result is HorseRacingResult) {
      betType = result.betType;
    } else if (result is BoatRacingResult) {
      betType = result.betType;
    } else if (result is AutoRacingResult) {
      betType = result.betType;
    } else if (result is KeirinResult) {
      betType = result.betType;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    if (betType != null && betType.isNotEmpty) ...[
                      Text(
                        betType,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                    ],
                    if (result.memo.isNotEmpty)
                      Text(
                        result.memo,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    amountText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: amountColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
