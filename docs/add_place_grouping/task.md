# UI調整の実装タスク

- [x] 1. 詳細画面での場所ごとの絞り込み（グループ化）
  - [x] `lib/utils/grouping_helper.dart` の `getGroupableProperties` に全競技の `place` を追加
  - [x] 同ファイルの `_getPropertyValue` にて各競技の `place` 値を返すよう修正
- [x] 2. 詳細グラフの縦向き化
  - [x] `lib/screens/chart_screen.dart` の `SystemChrome.setPreferredOrientations` を削除（縦向きを許可）
- [x] 3. セレクトとキーボードの被り修正
  - [x] `lib/widgets/creatable_autocomplete.dart` の `maxHeight` を、キーボードの高さ等を考慮した動的な値に変更
