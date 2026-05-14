import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mahjong_result.dart';
import '../models/pachinko_result.dart';
import '../models/slot_result.dart';
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
    String? place;
    String? typeOrMachine;
    String? expectedSettingLabel; // スロット専用
    String? gamesStr;
    String? rbStr;
    String? bbStr;
    String? rbProbStr;
    String? bbProbStr;
    String? probStr;

    if (result is MahjongResult) {
      place = result.place;
      typeOrMachine = result.type;
    } else if (result is PachinkoResult) {
      place = result.place;
      typeOrMachine = result.machine;
    } else if (result is SlotResult) {
      place = result.place;
      typeOrMachine = result.machine;
      final setting = result.expectedSetting as int;
      if (setting > 0) {
        expectedSettingLabel = '設定$setting';
      }
      
      final res = result as SlotResult;
      if (res.totalGames != null || res.rbCount != null || res.bbCount != null) {
        gamesStr = res.totalGames?.toString() ?? '-';
        rbStr = res.rbCount?.toString() ?? '-';
        bbStr = res.bbCount?.toString() ?? '-';
        rbProbStr = '-';
        bbProbStr = '-';
        probStr = '-';
        if (res.totalGames != null && res.totalGames! > 0) {
          if (res.rbCount != null && res.rbCount! > 0) {
            rbProbStr = '1/${(res.totalGames! / res.rbCount!).toStringAsFixed(1)}';
          }
          if (res.bbCount != null && res.bbCount! > 0) {
            bbProbStr = '1/${(res.totalGames! / res.bbCount!).toStringAsFixed(1)}';
          }
          final totalBonus = (res.rbCount ?? 0) + (res.bbCount ?? 0);
          if (totalBonus > 0) {
            probStr = '1/${(res.totalGames! / totalBonus).toStringAsFixed(1)}';
          }
        }
      }
    } else if (result is HorseRacingResult) {
      betType = result.betType;
      place = result.place;
    } else if (result is BoatRacingResult) {
      betType = result.betType;
      place = result.place;
    } else if (result is AutoRacingResult) {
      betType = result.betType;
      place = result.place;
    } else if (result is KeirinResult) {
      betType = result.betType;
      place = result.place;
    }

    final bool hasBadges = (place != null && place.isNotEmpty) ||
        (typeOrMachine != null && typeOrMachine.isNotEmpty) ||
        (betType != null && betType.isNotEmpty) ||
        (expectedSettingLabel != null);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                    if (hasBadges) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: [
                          if (place != null && place.isNotEmpty)
                            _buildBadge(context, Icons.place, place),
                          if (typeOrMachine != null && typeOrMachine.isNotEmpty)
                            _buildBadge(
                                context, Icons.casino_outlined, typeOrMachine),
                          if (expectedSettingLabel != null)
                            _buildBadge(context, Icons.tune,
                                expectedSettingLabel),
                          if (betType != null && betType.isNotEmpty)
                            _buildBadge(
                                context, Icons.confirmation_number, betType),
                        ],
                      ),
                    ],
                    if (gamesStr != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: [
                          _buildStatBadge(context, 'G数', gamesStr, Colors.grey.shade700),
                          _buildStatBadge(context, 'RB', rbStr!, Colors.blue.shade700),
                          _buildStatBadge(context, 'BB', bbStr!, Colors.red.shade700),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: [
                          _buildStatBadge(context, 'RB確率', rbProbStr!, Colors.blue.shade700),
                          _buildStatBadge(context, 'BB確率', bbProbStr!, Colors.red.shade700),
                          _buildStatBadge(context, 'ペカリ確率', probStr!, Colors.orange.shade700),
                        ],
                      ),
                    ],
                    if (result.memo.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.notes,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              result.memo,
                              style:
                                  Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: amountColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    onPressed: onDelete,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(top: 8.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, IconData icon, String label) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
