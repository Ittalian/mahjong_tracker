import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahjong_tracker/utils/grouping_helper.dart';
import 'package:mahjong_tracker/screens/chart_screen.dart';
import '../widgets/result_card.dart';
import 'package:mahjong_tracker/models/mahjong_result.dart';
import 'package:mahjong_tracker/models/pachinko_result.dart';
import 'package:mahjong_tracker/models/slot_result.dart';

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
  String? _selectedGroupValue;
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
    }
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

        if (_isDetailedView &&
            _selectedGroupProperty == 'date' &&
            _selectedDateUnit == 'custom' &&
            _customDateRange != null) {
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

        final int totalAmount =
            results.fold<int>(0, (sum, item) => sum + (item.amount as int));
        final currencyFormatter = NumberFormat("#,##0", "ja_JP");

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 46, 16, 0),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    '${widget.category['display_name']} 合計収支',
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
                  const SizedBox(height: 16),
                  if (_groupableProperties.isNotEmpty)
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
                          _selectedGroupValue = null;
                        });
                      },
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  const SizedBox(height: 8),
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
                  if (_isDetailedView && _selectedGroupValue != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedGroupValue = null;
                            });
                          },
                        ),
                        Text(
                          '$_selectedGroupValue の詳細',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (_isDetailedView &&
                _groupableProperties.isNotEmpty &&
                _selectedGroupValue == null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          });
                        },
                        items: _groupableProperties
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(GroupingHelper.getPropertyLabel(value)),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.bar_chart),
                      tooltip: 'グラフ表示',
                      onPressed: () {
                        _showChartScreen(context, results);
                      },
                    ),
                  ],
                ),
              ),
            if (_isDetailedView &&
                _selectedGroupProperty == 'date' &&
                _selectedGroupValue == null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      onSelectionChanged: (Set<String> newSelection) async {
                        final unit = newSelection.first;
                        if (unit == 'custom') {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
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
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${DateFormat('yyyy/MM/dd').format(_customDateRange!.start)} 〜 ${DateFormat('yyyy/MM/dd').format(_customDateRange!.end)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('データがありません'))
                  : _isDetailedView && _selectedGroupProperty != null
                      ? (_selectedGroupValue != null
                          ? _buildFilteredList(results)
                          : _buildDetailedList(results, currencyFormatter))
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final result = results[index];
                            return ResultCard(
                              result: result,
                              onTap: () => widget.onEdit(result),
                              onDelete: () => widget.onDelete(result),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailedList(List<dynamic> results, NumberFormat formatter) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: GroupingHelper.aggregateResultsAsync(
          results, widget.category['type'], _selectedGroupProperty!,
          dateUnit: _selectedDateUnit),
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

        return ListView.builder(
          itemCount: aggregated.length,
          itemBuilder: (context, index) {
            final item = aggregated[index];
            final amount = item['amount'] as int;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedGroupValue = item['name'];
                });
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(item['name']),
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

  Widget _buildFilteredList(List<dynamic> results) {
    return FutureBuilder<List<dynamic>>(
      future: GroupingHelper.filterResultsAsync(results,
          widget.category['type'], _selectedGroupProperty!, _selectedGroupValue!,
          dateUnit: _selectedDateUnit),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
        }
        final filtered = snapshot.data ?? [];

        if (filtered.isEmpty) {
          return const Center(child: Text('データがありません'));
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final result = filtered[index];
            return ResultCard(
              result: result,
              onTap: () => widget.onEdit(result),
              onDelete: () => widget.onDelete(result),
            );
          },
        );
      },
    );
  }

  /// グラフ画面を表示
  Future<void> _showChartScreen(BuildContext context, List<dynamic> results) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final aggregated = await GroupingHelper.aggregateResultsAsync(
          results, widget.category['type'], _selectedGroupProperty!,
          dateUnit: _selectedDateUnit);
      
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChartScreen(
              title:
                  '${widget.category['display_name']} - ${GroupingHelper.getPropertyLabel(_selectedGroupProperty!)}',
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
                  prop == 'memo' ? 'メモ' : GroupingHelper.getPropertyLabel(prop);
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
                            : '日付: ${DateFormat('yyyy/MM/dd').format(_dateRange!.start)} 〜 ${DateFormat('yyyy/MM/dd').format(_dateRange!.end)}',
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
