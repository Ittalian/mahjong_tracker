import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahjong_tracker/models/race_draft.dart';
import 'package:mahjong_tracker/services/race_draft_service.dart';
import 'package:mahjong_tracker/widgets/race_bet_dialog.dart';

/// 複数レースの収支を一時保存し、当日の収支としてまとめて保存する画面
class RaceDraftScreen extends StatefulWidget {
  /// 競技 (horse_racing / boat_racing / auto_racing / keirin)。遷移元の画面で決まる。
  final String category;

  const RaceDraftScreen({super.key, required this.category});

  @override
  State<RaceDraftScreen> createState() => _RaceDraftScreenState();
}

class _RaceDraftScreenState extends State<RaceDraftScreen> {
  final _service = RaceDraftService();
  final _yen = NumberFormat('#,###');
  DateTime _date = DateTime.now();
  final _placeCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();

  @override
  void dispose() {
    _placeCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  String get _category => widget.category;
  String get _label => raceCategoryLabels[_category] ?? '';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _fmt(int v) => '${v >= 0 ? '+' : ''}${_yen.format(v)}円';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  /// [existing] を渡すと編集、省略すると新規追加
  Future<void> _showBetDialog({RaceDraft? existing}) async {
    final m = await showRaceBetDialog(
      context,
      category: _category,
      initial: existing == null
          ? null
          : {
              'betType': existing.betType,
              'amount': existing.amount,
              'raceName': existing.raceName,
              'memo': existing.memo,
            },
    );
    if (m == null) return;

    final draft = RaceDraft(
      id: existing?.id,
      category: _category,
      date: existing?.date ?? _date,
      place: '',
      raceName: m['raceName'],
      betType: m['betType'],
      amount: m['amount'],
      memo: m['memo'],
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    if (existing == null) {
      await _service.addDraft(draft);
    } else {
      await _service.updateDraft(draft);
    }
  }

  Future<void> _commit(List<RaceDraft> drafts) async {
    final total = drafts.fold<int>(0, (s, d) => s + d.amount);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('当日の収支として保存'),
        content: Text(
            '${drafts.length}レース 合計 ${_fmt(total)} を1件の収支として保存します。'
            '\n一時保存した記録は削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _service.commitDrafts(
        _category,
        drafts,
        place: _placeCtrl.text.trim(),
        memo: _memoCtrl.text.trim(),
      );
      if (!mounted) return;
      _placeCtrl.clear();
      _memoCtrl.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('当日の収支として保存しました')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$_label　収支計算')),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(DateFormat('yyyy/MM/dd (E)', 'ja').format(_date)),
            trailing: const Icon(Icons.edit),
            onTap: _pickDate,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<RaceDraft>>(
              stream: _service.getDrafts(_category),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('エラー: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final drafts = snapshot.data!
                    .where((d) => _isSameDay(d.date, _date))
                    .toList();
                final total = drafts.fold<int>(0, (s, d) => s + d.amount);

                return Column(
                  children: [
                    Expanded(
                      child: drafts.isEmpty
                          ? const Center(child: Text('この日の一時保存はありません'))
                          : ListView.separated(
                              itemCount: drafts.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final d = drafts[i];
                                final title = d.raceName;
                                return ListTile(
                                  title: Text(
                                      '${title.isEmpty ? 'レース' : title}  ${d.betType}'),
                                  subtitle:
                                      d.memo.isEmpty ? null : Text(d.memo),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _fmt(d.amount),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: d.amount >= 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: '削除',
                                        onPressed: () =>
                                            _service.deleteDraft(d.id!),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _showBetDialog(existing: d),
                                );
                              },
                            ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${drafts.length}レース 合計'),
                                Text(
                                  _fmt(total),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        total >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed:
                                    drafts.isEmpty ? null : () => _commit(drafts),
                                icon: const Icon(Icons.save),
                                label: const Text('当日の収支として保存'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBetDialog(),
        tooltip: 'レースを追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
