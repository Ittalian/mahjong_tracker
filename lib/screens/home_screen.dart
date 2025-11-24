import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mahjong_result.dart';
import '../services/firestore_service.dart';
import '../widgets/result_card.dart';
import 'edit_screen.dart';

class HomeScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  HomeScreen({super.key});

  void _navigateToEditScreen(BuildContext context, [MahjongResult? result]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(result: result),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, MahjongResult result) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('この記録を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && result.id != null) {
      await _firestoreService.deleteResult(result.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('麻雀収支管理'),
      ),
      body: StreamBuilder<List<MahjongResult>>(
        stream: _firestoreService.getResults(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = snapshot.data ?? [];
          final totalAmount =
              results.fold<int>(0, (sum, item) => sum + item.amount);
          final currencyFormatter = NumberFormat("#,##0", "ja_JP");

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                width: double.infinity,
                child: Column(
                  children: [
                    const Text(
                      '合計収支',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${totalAmount >= 0 ? '+' : ''}${currencyFormatter.format(totalAmount)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: totalAmount >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? const Center(child: Text('データがありません'))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          return ResultCard(
                            result: result,
                            onTap: () => _navigateToEditScreen(context, result),
                            onLongPress: () => _confirmDelete(context, result),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
