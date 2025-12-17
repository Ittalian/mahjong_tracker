# パチンコ競技追加の実装計画

ユーザーのリクエストに基づき、新しい競技「パチンコ」を追加します。
既存の「麻雀」や「公営競技（競馬・競艇など）」の実装を参考に、一貫性のある形式で追加します。

## ユーザーレビューが必要な事項
- **入力項目**: パチンコは「賭け方（単勝など）」が不要なため、麻雀と同様に「日付/金額/メモ」のみの入力項目とします。
- **アイコン**: ひとまず適当なアイコン（`Icons.videogame_asset` 等）を設定します。

## 変更内容

### Models
#### [NEW] [pachinko_result.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/models/pachinko_result.dart)
- `MahjongResult` と同様の構成（`betType` なし）で作成します。

### Services
#### [MODIFY] [firestore_service.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/services/firestore_service.dart)
- `pachinko_results` コレクションへのCRUD操作を追加します。
  - `addPachinkoResult`
  - `getPachinkoResults`
  - `updatePachinkoResult`
  - `deletePachinkoResult`

### Screens
#### [MODIFY] [home_screen.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/screens/home_screen.dart)
- `_categories` リストに「パチンコ」を追加します。
- 削除時の分岐処理に `pachinko` を追加します。

#### [MODIFY] [edit_screen.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/screens/edit_screen.dart)
- `_saveResult` メソッド内の switch 文に `pachinko` ケースを追加し、保存/更新処理を実装します。
- `isRacing` 変数のロジックを修正し、パチンコの場合は「賭け方」入力欄を表示しないようにします（麻雀と同様の扱い）。

#### [MODIFY] [summary_screen.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/screens/summary_screen.dart)
- パチンコの収支合計を計算し、グラフやリストに表示するように追加します。

## 検証計画

### 動作確認
1.  **アプリ起動**: エラーなく起動することを確認。
2.  **カテゴリ表示**: ホーム画面下部のナビゲーションに「パチンコ」が表示されるか確認。
3.  **追加**: パチンコ画面で「＋」ボタンを押し、収支を追加できるか。入力欄が正しいか（賭け方がないか）。
4.  **表示**: 追加した収支がリストに表示されるか。
5.  **編集**: タップして編集画面に行き、更新できるか。
6.  **削除**: スワイプまたは長押し等で削除できるか。
7.  **集計**: 「サマリー」画面でパチンコの収支が正しく合計されているか。
