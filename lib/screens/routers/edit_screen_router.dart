import 'package:flutter/material.dart';
import 'package:mahjong_tracker/screens/edit/majong/mahjong_edit_screen.dart';
import 'package:mahjong_tracker/screens/edit/horse_racing/horse_racing_edit_screen.dart';
import 'package:mahjong_tracker/screens/edit/boat_racing/boat_racing_edit_screen.dart';
import 'package:mahjong_tracker/screens/edit/auto_racing/auto_racing_edit_screen.dart';
import 'package:mahjong_tracker/screens/edit/keirin/keirin_edit_screen.dart';
import 'package:mahjong_tracker/screens/edit/pachinko/pachinko_edit_screen.dart';

/// 競技タイプに基づいて適切な編集画面を返すルーター関数
Widget getEditScreenForCategory({
  required String categoryType,
  dynamic result,
}) {
  switch (categoryType) {
    case 'mahjong':
      return MahjongEditScreen(result: result);
    case 'horse_racing':
      return HorseRacingEditScreen(result: result);
    case 'boat_racing':
      return BoatRacingEditScreen(result: result);
    case 'auto_racing':
      return AutoRacingEditScreen(result: result);
    case 'keirin':
      return KeirinEditScreen(result: result);
    case 'pachinko':
      return PachinkoEditScreen(result: result);
    default:
      throw Exception('Unknown category type: $categoryType');
  }
}
