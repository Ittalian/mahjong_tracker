import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mahjong_tracker/models/auto_racing_result.dart';
import 'package:mahjong_tracker/models/boat_racing_result.dart';
import 'package:mahjong_tracker/models/horse_racing_result.dart';
import 'package:mahjong_tracker/models/keirin_result.dart';

/// レース系競技の表示名
const Map<String, String> raceCategoryLabels = {
  'horse_racing': '競馬',
  'keirin': '競輪',
  'boat_racing': '競艇',
  'auto_racing': 'オート',
};

const Map<String, List<String>> _betTypes = {
  'horse_racing': HorseRacingResult.betTypes,
  'keirin': KeirinResult.betTypes,
  'boat_racing': BoatRacingResult.betTypes,
  'auto_racing': AutoRacingResult.betTypes,
};

/// 1レース分の内訳 (betType, amount, raceName, memo) を追加・編集するダイアログ。
/// [initial] を渡すと編集モードになる。キャンセル時は null を返す。
Future<Map<String, dynamic>?> showRaceBetDialog(
  BuildContext context, {
  required String category,
  Map<String, dynamic>? initial,
}) async {
  final types = _betTypes[category]!;
  final raceCtrl =
      TextEditingController(text: (initial?['raceName'] as String?) ?? '');
  final amountCtrl = TextEditingController(
      text: initial == null ? '' : '${initial['amount'] ?? 0}');
  final memoCtrl =
      TextEditingController(text: (initial?['memo'] as String?) ?? '');
  final formKey = GlobalKey<FormState>();
  String betType = (initial?['betType'] as String?) ?? types.first;
  if (!types.contains(betType)) betType = types.first;

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: Text(initial == null ? 'レースを追加' : 'レースを編集'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: raceCtrl,
                  decoration:
                      const InputDecoration(labelText: 'レース (例: 11R)'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: betType,
                  decoration: const InputDecoration(labelText: '賭け方'),
                  items: types
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setLocal(() => betType = v!),
                ),
                TextFormField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(
                    labelText: '収支 (負けはマイナス)',
                    suffixText: '円',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                  ],
                  validator: (v) =>
                      int.tryParse(v ?? '') == null ? '数値を入力してください' : null,
                ),
                TextFormField(
                  controller: memoCtrl,
                  decoration: const InputDecoration(labelText: 'メモ'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx, {
                'betType': betType,
                'amount': int.parse(amountCtrl.text),
                'raceName': raceCtrl.text.trim(),
                'memo': memoCtrl.text.trim(),
              });
            },
            child: Text(initial == null ? '追加' : '保存'),
          ),
        ],
      ),
    ),
  );

  raceCtrl.dispose();
  amountCtrl.dispose();
  memoCtrl.dispose();
  return result;
}
