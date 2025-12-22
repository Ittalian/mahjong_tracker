import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// グラフ表示画面
/// 集計データを棒グラフで表示する
class ChartScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;

  const ChartScreen({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0", "ja_JP");

    return Scaffold(
      appBar: AppBar(
        title: Text('$title - グラフ'),
      ),
      body: data.isEmpty
          ? const Center(child: Text('データがありません'))
          : Column(
              children: [
                // 説明部分
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  width: double.infinity,
                  child: const Column(
                    children: [
                      Text(
                        '収支グラフ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.square, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('プラス'),
                          SizedBox(width: 16),
                          Icon(Icons.square, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text('マイナス'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // グラフ部分
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width:
                          data.length * 80.0 < MediaQuery.of(context).size.width
                              ? MediaQuery.of(context).size.width
                              : data.length * 80.0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _calculateMaxY(),
                          minY: _calculateMinY(),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                final item = data[groupIndex];
                                final amount = item['amount'] as int;
                                return BarTooltipItem(
                                  '${item['name']}\n',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '${amount >= 0 ? '+' : ''}${currencyFormatter.format(amount)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < data.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: RotatedBox(
                                        quarterTurns: 1,
                                        child: Text(
                                          data[value.toInt()]['name'],
                                          style: const TextStyle(fontSize: 12),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 80,
                                getTitlesWidget: (value, meta) {
                                  // 最大値と最小値のラベルは非表示
                                  final maxY = _calculateMaxY();
                                  final minY = _calculateMinY();
                                  if (value == maxY || value == minY) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    currencyFormatter.format(value.toInt()),
                                    style: const TextStyle(fontSize: 11),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: _calculateInterval(),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                              left: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          barGroups: _createBarGroups(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  /// 棒グラフの最大値を計算
  double _calculateMaxY() {
    if (data.isEmpty) return 100;
    final maxAmount =
        data.map((e) => e['amount'] as int).reduce((a, b) => a > b ? a : b);
    // 最大値より少し大きい値を返す
    return maxAmount > 0 ? maxAmount * 1.2 : 0;
  }

  /// 棒グラフの最小値を計算
  double _calculateMinY() {
    if (data.isEmpty) return -100;
    final minAmount =
        data.map((e) => e['amount'] as int).reduce((a, b) => a < b ? a : b);
    // 最小値より少し小さい値を返す
    return minAmount < 0 ? minAmount * 1.2 : 0;
  }

  /// グリッド線の間隔を計算
  double _calculateInterval() {
    final maxY = _calculateMaxY();
    final minY = _calculateMinY();
    final range = maxY - minY;

    if (range == 0) return 1000;

    // 適切な間隔を決定（約5本の横線を表示）
    final rawInterval = range / 5;

    // 桁数に応じて丸める
    if (rawInterval >= 10000) {
      return (rawInterval / 10000).ceil() * 10000.0;
    } else if (rawInterval >= 1000) {
      return (rawInterval / 1000).ceil() * 1000.0;
    } else if (rawInterval >= 100) {
      return (rawInterval / 100).ceil() * 100.0;
    } else {
      return rawInterval.ceilToDouble();
    }
  }

  /// 棒グラフのデータを作成
  List<BarChartGroupData> _createBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final amount = (item['amount'] as int).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: amount >= 0 ? Colors.green : Colors.red,
            width: 40,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();
  }
}
