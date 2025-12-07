import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mahjong_result.dart';
import '../services/firestore_service.dart';
import '../models/horse_racing_result.dart';
import '../models/boat_racing_result.dart';
import '../models/auto_racing_result.dart';
import '../models/keirin_result.dart';

class EditScreen extends StatefulWidget {
  final dynamic result;
  final String categoryType;

  const EditScreen({
    super.key,
    this.result,
    required this.categoryType,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late DateTime _selectedDate;
  late TextEditingController _amountController;
  late TextEditingController _memoController;
  late TextEditingController _betTypeController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.result?.date ?? DateTime.now();
    _amountController = TextEditingController(
      text: widget.result?.amount.toString() ?? '',
    );
    _memoController = TextEditingController(text: widget.result?.memo ?? '');

    String initialBetType = '';
    if (widget.result != null) {
      if (widget.result is HorseRacingResult) {
        initialBetType = (widget.result as HorseRacingResult).betType;
      } else if (widget.result is BoatRacingResult) {
        initialBetType = (widget.result as BoatRacingResult).betType;
      } else if (widget.result is AutoRacingResult) {
        initialBetType = (widget.result as AutoRacingResult).betType;
      } else if (widget.result is KeirinResult) {
        initialBetType = (widget.result as KeirinResult).betType;
      }
    }
    _betTypeController = TextEditingController(text: initialBetType);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    _betTypeController.dispose();
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
      final betType = _betTypeController.text;

      try {
        switch (widget.categoryType) {
          case 'mahjong':
            final newResult = MahjongResult(
              id: widget.result?.id,
              date: _selectedDate,
              amount: amount,
              memo: memo,
              createdAt: widget.result?.createdAt ?? DateTime.now(),
            );
            if (widget.result == null) {
              await _firestoreService.addMahjongResult(newResult);
            } else {
              await _firestoreService.updateMahjongResult(newResult);
            }
            break;

          case 'horse_racing':
            final newResult = HorseRacingResult(
              id: widget.result?.id,
              date: _selectedDate,
              amount: amount,
              betType: betType,
              memo: memo,
              createdAt: widget.result?.createdAt ?? DateTime.now(),
            );
            if (widget.result == null) {
              await _firestoreService.addHorseRacingResult(newResult);
            } else {
              await _firestoreService.updateHorseRacingResult(newResult);
            }
            break;

          case 'boat_racing':
            final newResult = BoatRacingResult(
              id: widget.result?.id,
              date: _selectedDate,
              amount: amount,
              betType: betType,
              memo: memo,
              createdAt: widget.result?.createdAt ?? DateTime.now(),
            );
            if (widget.result == null) {
              await _firestoreService.addBoatRacingResult(newResult);
            } else {
              await _firestoreService.updateBoatRacingResult(newResult);
            }
            break;

          case 'auto_racing':
            final newResult = AutoRacingResult(
              id: widget.result?.id,
              date: _selectedDate,
              amount: amount,
              betType: betType,
              memo: memo,
              createdAt: widget.result?.createdAt ?? DateTime.now(),
            );
            if (widget.result == null) {
              await _firestoreService.addAutoRacingResult(newResult);
            } else {
              await _firestoreService.updateAutoRacingResult(newResult);
            }
            break;

          case 'keirin':
            final newResult = KeirinResult(
              id: widget.result?.id,
              date: _selectedDate,
              amount: amount,
              betType: betType,
              memo: memo,
              createdAt: widget.result?.createdAt ?? DateTime.now(),
            );
            if (widget.result == null) {
              await _firestoreService.addKeirinResult(newResult);
            } else {
              await _firestoreService.updateKeirinResult(newResult);
            }
            break;
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
    final isRacing = widget.categoryType != 'mahjong';

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
              if (isRacing) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _betTypeController,
                  decoration: const InputDecoration(
                    labelText: '賭け方 (単勝、3連単など)',
                  ),
                ),
              ],
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
