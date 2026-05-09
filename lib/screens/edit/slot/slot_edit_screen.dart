import 'package:flutter/material.dart';
import 'package:mahjong_tracker/models/slot_result.dart';
import 'package:mahjong_tracker/models/machine_type.dart';
import 'package:mahjong_tracker/models/place.dart';
import 'package:mahjong_tracker/screens/edit/base/base_edit_screen.dart';
import 'package:mahjong_tracker/services/slot/slot_service.dart';
import 'package:mahjong_tracker/services/slot_machine_type_service.dart';
import 'package:mahjong_tracker/services/place_service.dart';
import 'package:mahjong_tracker/widgets/creatable_autocomplete.dart';

/// スロットの収支編集画面
class SlotEditScreen extends BaseEditScreen {
  const SlotEditScreen({
    super.key,
    super.result,
  });

  @override
  State<SlotEditScreen> createState() => _SlotEditScreenState();
}

class _SlotEditScreenState extends BaseEditScreenState<SlotEditScreen> {
  final _slotService = SlotService();
  final _slotMachineTypeService = SlotMachineTypeService();
  final _placeService = PlaceService();

  String _machineValue = '';
  int _expectedSetting = 0;
  final List<TextEditingController> _memberControllers = [];

  @override
  String get categoryType => 'slot';

  @override
  Future<void> updatePlaceNameInResults(String oldName, String newName) async {
    await _slotService.updatePlaceNames(oldName, newName);
  }

  @override
  void initCategorySpecificFields() {
    if (widget.result is SlotResult) {
      final res = widget.result as SlotResult;
      _machineValue = res.machine;
      _expectedSetting = res.expectedSetting;
      _initMemberControllers(res.member);
    } else {
      _machineValue = '';
      _expectedSetting = 0;
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

  /// 店舗フィールドをオーバーライドしてパチンコの店舗（category: 'pachinko'）を参照する
  @override
  Widget buildPlaceField() {
    return StreamBuilder<List<Place>>(
      stream: _placeService.getPlaces('pachinko'),
      builder: (context, snapshot) {
        final places = snapshot.data ?? [];
        return CreatableAutocomplete<Place>(
          options: places,
          displayStringForOption: (p) => p.name,
          labelText: '店舗',
          initialValue: placeValue,
          onChanged: (v) => placeValue = v,
          onCreate: (name) async {
            await _placeService.addPlace(
              Place(name: name, category: 'pachinko', createdAt: DateTime.now()),
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('保存しました')));
            }
          },
          onEdit: (place, newName) async {
            final oldName = place.name;
            await _placeService.updatePlace(
              Place(
                  id: place.id,
                  name: newName,
                  category: 'pachinko',
                  createdAt: place.createdAt),
            );
            if (oldName != newName) {
              await updatePlaceNameInResults(oldName, newName);
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('保存しました')));
            }
          },
          onDelete: (place) async {
            await _placeService.deletePlace(place.id!);
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('削除しました')));
            }
          },
        );
      },
    );
  }

  @override
  Widget buildCategorySpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<MachineType>>(
          stream: _slotMachineTypeService.getMachineTypes(),
          builder: (context, snapshot) {
            final machines = snapshot.data ?? [];
            return CreatableAutocomplete<MachineType>(
              options: machines,
              displayStringForOption: (m) => m.name,
              labelText: '台の種類',
              initialValue: _machineValue,
              onChanged: (v) => _machineValue = v,
              onCreate: (name) async {
                await _slotMachineTypeService.addMachineType(
                  MachineType(name: name, createdAt: DateTime.now()),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('保存しました')));
                }
              },
              onEdit: (machine, newName) async {
                final oldName = machine.name;
                await _slotMachineTypeService.updateMachineType(
                  MachineType(
                      id: machine.id,
                      name: newName,
                      createdAt: machine.createdAt),
                );
                if (oldName != newName) {
                  await _slotService.updateMachineNames(oldName, newName);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('保存しました')));
                }
              },
              onDelete: (machine) async {
                await _slotMachineTypeService.deleteMachineType(machine.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('削除しました')));
                }
              },
            );
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _expectedSetting,
          decoration: const InputDecoration(labelText: '予想設定'),
          items: [
            const DropdownMenuItem(value: 0, child: Text('未設定')),
            ...List.generate(6, (i) => i + 1).map(
              (s) => DropdownMenuItem(value: s, child: Text('設定$s')),
            ),
          ],
          onChanged: (v) => setState(() => _expectedSetting = v ?? 0),
        ),
        const SizedBox(height: 16),
        buildMemberInput(_memberControllers),
      ],
    );
  }

  @override
  Future<void> saveResult() async {
    if (formKey.currentState!.validate()) {
      final amount = int.tryParse(amountController.text) ?? 0;
      final memo = memoController.text;

      final memberList = _memberControllers
          .map((c) => c.text.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      try {
        final newResult = SlotResult(
          id: widget.result?.id,
          date: selectedDate,
          amount: amount,
          memo: memo,
          createdAt: widget.result?.createdAt ?? DateTime.now(),
          place: placeValue,
          machine: _machineValue,
          expectedSetting: _expectedSetting,
          member: memberList,
        );

        if (widget.result == null) {
          await _slotService.addResult(newResult);
        } else {
          await _slotService.updateResult(newResult);
        }

        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('保存しました')));
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
