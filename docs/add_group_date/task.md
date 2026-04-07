# 「日付」グループオプション追加タスク

# 「日付」グループオプション追加タスク

- [x] `lib/utils/grouping_helper.dart` の修正
  - [x] `getGroupableProperties` に `date` を追加。
  - [x] `getPropertyLabel` で `date` を「日付」にする。
  - [x] `aggregateResults` に `dateUnit` パラメータを追加し、「週間」「月間」「年間」「カスタム（日）」で日付フィールドを判定・集計する処理を実装。
    - 年間: `yyyy`年
    - 月間: `yyyy/MM`
    - 週間: `yyyy/MM/dd` (週の初めの日曜日に丸めるなど) または `"〇月第〇週"` の形式
    - カスタム: `yyyy/MM/dd` など
- [x] `lib/widgets/category_view.dart` の修正
  - [x] 状態として `_selectedDateUnit` ("year", "month", "week", "custom") を追加（デフォルトは "year"）。
  - [x] 状態として `_customStartDate`, `_customEndDate` を追加。
  - [x] `_selectedGroupProperty` が `date` の時、SegmentedButton をドロップダウンの下に表示（週間, 月間, 年間, カスタム）。
  - [x] 「カスタム」選択時、`showDateRangePicker` を起動して期間を設定できるようにする。
  - [x] リストやグラフを描画する前段で、「カスタム」時は `results` を指定された期間でフィルターする処理を入れる。
  - [x] `aggregateResults` と `filterResults` を呼び出す部分を `_selectedDateUnit` 等に対応させる。
- [x] `lib/screens/chart_screen.dart` の修正
  - [x] `initState` で `SystemChrome.setPreferredOrientations` を横向きに設定。
  - [x] `dispose` で縦向きに戻す設定。
  - [x] X軸のラベル幅など、横画面に合わせて多少調整。
