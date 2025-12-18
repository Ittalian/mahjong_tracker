import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahjong_tracker/services/category_handler.dart';
import 'package:mahjong_tracker/services/mahjong/mahjong_service.dart';
import 'package:mahjong_tracker/services/horse_racing/horse_racing_service.dart';
import 'package:mahjong_tracker/services/boat_racing/boat_racing_service.dart';
import 'package:mahjong_tracker/services/auto_racing/auto_racing_service.dart';
import 'package:mahjong_tracker/services/keirin/keirin_service.dart';
import 'package:mahjong_tracker/services/pachinko/pachinko_service.dart';
import '../widgets/result_card.dart';
import 'edit_screen.dart';
import 'summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mahjongService = MahjongService();
  final _horseRacingService = HorseRacingService();
  final _boatRacingService = BoatRacingService();
  final _autoRacingService = AutoRacingService();
  final _keirinService = KeirinService();
  final _pachinkoService = PachinkoService();

  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'mahjong',
      'label': '麻雀',
      'display_name': '麻雀',
      'icon': Icons.casino,
      'type': 'mahjong'
    },
    {
      'id': 'horse_racing',
      'label': '競馬',
      'display_name': '競馬',
      'icon': Icons.pets,
      'type': 'horse_racing'
    },
    {
      'id': 'boat_racing',
      'label': '競艇',
      'display_name': 'ボートレース',
      'icon': Icons.directions_boat,
      'type': 'boat_racing'
    },
    {
      'id': 'auto_racing',
      'label': 'オート',
      'display_name': 'オートレース',
      'icon': Icons.motorcycle,
      'type': 'auto_racing'
    },
    {
      'id': 'keirin',
      'label': '競輪',
      'display_name': '競輪',
      'icon': Icons.directions_bike,
      'type': 'keirin'
    },
    {
      'id': 'pachinko',
      'label': 'パチンコ',
      'display_name': 'パチンコ',
      'icon': Icons.videogame_asset,
      'type': 'pachinko'
    },
  ];

  late final Map<String, CategoryHandler> _handlers = {
    'mahjong': CategoryHandler(
      streamGetter: () =>
          _mahjongService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _mahjongService.deleteResult(id),
      add: (result) => _mahjongService.addResult(result),
      update: (result) => _mahjongService.updateResult(result),
    ),
    'horse_racing': CategoryHandler(
      streamGetter: () =>
          _horseRacingService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _horseRacingService.deleteResult(id),
      add: (result) => _horseRacingService.addResult(result),
      update: (result) => _horseRacingService.updateResult(result),
    ),
    'boat_racing': CategoryHandler(
      streamGetter: () =>
          _boatRacingService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _boatRacingService.deleteResult(id),
      add: (result) => _boatRacingService.addResult(result),
      update: (result) => _boatRacingService.updateResult(result),
    ),
    'auto_racing': CategoryHandler(
      streamGetter: () =>
          _autoRacingService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _autoRacingService.deleteResult(id),
      add: (result) => _autoRacingService.addResult(result),
      update: (result) => _autoRacingService.updateResult(result),
    ),
    'keirin': CategoryHandler(
      streamGetter: () =>
          _keirinService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _keirinService.deleteResult(id),
      add: (result) => _keirinService.addResult(result),
      update: (result) => _keirinService.updateResult(result),
    ),
    'pachinko': CategoryHandler(
      streamGetter: () =>
          _pachinkoService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _pachinkoService.deleteResult(id),
      add: (result) => _pachinkoService.addResult(result),
      update: (result) => _pachinkoService.updateResult(result),
    ),
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void _navigateToEditScreen(BuildContext context, [dynamic result]) {
    if (_currentIndex >= _categories.length) {
      return;
    }

    final currentCategory = _categories[_currentIndex];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(
          result: result,
          categoryType: currentCategory['type'],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, dynamic result) async {
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
      final currentCategory = _categories[_currentIndex];
      await _handlers[currentCategory['type']]!.delete(result.id!);
    }
  }

  Stream<List<dynamic>> _getStreamForCategory(String type) {
    return _handlers[type]!.streamGetter();
  }

  Widget _buildCategoryPage(Map<String, dynamic> category) {
    return StreamBuilder<List<dynamic>>(
      stream: _getStreamForCategory(category['type']),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data ?? [];
        final int totalAmount =
            results.fold<int>(0, (sum, item) => sum + (item.amount as int));
        final currencyFormatter = NumberFormat("#,##0", "ja_JP");

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    '${category['display_name']} 合計収支',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      ..._categories.map((category) {
        return BottomNavigationBarItem(
          icon: Icon(category['icon']),
          label: category['label'],
        );
      }),
      const BottomNavigationBarItem(
        icon: Icon(Icons.summarize),
        label: '合計',
      ),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          ..._categories.map((category) => _buildCategoryPage(category)),
          const SummaryScreen(),
        ],
      ),
      floatingActionButton: _currentIndex < _categories.length
          ? FloatingActionButton(
              onPressed: () => _navigateToEditScreen(context),
              tooltip: '収支を追加',
              child: Icon(_categories[_currentIndex]['icon']),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }
}
