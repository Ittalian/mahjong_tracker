import 'package:flutter/material.dart';
import 'package:mahjong_tracker/models/horse_racing_result.dart';
import 'package:mahjong_tracker/screens/edit/base/base_edit_screen.dart';
import 'package:mahjong_tracker/services/horse_racing/horse_racing_service.dart';

/// 競馬の収支編集画面
class HorseRacingEditScreen extends BaseEditScreen {
  const HorseRacingEditScreen({
    super.key,
    super.result,
  });

  @override
  State<HorseRacingEditScreen> createState() => _HorseRacingEditScreenState();
}

class _HorseRacingEditScreenState
    extends BaseEditScreenState<HorseRacingEditScreen> {
  final _horseRacingService = HorseRacingService();

  String _betType = '単勝';

  @override
  void initCategorySpecificFields() {
    if (widget.result is HorseRacingResult) {
      _betType = (widget.result as HorseRacingResult).betType;
    }
  }

  @override
  void disposeCategorySpecificFields() {
    // レース系は追加のコントローラーなし
  }

  @override
  Widget buildCategorySpecificFields() {
    return DropdownButtonFormField<String>(
      value: _betType,
      decoration: const InputDecoration(labelText: '賭け方'),
      items: HorseRacingResult.betTypes.map((e) {
        return DropdownMenuItem(value: e, child: Text(e));
      }).toList(),
      onChanged: (v) => setState(() => _betType = v!),
      validator: (v) => v == null ? '賭け方を選択してください' : null,
    );
  }

  @override
  Future<void> saveResult() async {
    if (formKey.currentState!.validate()) {
      final amount = int.tryParse(amountController.text) ?? 0;
      final memo = memoController.text;

      try {
        final newResult = HorseRacingResult(
          id: widget.result?.id,
          date: selectedDate,
          amount: amount,
          betType: _betType,
          memo: memo,
          createdAt: widget.result?.createdAt ?? DateTime.now(),
        );

        if (widget.result == null) {
          await _horseRacingService.addResult(newResult);
        } else {
          await _horseRacingService.updateResult(newResult);
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラーが発生しました: $e')),
          );
        }
      }
    }
  }
}
