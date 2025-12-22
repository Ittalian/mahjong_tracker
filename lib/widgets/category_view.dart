import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mahjong_tracker/utils/grouping_helper.dart';
import 'package:mahjong_tracker/screens/chart_screen.dart';
import '../widgets/result_card.dart';

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
  late final List<String> _groupableProperties;

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

        final results = snapshot.data ?? [];
        final int totalAmount =
            results.fold<int>(0, (sum, item) => sum + (item.amount as int));
        final currencyFormatter = NumberFormat("#,##0", "ja_JP");

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
    final aggregated = GroupingHelper.aggregateResults(
        results, widget.category['type'], _selectedGroupProperty!);

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
  }

  Widget _buildFilteredList(List<dynamic> results) {
    final filtered = GroupingHelper.filterResults(results,
        widget.category['type'], _selectedGroupProperty!, _selectedGroupValue!);

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
  }

  /// グラフ画面を表示
  void _showChartScreen(BuildContext context, List<dynamic> results) {
    final aggregated = GroupingHelper.aggregateResults(
        results, widget.category['type'], _selectedGroupProperty!);

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
}
