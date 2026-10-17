import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahjong_tracker/utils/grouping_helper.dart';
import 'package:mahjong_tracker/utils/date_helper.dart';
import 'package:mahjong_tracker/screens/chart_screen.dart';
import 'package:mahjong_tracker/widgets/result_card.dart';
import 'package:mahjong_tracker/models/mahjong_result.dart';
import 'package:mahjong_tracker/models/pachinko_result.dart';
import 'package:mahjong_tracker/models/slot_result.dart';

/// 階層フィルタ情報を保持するクラス
class _HierarchyFilter {
  final String property; // プロパティ名（例: 'weekday', 'place', 'machine' 等）
  final String value; // 選択された値（例: '月曜日', '〇〇店' 等）
  final String propertyLabel; // プロパティ表示名（例: '曜日', '店舗' 等）
  final String dateUnit; // 日付の場合の単位

  _HierarchyFilter({
    required this.property,
    required this.value,
    required this.propertyLabel,
    this.dateUnit = 'year',
  });
}

class CategoryView extends StatefulWidget {
  final Map<String, dynamic> category;
  final Stream<List<dynamic>> Function() streamGetter;
  final Function(dynamic) onEdit;
  final Function(dynamic) onDelete;

  const CategoryView({
    super.key,
    required this.category,
    required this.streamGetter,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  bool _isDetailedView = false;
  String? _selectedGroupProperty;
  String? _subGroupProperty;
  final List<_HierarchyFilter> _hierarchyStack = [];
  bool _showRawRecords = false; // 現在の階層で集計ではなく個別記録一覧を表示するフラグ

  String _selectedDateUnit = 'year';
  DateTimeRange? _customDateRange;
  late final List<String> _groupableProperties;
  Map<String, String> _activeFilters = {};
  DateTimeRange? _filterDateRange;

  @override
  void initState() {
    super.initState();
    _groupableProperties =
        GroupingHelper.getGroupableProperties(widget.category['type']);
    if (_groupableProperties.isNotEmpty) {
      _selectedGroupProperty = _groupableProperties.first;
      _subGroupProperty = _getDefaultSubGroupProperty(_selectedGroupProperty!);
    }
  }

  /// 現在のプロパティと重複しないデフォルトのサブグループプロパティを取得
  String _getDefaultSubGroupProperty(String currentProperty) {
    final available = _groupableProperties
        .where((p) => p != currentProperty && p != 'compound')
        .toList();
    if (available.isEmpty) return _groupableProperties.first;

    // 曜日や日付の場合は店舗を優先
    if ((currentProperty == 'weekday' || currentProperty == 'date') &&
        available.contains('place')) {
      return 'place';
    }
    // 店舗の場合は台の種類を優先
    if (currentProperty == 'place' && available.contains('machine')) {
      return 'machine';
    }
    return available.first;
  }

  /// 階層スタックの条件を順番に適用して結果を絞り込む
  Future<List<dynamic>> _filterResultsForHierarchy(
      List<dynamic> baseResults) async {
    List<dynamic> current = baseResults;
    for (final filter in _hierarchyStack) {
      current = await GroupingHelper.filterResultsAsync(
        current,
        widget.category['type'],
        filter.property,
        filter.value,
        dateUnit: filter.dateUnit,
      );
    }
    return current;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: widget.streamGetter(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rawResults = snapshot.data ?? [];
        List<dynamic> results = rawResults;

        // 日付期間指定フィルタの適用（詳細ビューで日付指定の場合）
        if (_isDetailedView &&
            _selectedGroupProperty == 'date' &&
            _selectedDateUnit == 'custom' &&
            _customDateRange != null &&
            _hierarchyStack.isEmpty) {
          DateTime start = DateTime(_customDateRange!.start.year,
              _customDateRange!.start.month, _customDateRange!.start.day);
          DateTime end = DateTime(
              _customDateRange!.end.year,
              _customDateRange!.end.month,
              _customDateRange!.end.day,
              23,
              59,
              59);
          results = rawResults.where((r) {
            DateTime d = r.date as DateTime;
            return (d.isAtSameMomentAs(start) || d.isAfter(start)) &&
                (d.isAtSameMomentAs(end) || d.isBefore(end));
          }).toList();
        }

        // 検索絞り込みフィルタの適用
        bool hasActiveFilters =
            _activeFilters.isNotEmpty || _filterDateRange != null;
        if (hasActiveFilters) {
          results = results.where((r) {
            bool isMatch = true;

            _activeFilters.forEach((prop, query) {
              if (!isMatch) return;
              if (query.trim().isEmpty) return;

              final keywords = query.trim().split(RegExp(r'\s+'));

              if (prop == 'memo') {
                final memo = (r.memo as String?) ?? '';
                bool propMatch = keywords
                    .any((kw) => memo.toLowerCase().contains(kw.toLowerCase()));
                if (!propMatch) isMatch = false;
              } else {
                final val = GroupingHelper.getPropertyValue(
                    r, widget.category['type'], prop);
                bool propMatch = keywords
                    .any((kw) => val.toLowerCase().contains(kw.toLowerCase()));

                if (prop == 'member' &&
                    (widget.category['type'] == 'mahjong' ||
                        widget.category['type'] == 'pachinko' ||
                        widget.category['type'] == 'slot')) {
                  List<String> members = [];
                  if (r is MahjongResult) {
                    members = r.member;
                  } else if (r is PachinkoResult) {
                    members = r.member;
                  } else if (r is SlotResult) {
                    members = r.member;
                  }

                  if (members.isNotEmpty) {
                    propMatch = keywords.any((kw) => members.any(
                        (m) => m.toLowerCase().contains(kw.toLowerCase())));
                  } else {
                    propMatch = keywords.any((kw) => 'ソロ'.contains(kw));
                  }
                }

                if (!propMatch) isMatch = false;
              }
            });

            if (isMatch && _filterDateRange != null) {
              DateTime d = r.date as DateTime;
              DateTime start = DateTime(_filterDateRange!.start.year,
                  _filterDateRange!.start.month, _filterDateRange!.start.day);
              DateTime end = DateTime(
                  _filterDateRange!.end.year,
                  _filterDateRange!.end.month,
                  _filterDateRange!.end.day,
                  23,
                  59,
                  59);
              if (d.isBefore(start) || d.isAfter(end)) {
                isMatch = false;
              }
            }

            return isMatch;
          }).toList();
        }

        final currencyFormatter = NumberFormat("#,##0", "ja_JP");

        return FutureBuilder<List<dynamic>>(
          future: _isDetailedView && _hierarchyStack.isNotEmpty
              ? _filterResultsForHierarchy(results)
              : Future.value(results),
          builder: (context, currentSnapshot) {
            final currentResults = currentSnapshot.data ?? results;
            final int totalAmount = currentResults.fold<int>(
                0, (sum, item) => sum + (item.amount as int));

            // ヘッダータイトルの生成
            String headerTitle = '${widget.category['display_name']} 合計収支';
            if (_isDetailedView && _hierarchyStack.isNotEmpty) {
              headerTitle = '${_hierarchyStack.last.value} の合計収支';
            }

            return Column(
              children: [
                // ヘッダーエリア
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 46, 16, 8),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        headerTitle,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${totalAmount >= 0 ? '+' : ''}${currencyFormatter.format(totalAmount)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: totalAmount >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      if (_isDetailedView && _hierarchyStack.isNotEmpty)
                        Text(
                          '(${currentResults.length}件の記録)',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700),
                        ),
                      const SizedBox(height: 12),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('基本'),
                            icon: Icon(Icons.list),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('詳細'),
                            icon: Icon(Icons.analytics),
                          ),
                        ],
                        selected: {_isDetailedView},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _isDetailedView = newSelection.first;
                            _hierarchyStack.clear();
                            _showRawRecords = false;
                          });
                        },
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.center,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.search,
                            color: hasActiveFilters
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                          onPressed: () => _showFilterBottomSheet(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // 詳細モード時のパンくずリスト & ナビゲーション
                if (_isDetailedView && _hierarchyStack.isNotEmpty)
                  _buildBreadcrumbs(context),

                // 第1階層（トップ集計）のグループ選択バー
                if (_isDetailedView &&
                    _groupableProperties.isNotEmpty &&
                    _hierarchyStack.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const Text('グループ：'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedGroupProperty,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGroupProperty = newValue;
                                if (newValue != null) {
                                  _subGroupProperty =
                                      _getDefaultSubGroupProperty(newValue);
                                }
                              });
                            },
                            items: _groupableProperties
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child:
                                    Text(GroupingHelper.getPropertyLabel(
                                        value, widget.category['type'])),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.bar_chart),
                          tooltip: 'グラフ表示',
                          onPressed: () {
                            _showChartScreen(context, currentResults,
                                _selectedGroupProperty!);
                          },
                        ),
                      ],
                    ),
                  ),

                // 日付グループ時の期間切り替えバー（第1階層のみ）
                if (_isDetailedView &&
                    _selectedGroupProperty == 'date' &&
                    _hierarchyStack.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Column(
                      children: [
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'week', label: Text('週間')),
                            ButtonSegment(value: 'month', label: Text('月間')),
                            ButtonSegment(value: 'year', label: Text('年間')),
                            ButtonSegment(value: 'custom', label: Text('指定')),
                          ],
                          selected: {_selectedDateUnit},
                          onSelectionChanged:
                              (Set<String> newSelection) async {
                            final unit = newSelection.first;
                            if (unit == 'custom') {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                                initialDateRange: _customDateRange,
                              );
                              if (picked != null) {
                                setState(() {
                                  _customDateRange = picked;
                                  _selectedDateUnit = unit;
                                });
                              }
                            } else {
                              setState(() {
                                _selectedDateUnit = unit;
                              });
                            }
                          },
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        if (_selectedDateUnit == 'custom' &&
                            _customDateRange != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              '${DateHelper.formatDateWithWeekday(_customDateRange!.start)} 〜 ${DateHelper.formatDateWithWeekday(_customDateRange!.end)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),

                // 第2階層（サブグループ集計）のプロパティ選択バー
                if (_isDetailedView &&
                    _hierarchyStack.length == 1 &&
                    !_showRawRecords)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 6.0),
                    child: Row(
                      children: [
                        const Text('さらに集計：'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _subGroupProperty,
                            onChanged: (String? newValue) {
                              setState(() {
                                _subGroupProperty = newValue;
                              });
                            },
                            items: _groupableProperties
                                .where((p) =>
                                    p != _hierarchyStack.first.property &&
                                    p != 'compound')
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child:
                                    Text(GroupingHelper.getPropertyLabel(
                                        value, widget.category['type'])),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_subGroupProperty != null)
                          IconButton(
                            icon: const Icon(Icons.bar_chart),
                            tooltip: 'グラフ表示',
                            onPressed: () {
                              _showChartScreen(
                                  context, currentResults, _subGroupProperty!);
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.receipt_long),
                          tooltip: 'すべての記録を表示',
                          onPressed: () {
                            setState(() {
                              _showRawRecords = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                // 「すべての記録を表示中」時のグループ集計に戻るボタン
                if (_isDetailedView &&
                    _hierarchyStack.length == 1 &&
                    _showRawRecords)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_hierarchyStack.first.value} の全記録一覧',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.analytics, size: 18),
                          label: const Text('グループ集計へ'),
                          onPressed: () {
                            setState(() {
                              _showRawRecords = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 4),

                // メインコンテンツエリア
                Expanded(
                  child: currentResults.isEmpty
                      ? const Center(child: Text('データがありません'))
                      : !_isDetailedView
                          ? _buildBasicCardList(currentResults)
                          : _hierarchyStack.isEmpty
                              ? _buildDetailedList(
                                  currentResults,
                                  _selectedGroupProperty!,
                                  currencyFormatter,
                                  isTopLevel: true,
                                )
                              : _hierarchyStack.length == 1 && !_showRawRecords
                                  ? _buildDetailedList(
                                      currentResults,
                                      _subGroupProperty ??
                                          _getDefaultSubGroupProperty(
                                              _hierarchyStack.first.property),
                                      currencyFormatter,
                                      isTopLevel: false,
                                    )
                                  : _buildBasicCardList(currentResults),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// パンくずリストおよび戻るナビゲーションUI
  Widget _buildBreadcrumbs(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: '1つ前の階層に戻る',
            onPressed: () {
              setState(() {
                if (_showRawRecords && _hierarchyStack.length == 1) {
                  _showRawRecords = false;
                } else {
                  _hierarchyStack.removeLast();
                  _showRawRecords = false;
                }
              });
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _hierarchyStack.clear();
                        _showRawRecords = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 2.0),
                      child: Text(
                        '詳細トップ',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  for (int i = 0; i < _hierarchyStack.length; i++) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                      child: Icon(Icons.chevron_right,
                          size: 16, color: Colors.grey),
                    ),
                    InkWell(
                      onTap: i < _hierarchyStack.length - 1
                          ? () {
                              setState(() {
                                _hierarchyStack.removeRange(
                                    i + 1, _hierarchyStack.length);
                                _showRawRecords = false;
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.0),
                        decoration: i == _hierarchyStack.length - 1
                            ? BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4.0),
                              )
                            : null,
                        child: Text(
                          _hierarchyStack[i].value,
                          style: TextStyle(
                            color: i == _hierarchyStack.length - 1
                                ? Colors.black87
                                : Theme.of(context).primaryColor,
                            fontWeight: i == _hierarchyStack.length - 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 基本のカードリスト表示
  Widget _buildBasicCardList(List<dynamic> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final result = list[index];
        return ResultCard(
          result: result,
          onTap: () => widget.onEdit(result),
          onDelete: () => widget.onDelete(result),
        );
      },
    );
  }

  /// 集計リスト表示
  Widget _buildDetailedList(
    List<dynamic> results,
    String groupProperty,
    NumberFormat formatter, {
    required bool isTopLevel,
  }) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: GroupingHelper.aggregateResultsAsync(
        results,
        widget.category['type'],
        groupProperty,
        dateUnit: _selectedDateUnit,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
        }
        final aggregated = snapshot.data ?? [];
        if (aggregated.isEmpty) {
          return const Center(child: Text('データがありません'));
        }

        // スロット専用の複合（店舗 × 機種）表示
        if (groupProperty == 'compound' && isTopLevel) {
          final Map<String, List<Map<String, dynamic>>> groupedByPlace = {};
          for (var item in aggregated) {
            final parts = (item['name'] as String).split(' × ');
            final place = parts[0];
            final machine = parts.length > 1 ? parts[1] : '';

            final Map<String, dynamic> itemWithMachine =
                Map<String, dynamic>.from(item);
            itemWithMachine['machine'] = machine;

            if (!groupedByPlace.containsKey(place)) {
              groupedByPlace[place] = [];
            }
            groupedByPlace[place]!.add(itemWithMachine);
          }

          return ListView.builder(
            itemCount: groupedByPlace.length,
            itemBuilder: (context, index) {
              final place = groupedByPlace.keys.elementAt(index);
              final machines = groupedByPlace[place]!;
              final placeTotalAmount =
                  machines.fold<int>(0, (sum, m) => sum + (m['amount'] as int));

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context)
                          .primaryColor
                          .withValues(alpha: 0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.storefront,
                                  color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              Text(place,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(
                            '${placeTotalAmount >= 0 ? '+' : ''}${formatter.format(placeTotalAmount)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: placeTotalAmount >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: machines.length,
                      itemBuilder: (context, mIndex) {
                        final mItem = machines[mIndex];
                        final amount = mItem['amount'] as int;
                        final machineName = mItem['machine'] as String;

                        final int? totalGames = mItem['totalGames'];
                        final int? rbCount = mItem['rbCount'];
                        final int? bbCount = mItem['bbCount'];

                        String rbProb = '-';
                        String bbProb = '-';
                        String totalProb = '-';

                        if (totalGames != null && totalGames > 0) {
                          if (rbCount != null && rbCount > 0) {
                            rbProb =
                                '1/${(totalGames / rbCount).toStringAsFixed(1)}';
                          }
                          if (bbCount != null && bbCount > 0) {
                            bbProb =
                                '1/${(totalGames / bbCount).toStringAsFixed(1)}';
                          }
                          final totalBonus = (rbCount ?? 0) + (bbCount ?? 0);
                          if (totalBonus > 0) {
                            totalProb =
                                '1/${(totalGames / totalBonus).toStringAsFixed(1)}';
                          }
                        }

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _hierarchyStack.add(_HierarchyFilter(
                                property: 'compound',
                                value: mItem['name'],
                                propertyLabel: '複合',
                              ));
                              _showRawRecords = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              border: Border(
                                bottom: BorderSide(
                                  color: mIndex < machines.length - 1
                                      ? Colors.grey.shade200
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Text(machineName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16))),
                                    Text(
                                      '${amount >= 0 ? '+' : ''}${formatter.format(amount)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: amount >= 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                if (totalGames != null ||
                                    rbCount != null ||
                                    bbCount != null) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: [
                                      _buildStatBadge(context, 'G数',
                                          '${totalGames ?? "-"}',
                                          Colors.grey.shade700),
                                      _buildStatBadge(context, 'RB',
                                          '${rbCount ?? "-"}',
                                          Colors.blue.shade700),
                                      _buildStatBadge(context, 'BB',
                                          '${bbCount ?? "-"}',
                                          Colors.red.shade700),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: [
                                      _buildStatBadge(context, 'RB確率', rbProb,
                                          Colors.blue.shade700),
                                      _buildStatBadge(context, 'BB確率', bbProb,
                                          Colors.red.shade700),
                                      _buildStatBadge(context, 'ペカリ確率',
                                          totalProb, Colors.orange.shade700),
                                    ],
                                  ),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }

        // 通常の集計リスト表示
        return ListView.builder(
          itemCount: aggregated.length,
          itemBuilder: (context, index) {
            final item = aggregated[index];
            final amount = item['amount'] as int;

            return InkWell(
              onTap: () {
                setState(() {
                  _hierarchyStack.add(_HierarchyFilter(
                    property: groupProperty,
                    value: item['name'],
                    propertyLabel:
                        GroupingHelper.getPropertyLabel(
                            groupProperty, widget.category['type']),
                    dateUnit: _selectedDateUnit,
                  ));
                  if (isTopLevel) {
                    _subGroupProperty =
                        _getDefaultSubGroupProperty(groupProperty);
                    _showRawRecords = false;
                  } else {
                    // 第2階層からタップした時は個別記録一覧を表示
                    _showRawRecords = true;
                  }
                });
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(item['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: item['type'] != null
                      ? Text(
                          item['type'] as String,
                          style: TextStyle(
                              color: item['type'] == '三麻'
                                  ? Colors.orange.shade700
                                  : Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${amount >= 0 ? '+' : ''}${formatter.format(amount)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: amount >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right,
                          color: Colors.grey, size: 20),
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

  Widget _buildStatBadge(
      BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// グラフ画面を表示
  Future<void> _showChartScreen(
      BuildContext context, List<dynamic> results, String groupProp) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final aggregated = await GroupingHelper.aggregateResultsAsync(
        results,
        widget.category['type'],
        groupProp,
        dateUnit: _selectedDateUnit,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChartScreen(
              title:
                  '${widget.category['display_name']} - ${GroupingHelper.getPropertyLabel(groupProp, widget.category['type'])}',
              data: aggregated,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _FilterBottomSheet(
          category: widget.category,
          groupableProperties: _groupableProperties,
          initialFilters: _activeFilters,
          initialDateRange: _filterDateRange,
          onApply: (filters, dateRange) {
            setState(() {
              _activeFilters = filters;
              _filterDateRange = dateRange;
            });
          },
        );
      },
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> category;
  final List<String> groupableProperties;
  final Map<String, String> initialFilters;
  final DateTimeRange? initialDateRange;
  final void Function(Map<String, String>, DateTimeRange?) onApply;

  const _FilterBottomSheet({
    required this.category,
    required this.groupableProperties,
    required this.initialFilters,
    required this.initialDateRange,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late Map<String, TextEditingController> _controllers;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (final prop in widget.groupableProperties) {
      if (prop == 'date') continue;
      _controllers[prop] =
          TextEditingController(text: widget.initialFilters[prop] ?? '');
    }
    _controllers['memo'] =
        TextEditingController(text: widget.initialFilters['memo'] ?? '');
    _dateRange = widget.initialDateRange;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '絞り込み',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    for (var controller in _controllers.values) {
                      controller.clear();
                    }
                    setState(() {
                      _dateRange = null;
                    });
                  },
                  child: const Text('クリア'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._controllers.entries.map((entry) {
              final prop = entry.key;
              final controller = entry.value;
              final label =
                  prop == 'memo' ? 'メモ' : GroupingHelper.getPropertyLabel(
                      prop, widget.category['type']);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: 'スペース区切りで複数指定',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              );
            }),
            if (widget.groupableProperties.contains('date'))
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dateRange == null
                            ? '日付: 指定なし'
                            : '日付: ${DateHelper.formatDateWithWeekday(_dateRange!.start)} 〜 ${DateHelper.formatDateWithWeekday(_dateRange!.end)}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                          initialDateRange: _dateRange,
                        );
                        if (picked != null) {
                          setState(() {
                            _dateRange = picked;
                          });
                        }
                      },
                      child: const Text('期間を選択'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final filters = <String, String>{};
                  _controllers.forEach((key, value) {
                    if (value.text.trim().isNotEmpty) {
                      filters[key] = value.text.trim();
                    }
                  });
                  widget.onApply(filters, _dateRange);
                  Navigator.pop(context);
                },
                child: const Text('適用'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
