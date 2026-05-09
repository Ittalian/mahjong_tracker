import 'package:flutter/material.dart';
import 'package:mahjong_tracker/models/mahjong_group.dart';
import 'package:mahjong_tracker/models/mahjong_result.dart';
import 'package:mahjong_tracker/screens/edit/base/base_edit_screen.dart';
import 'package:mahjong_tracker/services/mahjong/mahjong_group_service.dart';
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
  final _groupService = MahjongGroupService();

  String? _mahjongType;
  String? _umaRate;
  String? _priceRate = 'テンピン';
  int _chipRate = 50;
  final List<TextEditingController> _memberControllers = [];

  /// 'individual' | 'group' | null
  String? _addMode;

  /// グループ追加モード時に選択中のグループ名（表示用）
  String? _selectedGroupName;

  @override
  String get categoryType => 'mahjong';

  @override
  Future<void> updatePlaceNameInResults(String oldName, String newName) async {
    await _mahjongService.updatePlaceNames(oldName, newName);
  }

  @override
  void initCategorySpecificFields() {
    if (widget.result is MahjongResult) {
      final res = widget.result as MahjongResult;
      _mahjongType = res.type;
      _umaRate = res.umaRate;
      _priceRate = res.priceRate;
      _chipRate = res.chipRate;
      _initMemberControllers(res.member);
      if (res.member.isNotEmpty) {
        // 仮に individual をセット。グループ照合後に上書きされる可能性がある
        _addMode = 'individual';
        // 画面構築後にグループ照合を非同期実行
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _detectGroupMode(res.member);
        });
      }
    } else {
      _mahjongType = null;
      _umaRate = null;
    }
  }

  /// 登録済みグループのメンバーリストと比較してグループモードを自動判定
  Future<void> _detectGroupMode(List<String> members) async {
    if (members.isEmpty) return;
    try {
      final groups =
          await _groupService.getGroups(type: _mahjongType).first;
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
    if (members.isEmpty) {
      // モード未選択時は空のまま
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
      // コントローラをクリア
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

  /// グループ選択BottomSheetを表示
  Future<void> _showGroupSelector() async {
    final selected = await showModalBottomSheet<MahjongGroup>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _GroupSelectorSheet(
        groupService: _groupService,
        filterType: _mahjongType, // タイプ選択中なら絞り込み
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

  @override
  Widget buildCategorySpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              _umaRate = null;
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
        const SizedBox(height: 24),

        // ── メンバーセクション ──
        _buildMemberSection(),
      ],
    );
  }

  Widget _buildMemberSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('メンバー', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            // モード切り替えボタン（未選択時のみ両方表示）
            if (_addMode == null) ...[
              OutlinedButton.icon(
                onPressed: _switchToIndividual,
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('個人'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _switchToGroup,
                icon: const Icon(Icons.group_add, size: 16),
                label: const Text('グループ'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ] else ...[
              // 選択済みモード表示 + リセット
              _ModeChip(
                label: _addMode == 'individual'
                    ? '個人'
                    : (_selectedGroupName != null
                        ? 'G: $_selectedGroupName'
                        : 'グループ'),
                icon: _addMode == 'individual'
                    ? Icons.person
                    : Icons.group,
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

  /// 個人追加UI（既存の実装）
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

  /// グループ追加UI
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
          place: placeValue,
        );

        if (widget.result == null) {
          await _mahjongService.addResult(newResult);
        } else {
          await _mahjongService.updateResult(newResult);
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

// ── モードチップ ──────────────────────────────────
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
    return InputChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onDeleted: onClear,
      deleteIcon: const Icon(Icons.close, size: 16),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor:
          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
    );
  }
}

// ── グループ選択BottomSheet ─────────────────────────
class _GroupSelectorSheet extends StatefulWidget {
  final MahjongGroupService groupService;
  final String? filterType;

  const _GroupSelectorSheet({
    required this.groupService,
    this.filterType,
  });

  @override
  State<_GroupSelectorSheet> createState() => _GroupSelectorSheetState();
}

class _GroupSelectorSheetState extends State<_GroupSelectorSheet> {
  late final Stream<List<MahjongGroup>> _stream;

  @override
  void initState() {
    super.initState();
    // initStateでストリームを固定し、スクロール中に再接続されないようにする
    _stream = widget.groupService.getGroups(type: widget.filterType);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MahjongGroup>>(
      stream: _stream,
      builder: (context, snapshot) {
        final groups = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Text('グループを選択',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      if (widget.filterType != null) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(widget.filterType!,
                              style: const TextStyle(fontSize: 12)),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : groups.isEmpty
                          ? const Center(
                              child: Text('グループがありません',
                                  style:
                                      TextStyle(color: Colors.grey)),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: groups.length,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemBuilder: (context, index) {
                                final group = groups[index];
                                final typeColor =
                                    group.type == '三麻'
                                        ? Colors.orange.shade700
                                        : Colors.blue.shade700;
                                return Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Text(group.name,
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: typeColor
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: typeColor.withValues(
                                                    alpha: 0.4)),
                                          ),
                                          child: Text(group.type,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: typeColor)),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      group.members.isEmpty
                                          ? 'メンバーなし'
                                          : group.members.join('  /  '),
                                      style:
                                          const TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing:
                                        const Icon(Icons.chevron_right),
                                    onTap: () =>
                                        Navigator.pop(context, group),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
