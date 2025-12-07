import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gamble_record.dart';
import '../services/firestore_service.dart';
import '../widgets/result_card.dart';
import 'edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'mahjong', 'label': '麻雀', 'icon': Icons.casino},
    {'id': 'horse_racing', 'label': '競馬', 'icon': Icons.pets},
    {'id': 'boat_racing', 'label': '競艇', 'icon': Icons.directions_boat},
    {'id': 'auto_racing', 'label': 'オート', 'icon': Icons.motorcycle},
    {'id': 'keirin', 'label': '競輪', 'icon': Icons.directions_bike},
  ];

  void _navigateToEditScreen(BuildContext context, [GambleRecord? result]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(
          result: result,
          category: _categories[_currentIndex]['id'],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, GambleRecord result) async {
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
    final currentCategory = _categories[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentCategory['label']}収支管理'),
      ),
      body: StreamBuilder<List<GambleRecord>>(
        stream: _firestoreService.getResults(currentCategory['id']),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: _categories.map((category) {
          return BottomNavigationBarItem(
            icon: Icon(category['icon']),
            label: category['label'],
          );
        }).toList(),
      ),
    );
  }
}
