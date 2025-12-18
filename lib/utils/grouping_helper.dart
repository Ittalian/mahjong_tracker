import 'package:mahjong_tracker/models/mahjong_result.dart';
import 'package:mahjong_tracker/models/horse_racing_result.dart';
import 'package:mahjong_tracker/models/boat_racing_result.dart';
import 'package:mahjong_tracker/models/auto_racing_result.dart';
import 'package:mahjong_tracker/models/keirin_result.dart';
import 'package:mahjong_tracker/models/pachinko_result.dart';

class GroupingHelper {
  static List<Map<String, dynamic>> aggregateResults(
      List<dynamic> results, String categoryType, String property) {
    if (results.isEmpty) return [];

    final Map<String, int> groups = {};

    for (var result in results) {
      if (property == 'member' &&
          (categoryType == 'mahjong' || categoryType == 'pachinko')) {
        List<String> members = [];
        if (result is MahjongResult) {
          members = result.member;
        } else if (result is PachinkoResult) {
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
      } else {
        String key = _getPropertyValue(result, categoryType, property);
        groups[key] = (groups[key] ?? 0) + (result.amount as int);
      }
    }

    final List<Map<String, dynamic>> aggregated = groups.entries.map((e) {
      return {'name': e.key, 'amount': e.value};
    }).toList();

    // Sort by amount descending (optional, but usually nice)
    aggregated
        .sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));

    return aggregated;
  }

  static List<dynamic> filterResults(List<dynamic> results, String categoryType,
      String property, String value) {
    if (results.isEmpty) return [];

    return results.where((result) {
      if (property == 'member' &&
          (categoryType == 'mahjong' || categoryType == 'pachinko')) {
        List<String> members = [];
        if (result is MahjongResult) {
          members = result.member;
        } else if (result is PachinkoResult) {
          members = result.member;
        }

        if (value == 'ソロ') {
          return members.isEmpty;
        } else {
          return members.contains(value);
        }
      } else {
        return _getPropertyValue(result, categoryType, property) == value;
      }
    }).toList();
  }

  static String _getPropertyValue(
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
            default:
              return '';
          }
        }
        break;
      case 'horse_racing':
        if (result is HorseRacingResult && property == 'betType') {
          return result.betType;
        }
        break;
      case 'boat_racing':
        if (result is BoatRacingResult && property == 'betType') {
          return result.betType;
        }
        break;
      case 'auto_racing':
        if (result is AutoRacingResult && property == 'betType') {
          return result.betType;
        }
        break;
      case 'keirin':
        if (result is KeirinResult && property == 'betType') {
          return result.betType;
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
    }
    return 'その他';
  }

  static List<String> getGroupableProperties(String categoryType) {
    switch (categoryType) {
      case 'mahjong':
        return ['type', 'umaRate', 'priceRate', 'chipRate', 'member'];
      case 'horse_racing':
      case 'boat_racing':
      case 'auto_racing':
      case 'keirin':
        return ['betType'];
      case 'pachinko':
        return ['type', 'member', 'place', 'machine'];
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
        return '場所';
      case 'machine':
        return '機種';
      default:
        return property;
    }
  }
}
