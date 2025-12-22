import 'package:flutter/material.dart';
import 'package:mahjong_tracker/models/boat_racing_result.dart';
import 'package:mahjong_tracker/screens/edit/base/base_edit_screen.dart';
import 'package:mahjong_tracker/services/boat_racing/boat_racing_service.dart';

/// ボートレースの収支編集画面
class BoatRacingEditScreen extends BaseEditScreen {
  const BoatRacingEditScreen({
    super.key,
    super.result,
  });

  @override
  State<BoatRacingEditScreen> createState() => _BoatRacingEditScreenState();
}

class _BoatRacingEditScreenState
    extends BaseEditScreenState<BoatRacingEditScreen> {
  final _boatRacingService = BoatRacingService();

  String _betType = '単勝';

  @override
  void initCategorySpecificFields() {
    if (widget.result is BoatRacingResult) {
      _betType = (widget.result as BoatRacingResult).betType;
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
      items: BoatRacingResult.betTypes.map((e) {
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
        final newResult = BoatRacingResult(
          id: widget.result?.id,
          date: selectedDate,
          amount: amount,
          betType: _betType,
          memo: memo,
          createdAt: widget.result?.createdAt ?? DateTime.now(),
        );

        if (widget.result == null) {
          await _boatRacingService.addResult(newResult);
        } else {
          await _boatRacingService.updateResult(newResult);
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
