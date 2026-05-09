import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/machine_type.dart';
import '../../models/place.dart';
import '../../models/reviews/slot_machine_review.dart';
import '../../models/reviews/pachinko_place_review.dart';
import '../../services/slot_machine_type_service.dart';
import '../../services/place_service.dart';
import '../../services/reviews/review_service.dart';
import '../../widgets/star_rating_input.dart';

class ReviewSlotTab extends StatefulWidget {
  const ReviewSlotTab({Key? key}) : super(key: key);

  @override
  State<ReviewSlotTab> createState() => _ReviewSlotTabState();
}

class _ReviewSlotTabState extends State<ReviewSlotTab> {
  String _mode = 'machine'; // 'machine' or 'place'
  final _slotMachineTypeService = SlotMachineTypeService();
  final _placeService = PlaceService();
  final _reviewService = ReviewService();

  // Sort and Filter States
  Map<String, int> _minRatings = {};
  String _sortField = 'name';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _resetRatings();
  }

  void _resetRatings() {
    _minRatings = {
      'overall': 0,
      'explosive': 0,
      'soundEffect': 0,
      'production': 0,
      'setting': 0,
      'atmosphere': 0,
      'staff': 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スロット レビュー'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSortSheet,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'machine', label: Text('台')),
                ButtonSegment(value: 'place', label: Text('店舗')),
              ],
              selected: {_mode},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _mode = newSelection.first;
                });
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          Expanded(
            child: _mode == 'machine' ? _buildMachineList() : _buildPlaceList(),
          ),
        ],
      ),
    );
  }

  void _showFilterSortSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('絞り込みと並べ替え',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              _resetRatings();
                              _sortField = 'name';
                              _sortAscending = false;
                            });
                            setState(() {});
                          },
                          child: const Text('クリア'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('最低評価', style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildSliderRow('総合評価', 'overall', setSheetState),
                    if (_mode == 'machine') ...[
                      _buildSliderRow('爆発力', 'explosive', setSheetState),
                      _buildSliderRow('効果音', 'soundEffect', setSheetState),
                      _buildSliderRow('演出', 'production', setSheetState),
                    ] else ...[
                      _buildSliderRow('設定', 'setting', setSheetState),
                      _buildSliderRow('雰囲気', 'atmosphere', setSheetState),
                      _buildSliderRow('店員', 'staff', setSheetState),
                    ],
                    const Divider(),
                    const Text('並べ替え', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8.0,
                      children: [
                        ChoiceChip(
                          label: const Text('名前'),
                          selected: _sortField == 'name',
                          onSelected: (v) {
                            setSheetState(() => _sortField = 'name');
                            setState(() {});
                          },
                        ),
                        ChoiceChip(
                          label: const Text('総合評価'),
                          selected: _sortField == 'overall',
                          onSelected: (v) {
                            setSheetState(() => _sortField = 'overall');
                            setState(() {});
                          },
                        ),
                        if (_mode == 'machine') ...[
                          ChoiceChip(
                            label: const Text('爆発力'),
                            selected: _sortField == 'explosive',
                            onSelected: (v) {
                              setSheetState(() => _sortField = 'explosive');
                              setState(() {});
                            },
                          ),
                          ChoiceChip(
                            label: const Text('効果音'),
                            selected: _sortField == 'soundEffect',
                            onSelected: (v) {
                              setSheetState(() => _sortField = 'soundEffect');
                              setState(() {});
                            },
                          ),
                          ChoiceChip(
                            label: const Text('演出'),
                            selected: _sortField == 'production',
                            onSelected: (v) {
                              setSheetState(() => _sortField = 'production');
                              setState(() {});
                            },
                          ),
                        ] else ...[
                          ChoiceChip(
                            label: const Text('設定'),
                            selected: _sortField == 'setting',
                            onSelected: (v) {
                              setSheetState(() => _sortField = 'setting');
                              setState(() {});
                            },
                          ),
                          ChoiceChip(
                            label: const Text('雰囲気'),
                            selected: _sortField == 'atmosphere',
                            onSelected: (v) {
                              setSheetState(() => _sortField = 'atmosphere');
                              setState(() {});
                            },
                          ),
                          ChoiceChip(
                            label: const Text('店員'),
                            selected: _sortField == 'staff',
                            onSelected: (v) {
                              setSheetState(() => _sortField = 'staff');
                              setState(() {});
                            },
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        const Text('順序: '),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _sortAscending,
                            onChanged: (val) {
                              setSheetState(() => _sortAscending = val);
                              setState(() => _sortAscending = val);
                            },
                          ),
                        ),
                        Text(_sortAscending ? '昇順 (低-高, A-Z)' : '降順 (高-低, Z-A)'),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSliderRow(String label, String key, StateSetter setSheetState) {
    int val = _minRatings[key] ?? 0;
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label)),
        Expanded(
          child: Slider(
            value: val.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            label: val == 0 ? 'すべて' : '$val 以上',
            onChanged: (newVal) {
              setSheetState(() => _minRatings[key] = newVal.toInt());
              setState(() => _minRatings[key] = newVal.toInt());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMachineList() {
    final stream = Rx.combineLatest2(
      _slotMachineTypeService.getMachineTypes(),
      _reviewService.getSlotMachineReviews(),
      (List<MachineType> machines, List<SlotMachineReview> reviews) {
        return machines.map((m) {
          final review = reviews.where((r) => r.machineId == m.id).firstOrNull;
          return _MachineItemData(machine: m, review: review);
        }).toList();
      },
    );

    return StreamBuilder<List<_MachineItemData>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var list = snapshot.data!;

        // Filter
        list = list.where((item) {
          final r = item.review;
          if (r == null) return _minRatings.values.every((v) => v == 0);
          return r.overall >= (_minRatings['overall'] ?? 0) &&
              r.explosive >= (_minRatings['explosive'] ?? 0) &&
              r.soundEffect >= (_minRatings['soundEffect'] ?? 0) &&
              r.production >= (_minRatings['production'] ?? 0);
        }).toList();

        // Sort
        list.sort((a, b) {
          int cmp = 0;
          if (_sortField == 'name') {
            cmp = a.machine.name.compareTo(b.machine.name);
          } else {
            final rA = a.review;
            final rB = b.review;
            int valA = 0;
            int valB = 0;
            if (rA != null) {
              if (_sortField == 'overall') valA = rA.overall;
              else if (_sortField == 'explosive') valA = rA.explosive;
              else if (_sortField == 'soundEffect') valA = rA.soundEffect;
              else if (_sortField == 'production') valA = rA.production;
            }
            if (rB != null) {
              if (_sortField == 'overall') valB = rB.overall;
              else if (_sortField == 'explosive') valB = rB.explosive;
              else if (_sortField == 'soundEffect') valB = rB.soundEffect;
              else if (_sortField == 'production') valB = rB.production;
            }
            cmp = valA.compareTo(valB);
          }
          return _sortAscending ? cmp : -cmp;
        });

        if (list.isEmpty) return const Center(child: Text('データがありません'));

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final r = item.review;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => _showMachineReviewSheet(item.machine, r),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.machine.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showMachineReviewSheet(item.machine, r),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      if (r != null) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12.0,
                          runSpacing: 4.0,
                          children: [
                            _buildRatingBadge('総合', r.overall),
                            _buildRatingBadge('爆発', r.explosive),
                            _buildRatingBadge('効果', r.soundEffect),
                            _buildRatingBadge('演出', r.production),
                          ],
                        ),
                        if (r.memo.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.notes, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  r.memo,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ] else ...[
                        const SizedBox(height: 8),
                        const Text('未評価', style: TextStyle(color: Colors.grey)),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceList() {
    final stream = Rx.combineLatest2(
      _placeService.getPlaces('pachinko'),
      _reviewService.getPachinkoPlaceReviews(),
      (List<Place> places, List<PachinkoPlaceReview> reviews) {
        return places.map((p) {
          final review = reviews.where((r) => r.placeId == p.id).firstOrNull;
          return _PlaceItemData(place: p, review: review);
        }).toList();
      },
    );

    return StreamBuilder<List<_PlaceItemData>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var list = snapshot.data!;

        list = list.where((item) {
          final r = item.review;
          if (r == null) return _minRatings.values.every((v) => v == 0);
          return r.overall >= (_minRatings['overall'] ?? 0) &&
              r.setting >= (_minRatings['setting'] ?? 0) &&
              r.atmosphere >= (_minRatings['atmosphere'] ?? 0) &&
              r.staff >= (_minRatings['staff'] ?? 0);
        }).toList();

        list.sort((a, b) {
          int cmp = 0;
          if (_sortField == 'name') {
            cmp = a.place.name.compareTo(b.place.name);
          } else {
            final rA = a.review;
            final rB = b.review;
            int valA = 0;
            int valB = 0;
            if (rA != null) {
              if (_sortField == 'overall') valA = rA.overall;
              else if (_sortField == 'setting') valA = rA.setting;
              else if (_sortField == 'atmosphere') valA = rA.atmosphere;
              else if (_sortField == 'staff') valA = rA.staff;
            }
            if (rB != null) {
              if (_sortField == 'overall') valB = rB.overall;
              else if (_sortField == 'setting') valB = rB.setting;
              else if (_sortField == 'atmosphere') valB = rB.atmosphere;
              else if (_sortField == 'staff') valB = rB.staff;
            }
            cmp = valA.compareTo(valB);
          }
          return _sortAscending ? cmp : -cmp;
        });

        if (list.isEmpty) return const Center(child: Text('データがありません'));

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final r = item.review;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => _showPlaceReviewSheet(item.place, r),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.place.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showPlaceReviewSheet(item.place, r),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      if (r != null) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12.0,
                          runSpacing: 4.0,
                          children: [
                            _buildRatingBadge('総合', r.overall),
                            _buildRatingBadge('設定', r.setting),
                            _buildRatingBadge('雰囲', r.atmosphere),
                            _buildRatingBadge('店員', r.staff),
                          ],
                        ),
                        if (r.memo.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.notes, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  r.memo,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ] else ...[
                        const SizedBox(height: 8),
                        const Text('未評価', style: TextStyle(color: Colors.grey)),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMachineReviewSheet(MachineType machine, SlotMachineReview? initialReview) {
    int overall = initialReview?.overall ?? 3;
    int explosive = initialReview?.explosive ?? 3;
    int soundEffect = initialReview?.soundEffect ?? 3;
    int production = initialReview?.production ?? 3;
    final memoController = TextEditingController(text: initialReview?.memo ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${machine.name} のレビュー',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildRatingRow('総合評価', overall, (v) => setSheetState(() => overall = v)),
                    _buildRatingRow('爆発力', explosive, (v) => setSheetState(() => explosive = v)),
                    _buildRatingRow('効果音', soundEffect, (v) => setSheetState(() => soundEffect = v)),
                    _buildRatingRow('演出', production, (v) => setSheetState(() => production = v)),
                    TextField(
                      controller: memoController,
                      decoration: const InputDecoration(labelText: 'メモ'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final review = SlotMachineReview(
                            id: initialReview?.id,
                            machineId: machine.id!,
                            overall: overall,
                            explosive: explosive,
                            soundEffect: soundEffect,
                            production: production,
                            memo: memoController.text,
                            createdAt: initialReview?.createdAt ?? DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          await _reviewService.saveSlotMachineReview(review);
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('保存'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPlaceReviewSheet(Place place, PachinkoPlaceReview? initialReview) {
    int overall = initialReview?.overall ?? 3;
    int setting = initialReview?.setting ?? 3;
    int atmosphere = initialReview?.atmosphere ?? 3;
    int staff = initialReview?.staff ?? 3;
    final memoController = TextEditingController(text: initialReview?.memo ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${place.name} のレビュー',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildRatingRow('総合評価', overall, (v) => setSheetState(() => overall = v)),
                    _buildRatingRow('設定', setting, (v) => setSheetState(() => setting = v)),
                    _buildRatingRow('雰囲気', atmosphere, (v) => setSheetState(() => atmosphere = v)),
                    _buildRatingRow('店員', staff, (v) => setSheetState(() => staff = v)),
                    TextField(
                      controller: memoController,
                      decoration: const InputDecoration(labelText: 'メモ'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final review = PachinkoPlaceReview(
                            id: initialReview?.id,
                            placeId: place.id!,
                            overall: overall,
                            rotation: initialReview?.rotation ?? 3,
                            setting: setting,
                            atmosphere: atmosphere,
                            staff: staff,
                            memo: memoController.text,
                            createdAt: initialReview?.createdAt ?? DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          await _reviewService.savePachinkoPlaceReview(review);
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('保存'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRatingRow(String label, int rating, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          StarRatingInput(rating: rating, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildRatingBadge(String label, int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        StarRatingDisplay(rating: rating, size: 12),
      ],
    );
  }
}

class _MachineItemData {
  final MachineType machine;
  final SlotMachineReview? review;
  _MachineItemData({required this.machine, this.review});
}

class _PlaceItemData {
  final Place place;
  final PachinkoPlaceReview? review;
  _PlaceItemData({required this.place, this.review});
}
