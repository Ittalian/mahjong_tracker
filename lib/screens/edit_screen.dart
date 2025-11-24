import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mahjong_result.dart';
import '../services/firestore_service.dart';

class EditScreen extends StatefulWidget {
  final MahjongResult? result;

  const EditScreen({super.key, this.result});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late DateTime _selectedDate;
  late TextEditingController _amountController;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.result?.date ?? DateTime.now();
    _amountController = TextEditingController(
      text: widget.result?.amount.toString() ?? '',
    );
    _memoController = TextEditingController(text: widget.result?.memo ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveResult() async {
    if (_formKey.currentState!.validate()) {
      final amount = int.tryParse(_amountController.text) ?? 0;
      final memo = _memoController.text;

      final newResult = MahjongResult(
        id: widget.result?.id,
        date: _selectedDate,
        amount: amount,
        memo: memo,
        createdAt: widget.result?.createdAt ?? DateTime.now(),
      );

      try {
        if (widget.result == null) {
          await _firestoreService.addResult(newResult);
        } else {
          await _firestoreService.updateResult(newResult);
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.result != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '収支編集' : '収支追加'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListTile(
                title: Text(
                  '日付: ${DateFormat('yyyy/MM/dd').format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: '金額 (プラスまたはマイナス)',
                  helperText: '例: 5000, -3000',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(signed: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '金額を入力してください';
                  }
                  if (int.tryParse(value) == null) {
                    return '有効な数値を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: 'メモ (場所など)',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveResult,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
