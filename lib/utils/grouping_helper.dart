import 'package:mahjong_tracker/models/mahjong_result.dart';
import 'package:mahjong_tracker/models/horse_racing_result.dart';
import 'package:mahjong_tracker/models/boat_racing_result.dart';
import 'package:mahjong_tracker/models/auto_racing_result.dart';
import 'package:mahjong_tracker/models/keirin_result.dart';
import 'package:mahjong_tracker/models/pachinko_result.dart';
import 'package:mahjong_tracker/models/slot_result.dart';
import 'package:intl/intl.dart';

class GroupingHelper {
  static List<Map<String, dynamic>> aggregateResults(
      List<dynamic> results, String categoryType, String property,
      {String dateUnit = 'year'}) {
    if (results.isEmpty) return [];

    final Map<String, int> groups = {};

    for (var result in results) {
      if (property == 'member' &&
          (categoryType == 'mahjong' ||
              categoryType == 'pachinko' ||
              categoryType == 'slot')) {
        List<String> members = [];
        if (result is MahjongResult) {
          members = result.member;
        } else if (result is PachinkoResult) {
          members = result.member;
        } else if (result is SlotResult) {
          members = result.member;
        }

        if (members.isEmpty) {
          const key = 'ソロ';
          groups[key] = (groups[key] ?? 0) + (result.amount as int);
        } else {
          for (var member in members) {
            groups[member] = (groups[member] ?? 0) + (result.amount as int);
          }
        }
      } else if (property == 'date') {
        String key = _getDateKey(result.date as DateTime, dateUnit);
        groups[key] = (groups[key] ?? 0) + (result.amount as int);
      } else {
        String key = getPropertyValue(result, categoryType, property);
        groups[key] = (groups[key] ?? 0) + (result.amount as int);
      }
    }

    final List<Map<String, dynamic>> aggregated = groups.entries.map((e) {
      return {'name': e.key, 'amount': e.value};
    }).toList();

    // Sort by amount descending (optional, but usually nice)
    if (property == 'date') {
      aggregated.sort(
          (a, b) => (b['name'] as String).compareTo(a['name'] as String));
    } else {
      aggregated
          .sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));
    }

    return aggregated;
  }

  static List<dynamic> filterResults(List<dynamic> results, String categoryType,
      String property, String value,
      {String dateUnit = 'year'}) {
    if (results.isEmpty) return [];

    return results.where((result) {
      if (property == 'member' &&
          (categoryType == 'mahjong' ||
              categoryType == 'pachinko' ||
              categoryType == 'slot')) {
        List<String> members = [];
        if (result is MahjongResult) {
          members = result.member;
        } else if (result is PachinkoResult) {
          members = result.member;
        } else if (result is SlotResult) {
          members = result.member;
        }

        if (value == 'ソロ') {
          return members.isEmpty;
        } else {
          return members.contains(value);
        }
      } else if (property == 'date') {
        return _getDateKey(result.date as DateTime, dateUnit) == value;
      } else {
        return getPropertyValue(result, categoryType, property) == value;
      }
    }).toList();
  }

  static String _getDateKey(DateTime date, String dateUnit) {
    if (dateUnit == 'year') {
      return DateFormat('yyyy').format(date);
    } else if (dateUnit == 'month') {
      return DateFormat('yyyy/MM').format(date);
    } else if (dateUnit == 'week') {
      // Start of week (Monday)
      DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      return DateFormat('yyyy/MM/dd~').format(startOfWeek);
    } else {
      return DateFormat('yyyy/MM/dd').format(date);
    }
  }

  static String getPropertyValue(
      dynamic result, String categoryType, String property) {
    switch (categoryType) {
      case 'mahjong':
        if (result is MahjongResult) {
          switch (property) {
            case 'type':
              return result.type;
            case 'umaRate':
              return result.umaRate;
            case 'priceRate':
              return result.priceRate;
            case 'chipRate':
              return result.chipRate.toString();
            case 'place':
              return result.place.isEmpty ? '未設定' : result.place;
            default:
              return '';
          }
        }
        break;
      case 'horse_racing':
        if (result is HorseRacingResult) {
          if (property == 'betType') return result.betType;
          if (property == 'place') {
            return result.place.isEmpty ? '未設定' : result.place;
          }
        }
        break;
      case 'boat_racing':
        if (result is BoatRacingResult) {
          if (property == 'betType') return result.betType;
          if (property == 'place') {
            return result.place.isEmpty ? '未設定' : result.place;
          }
        }
        break;
      case 'auto_racing':
        if (result is AutoRacingResult) {
          if (property == 'betType') return result.betType;
          if (property == 'place') {
            return result.place.isEmpty ? '未設定' : result.place;
          }
        }
        break;
      case 'keirin':
        if (result is KeirinResult) {
          if (property == 'betType') return result.betType;
          if (property == 'place') {
            return result.place.isEmpty ? '未設定' : result.place;
          }
        }
        break;
      case 'pachinko':
        if (result is PachinkoResult) {
          switch (property) {
            case 'type':
              return result.type;
            case 'place':
              return result.place.isEmpty ? '未設定' : result.place;
            case 'machine':
              return result.machine.isEmpty ? '未設定' : result.machine;
            default:
              return '';
          }
        }
        break;
      case 'slot':
        if (result is SlotResult) {
          switch (property) {
            case 'place':
              return result.place.isEmpty ? '未設定' : result.place;
            case 'machine':
              return result.machine.isEmpty ? '未設定' : result.machine;
            case 'expectedSetting':
              return result.expectedSetting == 0
                  ? '未設定'
                  : '設定${result.expectedSetting}';
            default:
              return '';
          }
        }
        break;
    }
    return 'その他';
  }

  static List<String> getGroupableProperties(String categoryType) {
    switch (categoryType) {
      case 'mahjong':
        return ['type', 'umaRate', 'priceRate', 'chipRate', 'member', 'place', 'date'];
      case 'horse_racing':
      case 'boat_racing':
      case 'auto_racing':
      case 'keirin':
        return ['betType', 'place', 'date'];
      case 'pachinko':
        return ['type', 'member', 'place', 'machine', 'date'];
      case 'slot':
        return ['member', 'place', 'machine', 'expectedSetting', 'date'];
      default:
        return [];
    }
  }

  static String getPropertyLabel(String property) {
    switch (property) {
      case 'type':
        return 'タイプ';
      case 'umaRate':
        return 'ウマ';
      case 'priceRate':
        return 'レート';
      case 'chipRate':
        return 'チップ';
      case 'member':
        return 'メンバー';
      case 'betType':
        return '賭け方';
      case 'place':
        return '店舗';
      case 'machine':
        return '台の種類';
      case 'expectedSetting':
        return '予想設定';
      case 'date':
        return '日付';
      default:
        return property;
    }
  }
}
