import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 全ての編集画面で共有される機能を提供する抽象ベースクラス
abstract class BaseEditScreen extends StatefulWidget {
  final dynamic result;

  const BaseEditScreen({
    super.key,
    this.result,
  });
}

abstract class BaseEditScreenState<T extends BaseEditScreen> extends State<T> {
  final formKey = GlobalKey<FormState>();

  late DateTime selectedDate;
  late TextEditingController amountController;
  late TextEditingController memoController;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.result?.date ?? DateTime.now();
    amountController = TextEditingController(
      text: widget.result?.amount.toString() ?? '',
    );
    memoController = TextEditingController(text: widget.result?.memo ?? '');
    initCategorySpecificFields();
  }

  @override
  void dispose() {
    amountController.dispose();
    memoController.dispose();
    disposeCategorySpecificFields();
    super.dispose();
  }

  /// 競技固有のフィールドを初期化
  void initCategorySpecificFields();

  /// 競技固有のフィールドをクリーンアップ
  void disposeCategorySpecificFields();

  /// 競技固有のフォームフィールドを構築
  Widget buildCategorySpecificFields();

  /// 結果を保存
  Future<void> saveResult();

  /// 日付選択ダイアログを表示
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// 共通の日付選択UIを構築
  Widget buildDateSelector() {
    return ListTile(
      title: Text(
        '日付: ${DateFormat('yyyy/MM/dd').format(selectedDate)}',
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => selectDate(context),
    );
  }

  /// 共通の金額入力フィールドを構築
  Widget buildAmountField() {
    return TextFormField(
      controller: amountController,
      decoration: const InputDecoration(
        labelText: '金額 (プラスまたはマイナス)',
        helperText: '例: 5000, -3000',
      ),
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '金額を入力してください';
        }
        if (int.tryParse(value) == null) {
          return '有効な数値を入力してください';
        }
        return null;
      },
    );
  }

  /// 共通のメモ入力フィールドを構築
  Widget buildMemoField() {
    return TextFormField(
      controller: memoController,
      decoration: const InputDecoration(
        labelText: 'メモ (場所など)',
      ),
    );
  }

  /// 共通のメンバー入力UIを構築
  Widget buildMemberInput(List<TextEditingController> memberControllers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('メンバー', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        ...memberControllers.asMap().entries.map((entry) {
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
                      if (memberControllers.length > 1) {
                        controller.dispose();
                        memberControllers.removeAt(index);
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
              memberControllers.add(TextEditingController());
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('メンバーを追加'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.result != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '収支編集' : '収支追加'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                buildDateSelector(),
                buildAmountField(),
                const SizedBox(height: 16),
                buildCategorySpecificFields(),
                const SizedBox(height: 16),
                buildMemoField(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: saveResult,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('保存'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
