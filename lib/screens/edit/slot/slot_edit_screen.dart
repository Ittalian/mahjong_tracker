import 'package:flutter/material.dart';
import 'package:mahjong_tracker/models/slot_result.dart';
import 'package:mahjong_tracker/models/pachinko_group.dart';
import 'package:mahjong_tracker/models/machine_type.dart';
import 'package:mahjong_tracker/models/place.dart';
import 'package:mahjong_tracker/screens/edit/base/base_edit_screen.dart';
import 'package:mahjong_tracker/services/slot/slot_service.dart';
import 'package:mahjong_tracker/services/pachinko/pachinko_group_service.dart';
import 'package:mahjong_tracker/services/slot_machine_type_service.dart';
import 'package:mahjong_tracker/services/place_service.dart';
import 'package:mahjong_tracker/widgets/creatable_autocomplete.dart';

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
  final _groupService = PachinkoGroupService();
  final _slotMachineTypeService = SlotMachineTypeService();
  final _placeService = PlaceService();

  String _machineValue = '';
  int _expectedSetting = 0;
  final List<TextEditingController> _memberControllers = [];

  String? _addMode;
  String? _selectedGroupName;

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
      if (res.member.isNotEmpty) {
        _addMode = 'individual';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _detectGroupMode(res.member);
        });
      }
    } else {
      _machineValue = '';
      _expectedSetting = 0;
    }
  }

  Future<void> _detectGroupMode(List<String> members) async {
    if (members.isEmpty) return;
    try {
      final groups = await _groupService.getGroups().first;
      final sorted = List<String>.from(members)..sort();
      for (final group in groups) {
        final groupSorted = List<String>.from(group.members)..sort();
        if (sorted.length == groupSorted.length &&
            sorted.join(',') == groupSorted.join(',')) {
          if (mounted) {
            setState(() {
              _addMode = 'group';
              _selectedGroupName = group.name;
            });
          }
          return;
        }
      }
    } catch (_) {
      // 照合失敗時はindividualのまま
    }
  }

  void _initMemberControllers(List<String> members) {
    _memberControllers.clear();
    for (var member in members) {
      _memberControllers.add(TextEditingController(text: member));
    }
  }

  @override
  void disposeCategorySpecificFields() {
    for (var controller in _memberControllers) {
      controller.dispose();
    }
  }

  void _switchToIndividual() {
    setState(() {
      _addMode = 'individual';
      if (_memberControllers.isEmpty) {
        _memberControllers.add(TextEditingController());
      }
    });
  }

  void _switchToGroup() {
    setState(() {
      _addMode = 'group';
      for (final c in _memberControllers) {
        c.dispose();
      }
      _memberControllers.clear();
    });
  }

  void _clearAddMode() {
    setState(() {
      _addMode = null;
      for (final c in _memberControllers) {
        c.dispose();
      }
      _memberControllers.clear();
    });
  }

  Future<void> _showGroupSelector() async {
    final selected = await showModalBottomSheet<PachinkoGroup>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _GroupSelectorSheet(
        groupService: _groupService,
      ),
    );

    if (selected != null) {
      setState(() {
        for (final c in _memberControllers) {
          c.dispose();
        }
        _memberControllers.clear();
        for (final m in selected.members) {
          _memberControllers.add(TextEditingController(text: m));
        }
        _selectedGroupName = selected.name;
      });
    }
  }

  Widget _buildMemberSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('メンバー',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (_addMode == null) ...[
              OutlinedButton.icon(
                onPressed: _switchToIndividual,
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('個人'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _switchToGroup,
                icon: const Icon(Icons.group_add, size: 16),
                label: const Text('グループ'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ] else ...[
              _ModeChip(
                label: _addMode == 'individual'
                    ? '個人'
                    : (_selectedGroupName != null
                        ? 'G: $_selectedGroupName'
                        : 'グループ'),
                icon: _addMode == 'individual' ? Icons.person : Icons.group,
                onClear: _clearAddMode,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (_addMode == 'individual')
          _buildIndividualMemberInput()
        else if (_addMode == 'group')
          _buildGroupMemberInput()
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '追加方法を選択してください',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildIndividualMemberInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._memberControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'メンバー ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return '入力してください';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    setState(() {
                      if (_memberControllers.length > 1) {
                        controller.dispose();
                        _memberControllers.removeAt(index);
                      } else {
                        controller.clear();
                      }
                    });
                  },
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _memberControllers.add(TextEditingController());
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('メンバーを追加'),
        ),
      ],
    );
  }

  Widget _buildGroupMemberInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _showGroupSelector,
          icon: const Icon(Icons.group, size: 18),
          label: const Text('グループを選択'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
          ),
        ),
        if (_memberControllers.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('選択中のメンバー:',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _memberControllers.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value.text),
                avatar: CircleAvatar(
                  radius: 10,
                  child: Text(
                    '${entry.key + 1}',
                    style: const TextStyle(fontSize: 9),
                  ),
                ),
                onDeleted: () {
                  setState(() {
                    entry.value.dispose();
                    _memberControllers.removeAt(entry.key);
                    if (_memberControllers.isEmpty) {
                      _addMode = null;
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

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
              Place(
                  name: name,
                  category: 'pachinko',
                  createdAt: DateTime.now()),
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
        _buildMemberSection(),
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

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onClear;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.close,
                size: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupSelectorSheet extends StatefulWidget {
  final PachinkoGroupService groupService;

  const _GroupSelectorSheet({required this.groupService});

  @override
  State<_GroupSelectorSheet> createState() => _GroupSelectorSheetState();
}

class _GroupSelectorSheetState extends State<_GroupSelectorSheet> {
  late final Stream<List<PachinkoGroup>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = widget.groupService.getGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'グループを選択',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<PachinkoGroup>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final groups = snapshot.data ?? [];

                if (groups.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group_off,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'グループがありません',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(group.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          group.members.join(', '),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        trailing: const Icon(Icons.check_circle_outline),
                        onTap: () => Navigator.pop(context, group),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
