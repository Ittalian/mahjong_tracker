import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/place.dart';
import '../../models/reviews/mahjong_place_review.dart';
import '../../services/place_service.dart';
import '../../services/reviews/review_service.dart';
import '../../widgets/star_rating_input.dart';

class ReviewMahjongTab extends StatefulWidget {
  const ReviewMahjongTab({Key? key}) : super(key: key);

  @override
  State<ReviewMahjongTab> createState() => _ReviewMahjongTabState();
}

class _ReviewMahjongTabState extends State<ReviewMahjongTab> {
  final _placeService = PlaceService();
  final _reviewService = ReviewService();

  Map<String, int> _minRatings = {};
  String _sortField = 'name'; // 'name', 'overall', 'access', ...
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _resetRatings();
  }

  void _resetRatings() {
    _minRatings = {
      'overall': 0,
      'access': 0,
      'price': 0,
      'atmosphere': 0,
      'staff': 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('麻雀 レビュー'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSortSheet,
          )
        ],
      ),
      body: _buildPlaceList(),
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
                    _buildSliderRow('アクセス', 'access', setSheetState),
                    _buildSliderRow('値段', 'price', setSheetState),
                    _buildSliderRow('雰囲気', 'atmosphere', setSheetState),
                    _buildSliderRow('店員', 'staff', setSheetState),
                    const Divider(),
                    const Text('並べ替え', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8.0,
                      children: [
                        ChoiceChip(label: const Text('名前'), selected: _sortField == 'name', onSelected: (v) { setSheetState(() => _sortField = 'name'); setState(() {}); }),
                        ChoiceChip(label: const Text('総合評価'), selected: _sortField == 'overall', onSelected: (v) { setSheetState(() => _sortField = 'overall'); setState(() {}); }),
                        ChoiceChip(label: const Text('アクセス'), selected: _sortField == 'access', onSelected: (v) { setSheetState(() => _sortField = 'access'); setState(() {}); }),
                        ChoiceChip(label: const Text('値段'), selected: _sortField == 'price', onSelected: (v) { setSheetState(() => _sortField = 'price'); setState(() {}); }),
                        ChoiceChip(label: const Text('雰囲気'), selected: _sortField == 'atmosphere', onSelected: (v) { setSheetState(() => _sortField = 'atmosphere'); setState(() {}); }),
                        ChoiceChip(label: const Text('店員'), selected: _sortField == 'staff', onSelected: (v) { setSheetState(() => _sortField = 'staff'); setState(() {}); }),
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

  Widget _buildPlaceList() {
    final stream = Rx.combineLatest2(
      _placeService.getPlaces('mahjong'),
      _reviewService.getMahjongPlaceReviews(),
      (List<Place> places, List<MahjongPlaceReview> reviews) {
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
                 r.access >= (_minRatings['access'] ?? 0) &&
                 r.price >= (_minRatings['price'] ?? 0) &&
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
            int valA = 0; int valB = 0;
            if (rA != null) {
              if (_sortField == 'overall') valA = rA.overall;
              else if (_sortField == 'access') valA = rA.access;
              else if (_sortField == 'price') valA = rA.price;
              else if (_sortField == 'atmosphere') valA = rA.atmosphere;
              else if (_sortField == 'staff') valA = rA.staff;
            }
            if (rB != null) {
              if (_sortField == 'overall') valB = rB.overall;
              else if (_sortField == 'access') valB = rB.access;
              else if (_sortField == 'price') valB = rB.price;
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
                          Expanded(child: Text(item.place.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showPlaceReviewSheet(item.place, r), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                        ]
                      ),
                      if (r != null) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12.0,
                          runSpacing: 4.0,
                          children: [
                             _buildRatingBadge('総合', r.overall),
                             _buildRatingBadge('ｱｸｾｽ', r.access),
                             _buildRatingBadge('値段', r.price),
                             _buildRatingBadge('雰囲', r.atmosphere),
                             _buildRatingBadge('店員', r.staff),
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
                      ] else ...[
                         const SizedBox(height: 8),
                         const Text('未評価', style: TextStyle(color: Colors.grey)),
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

  void _showPlaceReviewSheet(Place place, MahjongPlaceReview? initialReview) {
    int overall = initialReview?.overall ?? 3;
    int access = initialReview?.access ?? 3;
    int price = initialReview?.price ?? 3;
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
                left: 16, right: 16, top: 16
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${place.name} のレビュー', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildRatingRow('総合評価', overall, (v) => setSheetState(() => overall = v)),
                    _buildRatingRow('アクセス', access, (v) => setSheetState(() => access = v)),
                    _buildRatingRow('値段', price, (v) => setSheetState(() => price = v)),
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
                          final review = MahjongPlaceReview(
                            id: initialReview?.id,
                            placeId: place.id!,
                            overall: overall,
                            access: access,
                            price: price,
                            atmosphere: atmosphere,
                            staff: staff,
                            memo: memoController.text,
                            createdAt: initialReview?.createdAt ?? DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          await _reviewService.saveMahjongPlaceReview(review);
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
      ]
    );
  }
}

class _PlaceItemData {
  final Place place;
  final MahjongPlaceReview? review;
  _PlaceItemData({required this.place, this.review});
}
