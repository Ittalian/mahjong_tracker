import 'package:flutter/material.dart';
import '../../models/reviews/racer_review.dart';
import '../../services/reviews/review_service.dart';
import '../../widgets/star_rating_input.dart';

class ReviewRacerTab extends StatefulWidget {
  final String category; // 'keirin', 'boat_racing', 'auto_racing'
  
  const ReviewRacerTab({Key? key, required this.category}) : super(key: key);

  @override
  State<ReviewRacerTab> createState() => _ReviewRacerTabState();
}

class _ReviewRacerTabState extends State<ReviewRacerTab> {
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
      'technique': 0,
      'mental': 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    String title = '選手レビュー';
    if (widget.category == 'keirin') title = '競輪 レビュー';
    if (widget.category == 'boat_racing') title = '競艇 レビュー';
    if (widget.category == 'auto_racing') title = 'オート レビュー';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSortSheet,
          )
        ],
      ),
      body: _buildRacerList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRacerReviewSheet(null),
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
                    _buildSliderRow('スピード', 'speed', setSheetState),
                    _buildSliderRow('技術', 'technique', setSheetState),
                    _buildSliderRow('メンタル', 'mental', setSheetState),
                    const Divider(),
                    const Text('並べ替え', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8.0,
                      children: [
                        ChoiceChip(label: const Text('名前'), selected: _sortField == 'name', onSelected: (v) { setSheetState(() => _sortField = 'name'); setState(() {}); }),
                        ChoiceChip(label: const Text('総合評価'), selected: _sortField == 'overall', onSelected: (v) { setSheetState(() => _sortField = 'overall'); setState(() {}); }),
                        ChoiceChip(label: const Text('スピード'), selected: _sortField == 'speed', onSelected: (v) { setSheetState(() => _sortField = 'speed'); setState(() {}); }),
                        ChoiceChip(label: const Text('技術'), selected: _sortField == 'technique', onSelected: (v) { setSheetState(() => _sortField = 'technique'); setState(() {}); }),
                        ChoiceChip(label: const Text('メンタル'), selected: _sortField == 'mental', onSelected: (v) { setSheetState(() => _sortField = 'mental'); setState(() {}); }),
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

  Widget _buildRacerList() {
    return StreamBuilder<List<RacerReview>>(
      stream: _reviewService.getRacerReviews(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var list = snapshot.data!;

        // 対象のカテゴリのみフィルタリング
        list = list.where((r) {
          if (r.category != widget.category) return false;
          return r.overall >= (_minRatings['overall'] ?? 0) &&
                 r.speed >= (_minRatings['speed'] ?? 0) &&
                 r.technique >= (_minRatings['technique'] ?? 0) &&
                 r.mental >= (_minRatings['mental'] ?? 0);
        }).toList();

        list.sort((a, b) {
          int cmp = 0;
          if (_sortField == 'name') {
            cmp = a.name.compareTo(b.name);
          } else {
            int valA = 0; int valB = 0;
            if (_sortField == 'overall') { valA = a.overall; valB = b.overall; }
            else if (_sortField == 'speed') { valA = a.speed; valB = b.speed; }
            else if (_sortField == 'technique') { valA = a.technique; valB = b.technique; }
            else if (_sortField == 'mental') { valA = a.mental; valB = b.mental; }
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
                onTap: () => _showRacerReviewSheet(r),
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
                              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showRacerReviewSheet(r), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                              const SizedBox(width: 16),
                              IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _confirmDelete(r.id!), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
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
                           _buildRatingBadge('技術', r.technique),
                           _buildRatingBadge('メンタル', r.mental),
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

  Future<void> _confirmDelete(String id) async {
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
      await _reviewService.deleteRacerReview(id);
    }
  }

  void _showRacerReviewSheet(RacerReview? initialReview) {
    final nameController = TextEditingController(text: initialReview?.name ?? '');
    int overall = initialReview?.overall ?? 3;
    int speed = initialReview?.speed ?? 3;
    int technique = initialReview?.technique ?? 3;
    int mental = initialReview?.mental ?? 3;
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
                      Text(initialReview == null ? '選手の追加' : '選手レビューの編集', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: '選手名'),
                        validator: (val) => val == null || val.isEmpty ? '選手名を入力してください' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildRatingRow('総合評価', overall, (v) => setSheetState(() => overall = v)),
                      _buildRatingRow('スピード', speed, (v) => setSheetState(() => speed = v)),
                      _buildRatingRow('技術', technique, (v) => setSheetState(() => technique = v)),
                      _buildRatingRow('メンタル', mental, (v) => setSheetState(() => mental = v)),
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
                              final review = RacerReview(
                                id: initialReview?.id,
                                name: nameController.text,
                                category: widget.category,
                                overall: overall,
                                speed: speed,
                                technique: technique,
                                mental: mental,
                                memo: memoController.text,
                                createdAt: initialReview?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              await _reviewService.saveRacerReview(review);
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
