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
      createResult: ({
        id,
        required date,
        required amount,
        betType,
        required memo,
        required createdAt,
        type,
        umaRate,
        priceRate,
        chipRate,
        member,
        place,
        machine,
      }) =>
          MahjongResult(
        id: id,
        date: date,
        amount: amount,
        memo: memo,
        createdAt: createdAt,
        type: type ?? '四麻',
        umaRate: umaRate ?? '10-30',
        priceRate: priceRate ?? 'テンピン',
        chipRate: chipRate ?? 50,
        member: member ?? [],
      ),
    ),
    'horse_racing': CategoryHandler(
      streamGetter: () =>
          _horseRacingService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _horseRacingService.deleteResult(id),
      add: (result) => _horseRacingService.addResult(result),
      update: (result) => _horseRacingService.updateResult(result),
      createResult: ({
        id,
        required date,
        required amount,
        betType,
        required memo,
        required createdAt,
        type,
        umaRate,
        priceRate,
        chipRate,
        member,
        place,
        machine,
      }) =>
          HorseRacingResult(
        id: id,
        date: date,
        amount: amount,
        betType: betType ?? '単勝',
        memo: memo,
        createdAt: createdAt,
      ),
    ),
    'boat_racing': CategoryHandler(
      streamGetter: () =>
          _boatRacingService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _boatRacingService.deleteResult(id),
      add: (result) => _boatRacingService.addResult(result),
      update: (result) => _boatRacingService.updateResult(result),
      createResult: ({
        id,
        required date,
        required amount,
        betType,
        required memo,
        required createdAt,
        type,
        umaRate,
        priceRate,
        chipRate,
        member,
        place,
        machine,
      }) =>
          BoatRacingResult(
        id: id,
        date: date,
        amount: amount,
        betType: betType ?? '単勝',
        memo: memo,
        createdAt: createdAt,
      ),
    ),
    'auto_racing': CategoryHandler(
      streamGetter: () =>
          _autoRacingService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _autoRacingService.deleteResult(id),
      add: (result) => _autoRacingService.addResult(result),
      update: (result) => _autoRacingService.updateResult(result),
      createResult: ({
        id,
        required date,
        required amount,
        betType,
        required memo,
        required createdAt,
        type,
        umaRate,
        priceRate,
        chipRate,
        member,
        place,
        machine,
      }) =>
          AutoRacingResult(
        id: id,
        date: date,
        amount: amount,
        betType: betType ?? '単勝',
        memo: memo,
        createdAt: createdAt,
      ),
    ),
    'keirin': CategoryHandler(
      streamGetter: () =>
          _keirinService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _keirinService.deleteResult(id),
      add: (result) => _keirinService.addResult(result),
      update: (result) => _keirinService.updateResult(result),
      createResult: ({
        id,
        required date,
        required amount,
        betType,
        required memo,
        required createdAt,
        type,
        umaRate,
        priceRate,
        chipRate,
        member,
        place,
        machine,
      }) =>
          KeirinResult(
        id: id,
        date: date,
        amount: amount,
        betType: betType ?? '単勝',
        memo: memo,
        createdAt: createdAt,
      ),
    ),
    'pachinko': CategoryHandler(
      streamGetter: () =>
          _pachinkoService.getResults().map((list) => list.cast<dynamic>()),
      delete: (id) => _pachinkoService.deleteResult(id),
      add: (result) => _pachinkoService.addResult(result),
      update: (result) => _pachinkoService.updateResult(result),
      createResult: ({
        id,
        required date,
        required amount,
        betType,
        required memo,
        required createdAt,
        type,
        umaRate,
        priceRate,
        chipRate,
        member,
        place,
        machine,
      }) =>
          PachinkoResult(
        id: id,
        date: date,
        amount: amount,
        memo: memo,
        createdAt: createdAt,
        type: type ?? 'ソロ',
        member: member ?? [],
        place: place ?? '',
        machine: machine ?? '',
      ),
    ),
  };

  late DateTime _selectedDate;
  late TextEditingController _amountController;
  late TextEditingController _memoController;
  final List<TextEditingController> _memberControllers = [];
  late TextEditingController _placeController;
  late TextEditingController _machineController;

  // Mahjong specific
  String? _mahjongType;
  String? _umaRate;
  String? _priceRate = 'テンピン';
  int _chipRate = 50;

  // Racing specific
  String _betType = '単勝';

  // Pachinko specific
  String _pachinkoType = 'ソロ';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.result?.date ?? DateTime.now();
    _amountController = TextEditingController(
      text: widget.result?.amount.toString() ?? '',
    );
    _memoController = TextEditingController(text: widget.result?.memo ?? '');

    // Init Mahjong
    if (widget.result is MahjongResult) {
      final res = widget.result as MahjongResult;
      _mahjongType = res.type;
      _umaRate = res.umaRate;
      _priceRate = res.priceRate;
      _chipRate = res.chipRate;
      _initMemberControllers(res.member);
    } else {
      // Default to null to force selection or based on requirements
      _mahjongType = null;
      _umaRate = null;
      // Start with one empty controller
      if (_memberControllers.isEmpty) {
        _memberControllers.add(TextEditingController());
      }
    }

    // Init Racing
    if (widget.result != null) {
      if (widget.result is HorseRacingResult) {
        _betType = (widget.result as HorseRacingResult).betType;
      } else if (widget.result is BoatRacingResult) {
        _betType = (widget.result as BoatRacingResult).betType;
      } else if (widget.result is AutoRacingResult) {
        _betType = (widget.result as AutoRacingResult).betType;
      } else if (widget.result is KeirinResult) {
        _betType = (widget.result as KeirinResult).betType;
      }
    }

    // Init Pachinko
    if (widget.result is PachinkoResult) {
      final res = widget.result as PachinkoResult;
      _pachinkoType = res.type;
      _initMemberControllers(res.member);
      _placeController = TextEditingController(text: res.place);
      _machineController = TextEditingController(text: res.machine);
    } else {
      _placeController = TextEditingController();
      _machineController = TextEditingController();
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
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    for (var controller in _memberControllers) {
      controller.dispose();
    }
    _placeController.dispose();
    _machineController.dispose();
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

      // Parse members
      final memberList = _memberControllers
          .map((c) => c.text.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      try {
        final handler = _handlers[widget.categoryType];
        if (handler == null) return;

        final newResult = handler.createResult!(
          id: widget.result?.id,
          date: _selectedDate,
          amount: amount,
          betType: _betType,
          memo: memo,
          createdAt: widget.result?.createdAt ?? DateTime.now(),
          type: widget.categoryType == 'mahjong'
              ? (_mahjongType ??
                  '四麻') // Default if null, but should be validated
              : (widget.categoryType == 'pachinko' ? _pachinkoType : null),
          umaRate:
              widget.categoryType == 'mahjong' ? (_umaRate ?? '10-30') : null,
          priceRate: widget.categoryType == 'mahjong' ? _priceRate : null,
          chipRate: widget.categoryType == 'mahjong' ? _chipRate : null,
          member: (widget.categoryType == 'mahjong' ||
                  (widget.categoryType == 'pachinko' &&
                      _pachinkoType == '乗り打ち'))
              ? memberList
              : null,
          place:
              widget.categoryType == 'pachinko' ? _placeController.text : null,
          machine: widget.categoryType == 'pachinko'
              ? _machineController.text
              : null,
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
      body: SingleChildScrollView(
        child: Padding(
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

                // Mahjong Fields
                if (widget.categoryType == 'mahjong') ...[
                  DropdownButtonFormField<String>(
                    value: _mahjongType,
                    decoration: const InputDecoration(labelText: 'タイプ'),
                    items: MahjongResult.types.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _mahjongType = v;
                        _umaRate = null; // Reset uma when type changes
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
                  const SizedBox(height: 16),
                  _buildMemberInput(),
                ],

                // Racing Fields
                if (isRacing) ...[
                  DropdownButtonFormField<String>(
                    value: _betType,
                    decoration: const InputDecoration(labelText: '賭け方'),
                    items:
                        _getBetTypesForCategory(widget.categoryType).map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (v) => setState(() => _betType = v!),
                    validator: (v) => v == null ? '賭け方を選択してください' : null,
                  ),
                ],

                // Pachinko Fields
                if (widget.categoryType == 'pachinko') ...[
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
                    _buildMemberInput(),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _placeController,
                    decoration: const InputDecoration(
                      labelText: '場所',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return '場所を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _machineController,
                    decoration: const InputDecoration(
                      labelText: '台の種類',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return '台の種類を入力してください';
                      }
                      return null;
                    },
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
      ),
    );
  }

  List<String> _getBetTypesForCategory(String category) {
    switch (category) {
      case 'horse_racing':
        return HorseRacingResult.betTypes;
      case 'boat_racing':
        return BoatRacingResult.betTypes;
      case 'auto_racing':
        return AutoRacingResult.betTypes;
      case 'keirin':
        return KeirinResult.betTypes;
      default:
        return ['単勝'];
    }
  }

  List<String> _getUmaRatesForType(String type) {
    if (type == '三麻') {
      return MahjongResult.umaRates3ma;
    } else if (type == '四麻') {
      return MahjongResult.umaRates4ma;
    }
    return [];
  }

  Widget _buildMemberInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('メンバー', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
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
}
