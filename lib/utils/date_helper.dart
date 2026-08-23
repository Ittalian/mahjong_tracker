import 'package:intl/intl.dart';

/// 日付および曜日のフォーマットを提供するヘルパークラス
class DateHelper {
  /// 曜日（短縮形: 月〜日）
  static const List<String> weekdaysShort = ['月', '火', '水', '木', '金', '土', '日'];

  /// 曜日（フル表記: 月曜日〜日曜日）
  static const List<String> weekdaysFull = [
    '月曜日',
    '火曜日',
    '水曜日',
    '木曜日',
    '金曜日',
    '土曜日',
    '日曜日',
  ];

  /// 指定した日付の曜日（短縮形: 例「月」）を取得
  static String getWeekdayShort(DateTime date) {
    if (date.weekday >= 1 && date.weekday <= 7) {
      return weekdaysShort[date.weekday - 1];
    }
    return '';
  }

  /// 指定した日付の曜日（フル表記: 例「月曜日」）を取得
  static String getWeekdayFull(DateTime date) {
    if (date.weekday >= 1 && date.weekday <= 7) {
      return weekdaysFull[date.weekday - 1];
    }
    return '';
  }

  /// 指定した日付を「yyyy/MM/dd (月)」形式にフォーマット
  static String formatDateWithWeekday(DateTime date) {
    final ymd = DateFormat('yyyy/MM/dd').format(date);
    final weekday = getWeekdayShort(date);
    return '$ymd ($weekday)';
  }

  /// 曜日の順序（ソート用インデックス）を取得
  static int getWeekdayIndex(String weekdayName) {
    int index = weekdaysFull.indexOf(weekdayName);
    if (index != -1) return index;
    index = weekdaysShort.indexOf(weekdayName);
    if (index != -1) return index;
    return 99;
  }
}
