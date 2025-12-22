import 'package:flutter/material.dart';
import 'package:mahjong_tracker/models/pachinko_result.dart';
import 'package:mahjong_tracker/screens/edit/base/base_edit_screen.dart';
import 'package:mahjong_tracker/services/pachinko/pachinko_service.dart';

/// パチンコの収支編集画面
class PachinkoEditScreen extends BaseEditScreen {
  const PachinkoEditScreen({
    super.key,
    super.result,
  });

  @override
  State<PachinkoEditScreen> createState() => _PachinkoEditScreenState();
}

class _PachinkoEditScreenState extends BaseEditScreenState<PachinkoEditScreen> {
  final _pachinkoService = PachinkoService();

  String _pachinkoType = 'ソロ';
  final List<TextEditingController> _memberControllers = [];
  late TextEditingController _placeController;
  late TextEditingController _machineController;

  @override
  void initCategorySpecificFields() {
    if (widget.result is PachinkoResult) {
      final res = widget.result as PachinkoResult;
      _pachinkoType = res.type;
      _initMemberControllers(res.member);
      _placeController = TextEditingController(text: res.place);
      _machineController = TextEditingController(text: res.machine);
    } else {
      _placeController = TextEditingController();
      _machineController = TextEditingController();
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
    _placeController.dispose();
    _machineController.dispose();
  }

  @override
  Widget buildCategorySpecificFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _pachinkoType,
          decoration: const InputDecoration(labelText: 'タイプ'),
          items: PachinkoResult.types.map((e) {
            return DropdownMenuItem(value: e, child: Text(e));
          }).toList(),
          onChanged: (v) => setState(() => _pachinkoType = v!),
          validator: (v) => v == null ? 'タイプを選択してください' : null,
        ),
        if (_pachinkoType == '乗り打ち') ...[
          const SizedBox(height: 16),
          buildMemberInput(_memberControllers),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: _placeController,
          decoration: const InputDecoration(
            labelText: '場所',
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return '場所を入力してください';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _machineController,
          decoration: const InputDecoration(
            labelText: '台の種類',
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return '台の種類を入力してください';
            }
            return null;
          },
        ),
      ],
    );
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
        final newResult = PachinkoResult(
          id: widget.result?.id,
          date: selectedDate,
          amount: amount,
          memo: memo,
          createdAt: widget.result?.createdAt ?? DateTime.now(),
          type: _pachinkoType,
          member: _pachinkoType == '乗り打ち' ? memberList : [],
          place: _placeController.text,
          machine: _machineController.text,
        );

        if (widget.result == null) {
          await _pachinkoService.addResult(newResult);
        } else {
          await _pachinkoService.updateResult(newResult);
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
