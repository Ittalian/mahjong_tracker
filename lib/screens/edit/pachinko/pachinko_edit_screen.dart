import 'package:flutter/material.dart';
import 'package:mahjong_tracker/models/pachinko_result.dart';
import 'package:mahjong_tracker/screens/edit/base/base_edit_screen.dart';
import 'package:mahjong_tracker/services/pachinko/pachinko_service.dart';
import 'package:mahjong_tracker/models/machine_type.dart';
import 'package:mahjong_tracker/services/machine_type_service.dart';
import 'package:mahjong_tracker/widgets/creatable_autocomplete.dart';

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
  final _machineTypeService = MachineTypeService();

  String _pachinkoType = 'ソロ';
  final List<TextEditingController> _memberControllers = [];
  String _machineValue = '';

  @override
  String get categoryType => 'pachinko';

  @override
  Future<void> updatePlaceNameInResults(String oldName, String newName) async {
    await _pachinkoService.updatePlaceNames(oldName, newName);
  }

  @override
  void initCategorySpecificFields() {
    if (widget.result is PachinkoResult) {
      final res = widget.result as PachinkoResult;
      _pachinkoType = res.type;
      _initMemberControllers(res.member);
      _machineValue = res.machine;
    } else {
      _machineValue = '';
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
        StreamBuilder<List<MachineType>>(
          stream: _machineTypeService.getMachineTypes(),
          builder: (context, snapshot) {
            final machines = snapshot.data ?? [];
            return CreatableAutocomplete<MachineType>(
              key: ValueKey('machine_${machines.length}_${machines.hashCode}'),
              options: machines,
              displayStringForOption: (m) => m.name,
              labelText: '台の種類',
              initialValue: _machineValue,
              onChanged: (v) => _machineValue = v,
              onCreate: (name) async {
                await _machineTypeService.addMachineType(MachineType(name: name, createdAt: DateTime.now()));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存しました')));
                }
              },
              onEdit: (machine, newName) async {
                final oldName = machine.name;
                await _machineTypeService.updateMachineType(MachineType(id: machine.id, name: newName, createdAt: machine.createdAt));
                if (oldName != newName) {
                  await _pachinkoService.updateMachineNames(oldName, newName);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存しました')));
                }
              },
              onDelete: (machine) async {
                await _machineTypeService.deleteMachineType(machine.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('削除しました')));
                }
              },
            );
          }
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
          place: placeValue,
          machine: _machineValue,
        );

        if (widget.result == null) {
          await _pachinkoService.addResult(newResult);
        } else {
          await _pachinkoService.updateResult(newResult);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存しました')));
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
