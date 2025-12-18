import 'package:flutter/material.dart';
import 'package:mahjong_tracker/models/mahjong_result.dart';
import 'package:intl/intl.dart';
import 'package:mahjong_tracker/models/horse_racing_result.dart';
import 'package:mahjong_tracker/models/boat_racing_result.dart';
import 'package:mahjong_tracker/models/auto_racing_result.dart';
import 'package:mahjong_tracker/models/keirin_result.dart';
import 'package:mahjong_tracker/models/pachinko_result.dart';
import 'package:mahjong_tracker/services/category_handler.dart';
import 'package:mahjong_tracker/services/mahjong/mahjong_service.dart';
import 'package:mahjong_tracker/services/horse_racing/horse_racing_service.dart';
import 'package:mahjong_tracker/services/boat_racing/boat_racing_service.dart';
import 'package:mahjong_tracker/services/auto_racing/auto_racing_service.dart';
import 'package:mahjong_tracker/services/keirin/keirin_service.dart';
import 'package:mahjong_tracker/services/pachinko/pachinko_service.dart';

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
  final _mahjongService = MahjongService();
  final _horseRacingService = HorseRacingService();
  final _boatRacingService = BoatRacingService();
  final _autoRacingService = AutoRacingService();
  final _keirinService = KeirinService();
  final _pachinkoService = PachinkoService();

  late final Map<String, CategoryHandler> _handlers = {
    'mahjong': CategoryHandler(
      streamGetter: () =>
          _mahjongService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _mahjongService.deleteResult(id),
      add: (result) => _mahjongService.addResult(result),
      update: (result) => _mahjongService.updateResult(result),
      createResult: (
              {id,
              required date,
              required amount,
              betType,
              required memo,
              required createdAt}) =>
          MahjongResult(
              id: id,
              date: date,
              amount: amount,
              memo: memo,
              createdAt: createdAt),
    ),
    'horse_racing': CategoryHandler(
      streamGetter: () =>
          _horseRacingService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _horseRacingService.deleteResult(id),
      add: (result) => _horseRacingService.addResult(result),
      update: (result) => _horseRacingService.updateResult(result),
      createResult: (
              {id,
              required date,
              required amount,
              betType,
              required memo,
              required createdAt}) =>
          HorseRacingResult(
              id: id,
              date: date,
              amount: amount,
              betType: betType ?? '',
              memo: memo,
              createdAt: createdAt),
    ),
    'boat_racing': CategoryHandler(
      streamGetter: () =>
          _boatRacingService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _boatRacingService.deleteResult(id),
      add: (result) => _boatRacingService.addResult(result),
      update: (result) => _boatRacingService.updateResult(result),
      createResult: (
              {id,
              required date,
              required amount,
              betType,
              required memo,
              required createdAt}) =>
          BoatRacingResult(
              id: id,
              date: date,
              amount: amount,
              betType: betType ?? '',
              memo: memo,
              createdAt: createdAt),
    ),
    'auto_racing': CategoryHandler(
      streamGetter: () =>
          _autoRacingService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _autoRacingService.deleteResult(id),
      add: (result) => _autoRacingService.addResult(result),
      update: (result) => _autoRacingService.updateResult(result),
      createResult: (
              {id,
              required date,
              required amount,
              betType,
              required memo,
              required createdAt}) =>
          AutoRacingResult(
              id: id,
              date: date,
              amount: amount,
              betType: betType ?? '',
              memo: memo,
              createdAt: createdAt),
    ),
    'keirin': CategoryHandler(
      streamGetter: () =>
          _keirinService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _keirinService.deleteResult(id),
      add: (result) => _keirinService.addResult(result),
      update: (result) => _keirinService.updateResult(result),
      createResult: (
              {id,
              required date,
              required amount,
              betType,
              required memo,
              required createdAt}) =>
          KeirinResult(
              id: id,
              date: date,
              amount: amount,
              betType: betType ?? '',
              memo: memo,
              createdAt: createdAt),
    ),
    'pachinko': CategoryHandler(
      streamGetter: () =>
          _pachinkoService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _pachinkoService.deleteResult(id),
      add: (result) => _pachinkoService.addResult(result),
      update: (result) => _pachinkoService.updateResult(result),
      createResult: (
              {id,
              required date,
              required amount,
              betType,
              required memo,
              required createdAt}) =>
          PachinkoResult(
              id: id,
              date: date,
              amount: amount,
              memo: memo,
              createdAt: createdAt),
    ),
  };

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
        final handler = _handlers[widget.categoryType];
        if (handler == null) return;

        final newResult = handler.createResult!(
          id: widget.result?.id,
          date: _selectedDate,
          amount: amount,
          betType: betType,
          memo: memo,
          createdAt: widget.result?.createdAt ?? DateTime.now(),
        );

        if (widget.result == null) {
          await handler.add(newResult);
        } else {
          await handler.update(newResult);
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
    final isRacing =
        widget.categoryType != 'mahjong' && widget.categoryType != 'pachinko';

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
