import 'package:rxdart/rxdart.dart';
import 'package:mahjong_tracker/services/pachinko/pachinko_service.dart';
import 'package:mahjong_tracker/services/slot/slot_service.dart';

class GambleMemberService {
  final _pachinkoService = PachinkoService();
  final _slotService = SlotService();

  /// パチンコとスロットの両方の過去の収支から重複なしのメンバー名一覧を返す
  Stream<List<String>> getUniqueMembers() {
    return Rx.combineLatest2<List<String>, List<String>, List<String>>(
      _pachinkoService.getUniqueMembers(),
      _slotService.getUniqueMembers(),
      (pachinkoMembers, slotMembers) {
        final names = <String>{};
        names.addAll(pachinkoMembers);
        names.addAll(slotMembers);
        final sorted = names.toList()..sort();
        return sorted;
      },
    );
  }
}
