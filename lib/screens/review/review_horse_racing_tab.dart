import 'package:flutter/material.dart';
import '../../models/reviews/horse_review.dart';
import '../../models/reviews/jockey_review.dart';
import '../../services/reviews/review_service.dart';
import '../../widgets/star_rating_input.dart';

class ReviewHorseRacingTab extends StatefulWidget {
  const ReviewHorseRacingTab({Key? key}) : super(key: key);

  @override
  State<ReviewHorseRacingTab> createState() => _ReviewHorseRacingTabState();
}

class _ReviewHorseRacingTabState extends State<ReviewHorseRacingTab> {
  String _mode = 'horse'; // 'horse' or 'jockey'
  final _reviewService = ReviewService();

  Map<String, int> _minRatings = {};
  String _sortField = 'name'; // 'name', 'overall', 'speed', ...
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _resetRatings();
  }

  void _resetRatings() {
    _minRatings = {
      'overall': 0,
      'speed': 0,
      'stamina': 0,
      'power': 0,
      'technique': 0,
      'clutch': 0,
      'pace': 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('競馬 レビュー'),
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
                ButtonSegment(value: 'horse', label: Text('馬')),
                ButtonSegment(value: 'jockey', label: Text('騎手')),
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
            child: _mode == 'horse' ? _buildHorseList() : _buildJockeyList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_mode == 'horse') {
            _showHorseReviewSheet(null);
          } else {
            _showJockeyReviewSheet(null);
          }
        },
        child: const Icon(Icons.add),
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
                        const Text('絞り込みと並べ替え', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    if (_mode == 'horse') ...[
                      _buildSliderRow('スピード', 'speed', setSheetState),
                      _buildSliderRow('スタミナ', 'stamina', setSheetState),
                      _buildSliderRow('パワー', 'power', setSheetState),
                    ] else ...[
                      _buildSliderRow('技術', 'technique', setSheetState),
                      _buildSliderRow('勝負強さ', 'clutch', setSheetState),
                      _buildSliderRow('ペース', 'pace', setSheetState),
                    ],
                    const Divider(),
                    const Text('並べ替え', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8.0,
                      children: [
                        ChoiceChip(label: const Text('名前'), selected: _sortField == 'name', onSelected: (v) { setSheetState(() => _sortField = 'name'); setState(() {}); }),
                        ChoiceChip(label: const Text('総合評価'), selected: _sortField == 'overall', onSelected: (v) { setSheetState(() => _sortField = 'overall'); setState(() {}); }),
                        if (_mode == 'horse') ...[
                          ChoiceChip(label: const Text('スピード'), selected: _sortField == 'speed', onSelected: (v) { setSheetState(() => _sortField = 'speed'); setState(() {}); }),
                          ChoiceChip(label: const Text('スタミナ'), selected: _sortField == 'stamina', onSelected: (v) { setSheetState(() => _sortField = 'stamina'); setState(() {}); }),
                          ChoiceChip(label: const Text('パワー'), selected: _sortField == 'power', onSelected: (v) { setSheetState(() => _sortField = 'power'); setState(() {}); }),
                        ] else ...[
                          ChoiceChip(label: const Text('技術'), selected: _sortField == 'technique', onSelected: (v) { setSheetState(() => _sortField = 'technique'); setState(() {}); }),
                          ChoiceChip(label: const Text('勝負強さ'), selected: _sortField == 'clutch', onSelected: (v) { setSheetState(() => _sortField = 'clutch'); setState(() {}); }),
                          ChoiceChip(label: const Text('ペース'), selected: _sortField == 'pace', onSelected: (v) { setSheetState(() => _sortField = 'pace'); setState(() {}); }),
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

  Widget _buildHorseList() {
    return StreamBuilder<List<HorseReview>>(
      stream: _reviewService.getHorseReviews(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var list = snapshot.data!;

        list = list.where((r) {
          return r.overall >= (_minRatings['overall'] ?? 0) &&
                 r.speed >= (_minRatings['speed'] ?? 0) &&
                 r.stamina >= (_minRatings['stamina'] ?? 0) &&
                 r.power >= (_minRatings['power'] ?? 0);
        }).toList();

        list.sort((a, b) {
          int cmp = 0;
          if (_sortField == 'name') {
            cmp = a.name.compareTo(b.name);
          } else {
            int valA = 0; int valB = 0;
            if (_sortField == 'overall') { valA = a.overall; valB = b.overall; }
            else if (_sortField == 'speed') { valA = a.speed; valB = b.speed; }
            else if (_sortField == 'stamina') { valA = a.stamina; valB = b.stamina; }
            else if (_sortField == 'power') { valA = a.power; valB = b.power; }
            cmp = valA.compareTo(valB);
          }
          return _sortAscending ? cmp : -cmp;
        });

        if (list.isEmpty) return const Center(child: Text('データがありません'));

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final r = list[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => _showHorseReviewSheet(r),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(r.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showHorseReviewSheet(r), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                              const SizedBox(width: 16),
                              IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _confirmDelete(r.id!, 'horse'), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                            ],
                          )
                        ]
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 4.0,
                        children: [
                           _buildRatingBadge('総合', r.overall),
                           _buildRatingBadge('スピード', r.speed),
                           _buildRatingBadge('スタミナ', r.stamina),
                           _buildRatingBadge('パワー', r.power),
                        ]
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
                      ]
                    ]
                  )
                )
              )
            );
          },
        );
      },
    );
  }

  Widget _buildJockeyList() {
    return StreamBuilder<List<JockeyReview>>(
      stream: _reviewService.getJockeyReviews(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var list = snapshot.data!;

        list = list.where((r) {
          return r.overall >= (_minRatings['overall'] ?? 0) &&
                 r.technique >= (_minRatings['technique'] ?? 0) &&
                 r.clutch >= (_minRatings['clutch'] ?? 0) &&
                 r.pace >= (_minRatings['pace'] ?? 0);
        }).toList();

        list.sort((a, b) {
          int cmp = 0;
          if (_sortField == 'name') {
            cmp = a.name.compareTo(b.name);
          } else {
            int valA = 0; int valB = 0;
            if (_sortField == 'overall') { valA = a.overall; valB = b.overall; }
            else if (_sortField == 'technique') { valA = a.technique; valB = b.technique; }
            else if (_sortField == 'clutch') { valA = a.clutch; valB = b.clutch; }
            else if (_sortField == 'pace') { valA = a.pace; valB = b.pace; }
            cmp = valA.compareTo(valB);
          }
          return _sortAscending ? cmp : -cmp;
        });

        if (list.isEmpty) return const Center(child: Text('データがありません'));

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final r = list[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => _showJockeyReviewSheet(r),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(r.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showJockeyReviewSheet(r), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                              const SizedBox(width: 16),
                              IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _confirmDelete(r.id!, 'jockey'), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                            ],
                          )
                        ]
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 4.0,
                        children: [
                           _buildRatingBadge('総合', r.overall),
                           _buildRatingBadge('技術', r.technique),
                           _buildRatingBadge('勝負強さ', r.clutch),
                           _buildRatingBadge('ペース', r.pace),
                        ]
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
                      ]
                    ]
                  )
                )
              )
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(String id, String type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('このレビューを削除してもよろしいですか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (type == 'horse') {
        await _reviewService.deleteHorseReview(id);
      } else {
        await _reviewService.deleteJockeyReview(id);
      }
    }
  }

  void _showHorseReviewSheet(HorseReview? initialReview) {
    final nameController = TextEditingController(text: initialReview?.name ?? '');
    int overall = initialReview?.overall ?? 3;
    int speed = initialReview?.speed ?? 3;
    int stamina = initialReview?.stamina ?? 3;
    int power = initialReview?.power ?? 3;
    final memoController = TextEditingController(text: initialReview?.memo ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16, right: 16, top: 16
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(initialReview == null ? '馬の追加' : '馬レビューの編集', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: '馬名'),
                        validator: (val) => val == null || val.isEmpty ? '馬名を入力してください' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildRatingRow('総合評価', overall, (v) => setSheetState(() => overall = v)),
                      _buildRatingRow('スピード', speed, (v) => setSheetState(() => speed = v)),
                      _buildRatingRow('スタミナ', stamina, (v) => setSheetState(() => stamina = v)),
                      _buildRatingRow('パワー', power, (v) => setSheetState(() => power = v)),
                      TextFormField(
                        controller: memoController,
                        decoration: const InputDecoration(labelText: 'メモ'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final review = HorseReview(
                                id: initialReview?.id,
                                name: nameController.text,
                                overall: overall,
                                speed: speed,
                                stamina: stamina,
                                power: power,
                                memo: memoController.text,
                                createdAt: initialReview?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              await _reviewService.saveHorseReview(review);
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          child: const Text('保存'),
                        ),
                      ),
                      const SizedBox(height: 16),
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

  void _showJockeyReviewSheet(JockeyReview? initialReview) {
    final nameController = TextEditingController(text: initialReview?.name ?? '');
    int overall = initialReview?.overall ?? 3;
    int technique = initialReview?.technique ?? 3;
    int clutch = initialReview?.clutch ?? 3;
    int pace = initialReview?.pace ?? 3;
    final memoController = TextEditingController(text: initialReview?.memo ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16, right: 16, top: 16
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(initialReview == null ? '騎手の追加' : '騎手レビューの編集', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: '騎手名'),
                        validator: (val) => val == null || val.isEmpty ? '騎手名を入力してください' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildRatingRow('総合評価', overall, (v) => setSheetState(() => overall = v)),
                      _buildRatingRow('技術', technique, (v) => setSheetState(() => technique = v)),
                      _buildRatingRow('勝負強さ', clutch, (v) => setSheetState(() => clutch = v)),
                      _buildRatingRow('ペース配分', pace, (v) => setSheetState(() => pace = v)),
                      TextFormField(
                        controller: memoController,
                        decoration: const InputDecoration(labelText: 'メモ'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final review = JockeyReview(
                                id: initialReview?.id,
                                name: nameController.text,
                                overall: overall,
                                technique: technique,
                                clutch: clutch,
                                pace: pace,
                                memo: memoController.text,
                                createdAt: initialReview?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              await _reviewService.saveJockeyReview(review);
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          child: const Text('保存'),
                        ),
                      ),
                      const SizedBox(height: 16),
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
      ]
    );
  }
}
