import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mahjong_tracker/services/mahjong/mahjong_service.dart';
import 'package:mahjong_tracker/services/horse_racing/horse_racing_service.dart';
import 'package:mahjong_tracker/services/boat_racing/boat_racing_service.dart';
import 'package:mahjong_tracker/services/auto_racing/auto_racing_service.dart';
import 'package:mahjong_tracker/services/keirin/keirin_service.dart';
import 'package:mahjong_tracker/services/pachinko/pachinko_service.dart';

class SummaryScreen extends StatelessWidget {
  final Function(int)? onNavigateToCategory;

  const SummaryScreen({
    super.key,
    this.onNavigateToCategory,
  });

  Stream<int> _getTotal(Stream<List<dynamic>> stream) {
    return stream.map(
        (list) => list.fold<int>(0, (sum, item) => sum + (item.amount as int)));
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0", "ja_JP");

    final mahjongStream = _getTotal(MahjongService().getResults());
    final horseStream = _getTotal(HorseRacingService().getResults());
    final boatStream = _getTotal(BoatRacingService().getResults());
    final autoStream = _getTotal(AutoRacingService().getResults());
    final keirinStream = _getTotal(KeirinService().getResults());
    final pachinkoStream = _getTotal(PachinkoService().getResults());

    return StreamBuilder<List<int>>(
      stream: CombineLatestStream.list([
        mahjongStream,
        horseStream,
        boatStream,
        autoStream,
        keirinStream,
        pachinkoStream,
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final totals = snapshot.data!;
        final mahjongTotal = totals[0];
        final horseTotal = totals[1];
        final boatTotal = totals[2];
        final autoTotal = totals[3];
        final keirinTotal = totals[4];
        final pachinkoTotal = totals[5];

        final grandTotal = mahjongTotal +
            horseTotal +
            boatTotal +
            autoTotal +
            keirinTotal +
            pachinkoTotal;

        final categories = [
          { 'label': '麻雀', 'total': mahjongTotal, 'icon': Icons.casino },
          { 'label': '競馬', 'total': horseTotal, 'icon': Icons.pets },
          { 'label': 'ボートレース', 'total': boatTotal, 'icon': Icons.directions_boat },
          { 'label': 'オートレース', 'total': autoTotal, 'icon': Icons.motorcycle },
          { 'label': '競輪', 'total': keirinTotal, 'icon': Icons.directions_bike },
          { 'label': 'パチンコ', 'total': pachinkoTotal, 'icon': Icons.videogame_asset },
        ];

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              width: double.infinity,
              child: Column(
                children: [
                  const Text(
                    '総合計収支',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${grandTotal >= 0 ? '+' : ''}${currencyFormatter.format(grandTotal)}',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: grandTotal >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final total = category['total'] as int;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(category['icon'] as IconData,
                          color: Theme.of(context).primaryColor),
                    ),
                    title: Text(category['label'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      '${total >= 0 ? '+' : ''}${currencyFormatter.format(total)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: total >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    onTap: () => onNavigateToCategory?.call(index),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
