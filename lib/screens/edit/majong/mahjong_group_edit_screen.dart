import 'package:flutter/material.dart';
import 'package:mahjong_tracker/models/mahjong_group.dart';
import 'package:mahjong_tracker/models/mahjong_result.dart';
import 'package:mahjong_tracker/services/mahjong/mahjong_group_service.dart';
import 'package:mahjong_tracker/services/mahjong/mahjong_service.dart';

// ──────────────────────────────────────────────────────
// グループ一覧・管理画面（SegmentedButton で三麻/四麻切り替え）
// ──────────────────────────────────────────────────────
class MahjongGroupListScreen extends StatefulWidget {
  const MahjongGroupListScreen({super.key});

  @override
  State<MahjongGroupListScreen> createState() =>
      _MahjongGroupListScreenState();
}

class _MahjongGroupListScreenState extends State<MahjongGroupListScreen> {
  final _service = MahjongGroupService();
  String _selectedType = '四麻'; // 初期タブ

  @override
  Widget build(BuildContext context) {
    final typeColor =
        _selectedType == '三麻' ? Colors.orange.shade700 : Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('麻雀グループ管理'),
      ),
      body: StreamBuilder<List<MahjongGroup>>(
        stream: _service.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data ?? [];
          final filtered =
              all.where((g) => g.type == _selectedType).toList();

          return Column(
            children: [
              // ── SegmentedButton ────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  children: [
                    SegmentedButton<String>(
                      segments: MahjongResult.types.map((t) {
                        final c = t == '三麻'
                            ? Colors.orange.shade700
                            : Colors.blue.shade700;
                        return ButtonSegment<String>(
                          value: t,
                          label: Text(t),
                          icon: Icon(
                            t == '三麻'
                                ? Icons.looks_3
                                : Icons.looks_4,
                            color: _selectedType == t ? c : null,
                          ),
                        );
                      }).toList(),
                      selected: {_selectedType},
                      onSelectionChanged: (s) =>
                          setState(() => _selectedType = s.first),
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),

              // ── グループ一覧 ─────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.group_off,
                                size: 48,
                                color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              '$_selectedType のグループがありません',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        itemBuilder: (context, index) {
                          final group = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _GroupCard(
                              group: group,
                              color: typeColor,
                              onEdit: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MahjongGroupEditScreen(
                                            group: group),
                                  ),
                                );
                              },
                              onDelete: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('削除確認'),
                                    content: Text(
                                        '「${group.name}」を削除します。'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child:
                                            const Text('キャンセル'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('削除',
                                            style: TextStyle(
                                                color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true &&
                                    group.id != null) {
                                  await _service.deleteGroup(group.id!);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MahjongGroupEditScreen(initialType: _selectedType),
            ),
          );
        },
        tooltip: '$_selectedType グループを追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// グループカード
// ──────────────────────────────────────────────────────
class _GroupCard extends StatelessWidget {
  final MahjongGroup group;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GroupCard({
    required this.group,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: '編集',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete,
                      size: 20, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: '削除',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            group.members.isEmpty
                ? Text('メンバーなし',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12))
                : Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: group.members
                        .asMap()
                        .entries
                        .map((e) => _MemberBadge(
                              index: e.key + 1,
                              name: e.value,
                              color: color,
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class _MemberBadge extends StatelessWidget {
  final int index;
  final String name;
  final Color color;

  const _MemberBadge(
      {required this.index, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$index',
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              color: color.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// グループ追加・編集画面
// ──────────────────────────────────────────────────────
class MahjongGroupEditScreen extends StatefulWidget {
  final MahjongGroup? group;

  /// セクションから追加する場合に自動セットされるタイプ
  final String? initialType;

  const MahjongGroupEditScreen({super.key, this.group, this.initialType});

  @override
  State<MahjongGroupEditScreen> createState() =>
      _MahjongGroupEditScreenState();
}

class _MahjongGroupEditScreenState extends State<MahjongGroupEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _newMemberController = TextEditingController();
  final _groupService = MahjongGroupService();
  final _mahjongService = MahjongService();

  late String _type;
  List<String> _members = [];

  /// タイプが外部から確定されている場合（新規追加時のみ）はセレクタを非表示
  bool get _typeFixed => widget.initialType != null && widget.group == null;

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _nameController.text = widget.group!.name;
      _type = widget.group!.type;
      _members = List<String>.from(widget.group!.members);
    } else {
      _type = widget.initialType ?? '四麻';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newMemberController.dispose();
    super.dispose();
  }

  void _addMember(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (_members.contains(trimmed)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「$trimmed」はすでに追加されています')),
      );
      return;
    }
    setState(() => _members.add(trimmed));
    _newMemberController.clear();
  }

  void _removeMember(int index) {
    setState(() => _members.removeAt(index));
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _members.removeAt(oldIndex);
      _members.insert(newIndex, item);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final group = MahjongGroup(
      id: widget.group?.id,
      name: _nameController.text.trim(),
      type: _type,
      members: _members,
      createdAt: widget.group?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.group == null) {
        await _groupService.addGroup(group);
      } else {
        await _groupService.updateGroup(group);
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('保存しました')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.group != null;
    final typeColor =
        _type == '三麻' ? Colors.orange.shade700 : Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'グループ編集' : 'グループ追加'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── グループ名 ──────────────────────────────
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'グループ名',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'グループ名を入力してください'
                    : null,
              ),
              const SizedBox(height: 24),

              // ── タイプ選択（セクション指定時は非表示）──────
              if (!_typeFixed) ...[
                const Text('タイプ',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: MahjongResult.types.map((t) {
                    final selected = _type == t;
                    final color = t == '三麻'
                        ? Colors.orange.shade700
                        : Colors.blue.shade700;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(t),
                        selected: selected,
                        selectedColor: color.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: selected ? color : Colors.grey.shade600,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (_) => setState(() => _type = t),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ] else ...[
                Row(
                  children: [
                    const Text('タイプ',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: typeColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        _type,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // ── 選択中メンバー（ドラッグで並べ替え）────────
              const Text('メンバー',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('長押しでドラッグして並び替えできます',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 12),

              if (_members.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('メンバーがいません',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13)),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _members.length,
                  onReorder: _onReorder,
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(10),
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final name = _members[index];
                    return Container(
                      key: ValueKey('$name-$index'),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: typeColor.withValues(alpha: 0.3)),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 20,
                                  color: Colors.red),
                              onPressed: () => _removeMember(index),
                              visualDensity: VisualDensity.compact,
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),

              // ── 登録済みメンバーから追加 ──────────────────
              StreamBuilder<List<String>>(
                stream: _mahjongService.getUniqueMembers(),
                builder: (context, snapshot) {
                  final existingNames = snapshot.data ?? [];
                  final candidates = existingNames
                      .where((n) => !_members.contains(n))
                      .toList();

                  if (existingNames.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history,
                              size: 16,
                              color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '登録済みメンバーから追加',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (candidates.isEmpty)
                        Text(
                          '未追加のメンバーはいません',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: candidates
                              .map((name) => _ExistingMemberChip(
                                    name: name,
                                    onAdd: () => _addMember(name),
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),

              // ── 新規メンバー追加 ──────────────────────────
              Row(
                children: [
                  Icon(Icons.person_add,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '新規メンバーを追加',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newMemberController,
                      decoration: const InputDecoration(
                        labelText: 'メンバー名を入力',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onFieldSubmitted: _addMember,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () =>
                        _addMember(_newMemberController.text),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('追加'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('保存'),
          ),
        ),
      ),
    );
  }
}

// ── 登録済みメンバー追加チップ ────────────────────────────
class _ExistingMemberChip extends StatelessWidget {
  final String name;
  final VoidCallback onAdd;

  const _ExistingMemberChip({required this.name, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
