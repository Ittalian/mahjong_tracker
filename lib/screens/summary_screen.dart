import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../services/firestore_service.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  Stream<int> _getTotal(Stream<List<dynamic>> stream) {
    return stream.map(
        (list) => list.fold<int>(0, (sum, item) => sum + (item.amount as int)));
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final currencyFormatter = NumberFormat("#,##0", "ja_JP");

    final mahjongStream = _getTotal(firestoreService.getMahjongResults());
    final horseStream = _getTotal(firestoreService.getHorseRacingResults());
    final boatStream = _getTotal(firestoreService.getBoatRacingResults());
    final autoStream = _getTotal(firestoreService.getAutoRacingResults());
    final keirinStream = _getTotal(firestoreService.getKeirinResults());
    final pachinkoStream = _getTotal(firestoreService.getPachinkoResults());

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
          {
            'label': '麻雀',
            'total': mahjongTotal,
            'icon': Icons.casino,
          },
          {
            'label': '競馬',
            'total': horseTotal,
            'icon': Icons.pets,
          },
          {
            'label': 'ボートレース',
            'total': boatTotal,
            'icon': Icons.directions_boat,
          },
          {
            'label': 'オートレース',
            'total': autoTotal,
            'icon': Icons.motorcycle,
          },
          {
            'label': '競輪',
            'total': keirinTotal,
            'icon': Icons.directions_bike,
          },
          {
            'label': 'パチンコ',
            'total': pachinkoTotal,
            'icon': Icons.videogame_asset,
          },
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
