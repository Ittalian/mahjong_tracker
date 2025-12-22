import 'package:flutter/material.dart';
import 'package:mahjong_tracker/models/auto_racing_result.dart';
import 'package:mahjong_tracker/screens/edit/base/base_edit_screen.dart';
import 'package:mahjong_tracker/services/auto_racing/auto_racing_service.dart';

/// オートレースの収支編集画面
class AutoRacingEditScreen extends BaseEditScreen {
  const AutoRacingEditScreen({
    super.key,
    super.result,
  });

  @override
  State<AutoRacingEditScreen> createState() => _AutoRacingEditScreenState();
}

class _AutoRacingEditScreenState
    extends BaseEditScreenState<AutoRacingEditScreen> {
  final _autoRacingService = AutoRacingService();

  String _betType = '単勝';

  @override
  void initCategorySpecificFields() {
    if (widget.result is AutoRacingResult) {
      _betType = (widget.result as AutoRacingResult).betType;
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
      items: AutoRacingResult.betTypes.map((e) {
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
        final newResult = AutoRacingResult(
          id: widget.result?.id,
          date: selectedDate,
          amount: amount,
          betType: _betType,
          memo: memo,
          createdAt: widget.result?.createdAt ?? DateTime.now(),
        );

        if (widget.result == null) {
          await _autoRacingService.addResult(newResult);
        } else {
          await _autoRacingService.updateResult(newResult);
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
