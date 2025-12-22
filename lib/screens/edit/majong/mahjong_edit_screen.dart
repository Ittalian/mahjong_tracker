import 'package:flutter/material.dart';
import 'package:mahjong_tracker/models/mahjong_result.dart';
import 'package:mahjong_tracker/screens/edit/base/base_edit_screen.dart';
import 'package:mahjong_tracker/services/mahjong/mahjong_service.dart';

/// 麻雀の収支編集画面
class MahjongEditScreen extends BaseEditScreen {
  const MahjongEditScreen({
    super.key,
    super.result,
  });

  @override
  State<MahjongEditScreen> createState() => _MahjongEditScreenState();
}

class _MahjongEditScreenState extends BaseEditScreenState<MahjongEditScreen> {
  final _mahjongService = MahjongService();

  String? _mahjongType;
  String? _umaRate;
  String? _priceRate = 'テンピン';
  int _chipRate = 50;
  final List<TextEditingController> _memberControllers = [];

  @override
  void initCategorySpecificFields() {
    if (widget.result is MahjongResult) {
      final res = widget.result as MahjongResult;
      _mahjongType = res.type;
      _umaRate = res.umaRate;
      _priceRate = res.priceRate;
      _chipRate = res.chipRate;
      _initMemberControllers(res.member);
    } else {
      _mahjongType = null;
      _umaRate = null;
      if (_memberControllers.isEmpty) {
        _memberControllers.add(TextEditingController());
      }
    }
  }

  void _initMemberControllers(List<String> members) {
    _memberControllers.clear();
    if (members.isEmpty) {
      _memberControllers.add(TextEditingController());
    } else {
      for (var member in members) {
        _memberControllers.add(TextEditingController(text: member));
      }
    }
  }

  @override
  void disposeCategorySpecificFields() {
    for (var controller in _memberControllers) {
      controller.dispose();
    }
  }

  @override
  Widget buildCategorySpecificFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _mahjongType,
          decoration: const InputDecoration(labelText: 'タイプ'),
          items: MahjongResult.types.map((e) {
            return DropdownMenuItem(value: e, child: Text(e));
          }).toList(),
          onChanged: (v) {
            setState(() {
              _mahjongType = v;
              _umaRate = null; // Reset uma when type changes
            });
          },
          validator: (v) => v == null ? 'タイプを選択してください' : null,
        ),
        const SizedBox(height: 16),
        if (_mahjongType != null) ...[
          DropdownButtonFormField<String>(
            value: _umaRate,
            decoration: const InputDecoration(labelText: 'ウマ'),
            items: _getUmaRatesForType(_mahjongType!).map((e) {
              return DropdownMenuItem(value: e, child: Text(e));
            }).toList(),
            onChanged: (v) => setState(() => _umaRate = v),
            validator: (v) => v == null ? 'ウマを選択してください' : null,
          ),
          const SizedBox(height: 16),
        ],
        DropdownButtonFormField<String>(
          value: _priceRate,
          decoration: const InputDecoration(labelText: 'レート'),
          items: MahjongResult.priceRates.map((e) {
            return DropdownMenuItem(value: e, child: Text(e));
          }).toList(),
          onChanged: (v) => setState(() => _priceRate = v!),
          validator: (v) => v == null ? 'レートを選択してください' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _chipRate,
          decoration: const InputDecoration(labelText: 'チップ'),
          items: MahjongResult.chipRates.map((e) {
            return DropdownMenuItem(
                value: e, child: Text(e == 0 ? 'なし' : e.toString()));
          }).toList(),
          onChanged: (v) => setState(() => _chipRate = v!),
          validator: (v) => v == null ? 'チップを選択してください' : null,
        ),
        const SizedBox(height: 16),
        buildMemberInput(_memberControllers),
      ],
    );
  }

  List<String> _getUmaRatesForType(String type) {
    if (type == '三麻') {
      return MahjongResult.umaRates3ma;
    } else if (type == '四麻') {
      return MahjongResult.umaRates4ma;
    }
    return [];
  }

  @override
  Future<void> saveResult() async {
    if (formKey.currentState!.validate()) {
      final amount = int.tryParse(amountController.text) ?? 0;
      final memo = memoController.text;

      // Parse members
      final memberList = _memberControllers
          .map((c) => c.text.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      try {
        final newResult = MahjongResult(
          id: widget.result?.id,
          date: selectedDate,
          amount: amount,
          memo: memo,
          createdAt: widget.result?.createdAt ?? DateTime.now(),
          type: _mahjongType ?? '四麻',
          umaRate: _umaRate ?? '10-30',
          priceRate: _priceRate ?? 'テンピン',
          chipRate: _chipRate,
          member: memberList,
        );

        if (widget.result == null) {
          await _mahjongService.addResult(newResult);
        } else {
          await _mahjongService.updateResult(newResult);
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
