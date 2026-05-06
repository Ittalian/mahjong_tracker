import 'package:flutter/material.dart';

abstract class AutocompleteOption<T> {}

class ItemOption<T> extends AutocompleteOption<T> {
  final T item;
  ItemOption(this.item);
}

class CreateOption<T> extends AutocompleteOption<T> {
  final String text;
  CreateOption(this.text);
}

class CreatableAutocomplete<T extends Object> extends StatefulWidget {
  final List<T> options;
  final String Function(T) displayStringForOption;
  final Future<void> Function(String) onCreate;
  final Future<void> Function(T, String) onEdit;
  final Future<void> Function(T) onDelete;
  final void Function(String) onChanged;
  final String labelText;
  final String? initialValue;

  const CreatableAutocomplete({
    super.key,
    required this.options,
    required this.displayStringForOption,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
    required this.onChanged,
    required this.labelText,
    this.initialValue,
  });

  @override
  State<CreatableAutocomplete<T>> createState() => _CreatableAutocompleteState<T>();
}

class _CreatableAutocompleteState<T extends Object> extends State<CreatableAutocomplete<T>> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();

    _textController.addListener(() {
      widget.onChanged(_textController.text);
    });
  }

  @override
  void didUpdateWidget(CreatableAutocomplete<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && widget.initialValue != null) {
      // ユーザーが入力中の場合は上書きしないようにするなどの工夫が必要だが、
      // 基本的には初期表示時のデータバインディング用
      if (_textController.text.isEmpty && widget.initialValue!.isNotEmpty) {
        _textController.text = widget.initialValue!;
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showEditDialog(T item) {
    final currentName = widget.displayStringForOption(item);
    final editController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('名前を編集'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(labelText: '新しい名前'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = editController.text.trim();
                if (newName.isNotEmpty && newName != currentName) {
                  await widget.onEdit(item, newName);
                  // 入力欄も更新する場合
                  if (_textController.text == currentName) {
                    _textController.text = newName;
                  }
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _focusNode.unfocus();
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(T item) {
    final name = widget.displayStringForOption(item);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('削除の確認'),
          content: Text('「$name」を削除してもよろしいですか？\n※過去の履歴の表示に影響が出る場合があります。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await widget.onDelete(item);
                // 入力欄が同じ名前ならクリア
                if (_textController.text == name) {
                  _textController.text = '';
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _focusNode.unfocus();
                }
              },
              child: const Text('削除', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<AutocompleteOption<T>>(
      textEditingController: _textController,
      focusNode: _focusNode,
      displayStringForOption: (option) {
        if (option is ItemOption<T>) {
          return widget.displayStringForOption(option.item);
        } else if (option is CreateOption<T>) {
          return option.text;
        }
        return '';
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text;
        final filteredOptions = widget.options.where((option) {
          return widget.displayStringForOption(option)
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();

        final result = <AutocompleteOption<T>>[];
        result.addAll(filteredOptions.map((e) => ItemOption(e)));

        // 入力文字があり、かつ完全一致する既存項目がない場合は「作成」オプションを追加
        if (query.isNotEmpty) {
          final exactMatch = widget.options.any((option) =>
              widget.displayStringForOption(option) == query);
          if (!exactMatch) {
            result.add(CreateOption(query));
          }
        } else if (query.isEmpty) {
            // queryが空の場合は全件表示する
            return widget.options.map((e) => ItemOption(e)).toList();
        }

        return result;
      },
      onSelected: (option) async {
        if (option is CreateOption<T>) {
          await widget.onCreate(option.text);
          // 作成後はテキストフィールドにセット
          _textController.text = option.text;
          _focusNode.unfocus();
        } else if (option is ItemOption<T>) {
          _textController.text = widget.displayStringForOption(option.item);
          _focusNode.unfocus();
        }
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 150,
                maxWidth: MediaQuery.of(context).size.width - 32, // パディング考慮
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);

                  if (option is CreateOption<T>) {
                    return ListTile(
                      leading: const Icon(Icons.add),
                      title: Text('「${option.text}」を作成'),
                      onTap: () {
                        onSelected(option);
                      },
                    );
                  } else if (option is ItemOption<T>) {
                    final item = option.item;
                    final name = widget.displayStringForOption(item);
                    return ListTile(
                      title: Text(name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showEditDialog(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () => _showDeleteDialog(item),
                          ),
                        ],
                      ),
                      onTap: () {
                        onSelected(option);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
