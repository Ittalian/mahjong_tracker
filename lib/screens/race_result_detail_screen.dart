import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahjong_tracker/services/race_draft_service.dart';
import 'package:mahjong_tracker/services/auto_racing/auto_racing_service.dart';
import 'package:mahjong_tracker/services/boat_racing/boat_racing_service.dart';
import 'package:mahjong_tracker/services/horse_racing/horse_racing_service.dart';
import 'package:mahjong_tracker/services/keirin/keirin_service.dart';
import 'package:mahjong_tracker/widgets/race_bet_dialog.dart';

/// 保存済みの1日分の収支について、各レースの収支を表示・編集・削除する画面
class RaceResultDetailScreen extends StatefulWidget {
  final String category;

  /// HorseRacingResult / BoatRacingResult / AutoRacingResult / KeirinResult
  final dynamic result;

  const RaceResultDetailScreen({
    super.key,
    required this.category,
    required this.result,
  });

  @override
  State<RaceResultDetailScreen> createState() => _RaceResultDetailScreenState();
}

class _RaceResultDetailScreenState extends State<RaceResultDetailScreen> {
  final _service = RaceDraftService();
  final _yen = NumberFormat('#,###');
  late List<Map<String, dynamic>> _bets;
  late final TextEditingController _placeCtrl;
  late final TextEditingController _memoCtrl;

  String get _label => raceCategoryLabels[widget.category] ?? '';
  DateTime get _date => widget.result.date as DateTime;

  @override
  void initState() {
    super.initState();
    _placeCtrl = TextEditingController(text: widget.result.place as String);
    _memoCtrl = TextEditingController(text: widget.result.memo as String);
    final List raw = widget.result.bets as List;
    _bets = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    // 内訳を持たない旧データは、記録全体を1レースとして扱う
    if (_bets.isEmpty) {
      _bets = [
        {
          'betType': widget.result.betType,
          'amount': widget.result.amount,
          'raceName': '',
          'memo': '',
        }
      ];
    }
  }

  @override
  void dispose() {
    _placeCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  String _fmt(int v) => '${v >= 0 ? '+' : ''}${_yen.format(v)}円';

  int get _total => _bets.fold<int>(0, (s, b) => s + (b['amount'] as int));

  Future<void> _delete() async {
    final id = widget.result.id as String?;
    if (id == null) return;
    switch (widget.category) {
      case 'horse_racing':
        await HorseRacingService().deleteResult(id);
        break;
      case 'boat_racing':
        await BoatRacingService().deleteResult(id);
        break;
      case 'auto_racing':
        await AutoRacingService().deleteResult(id);
        break;
      case 'keirin':
        await KeirinService().deleteResult(id);
        break;
    }
  }

  Future<void> _persist() async {
    try {
      if (_bets.isEmpty) {
        await _delete();
        if (mounted) Navigator.pop(context);
        return;
      }
      await _service.saveDay(
        widget.category,
        id: widget.result.id as String?,
        date: _date,
        bets: _bets,
        place: _placeCtrl.text.trim(),
        memo: _memoCtrl.text.trim(),
        createdAt: widget.result.createdAt as DateTime,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    }
  }

  Future<void> _addOrEdit({int? index}) async {
    final m = await showRaceBetDialog(
      context,
      category: widget.category,
      initial: index == null ? null : _bets[index],
    );
    if (m == null) return;
    setState(() {
      if (index == null) {
        _bets.add(m);
      } else {
        _bets[index] = m;
      }
    });
    await _persist();
  }

  Future<void> _deleteBet(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('削除確認'),
        content: Text(_bets.length == 1
            ? 'このレースを削除すると、この日の記録も削除されます。よろしいですか？'
            : 'このレースを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _bets.removeAt(index));
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('yyyy/MM/dd (E)', 'ja').format(_date);
    return Scaffold(
      appBar: AppBar(title: Text('$_label　$dateText')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Focus(
              onFocusChange: (focused) {
                if (!focused) _persist();
              },
              child: Column(
                children: [
                  TextField(
                    controller: _placeCtrl,
                    decoration: const InputDecoration(labelText: '開催場所'),
                  ),
                  TextField(
                    controller: _memoCtrl,
                    decoration: const InputDecoration(labelText: 'メモ'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _bets.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final b = _bets[i];
                final amount = b['amount'] as int;
                final title = (b['raceName'] as String?) ?? '';
                final memo = (b['memo'] as String?) ?? '';
                return ListTile(
                  title:
                      Text('${title.isEmpty ? 'レース' : title}  ${b['betType']}'),
                  subtitle: memo.isEmpty ? null : Text(memo),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _fmt(amount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: amount >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: '削除',
                        onPressed: () => _deleteBet(i),
                      ),
                    ],
                  ),
                  onTap: () => _addOrEdit(index: i),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_bets.length}レース 合計'),
                      Text(
                        _fmt(_total),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _total >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        tooltip: 'レースを追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
