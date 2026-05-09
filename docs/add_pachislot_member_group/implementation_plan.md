# パチンコ・スロットの共有グループ機能追加

パチンコおよびスロットの収支登録において、「乗り打ち」等で一緒に打つメンバーをグループ単位で管理・追加できるようにします。
また、グループはパチンコとスロットで共有して利用できるように設計します。

## Proposed Changes

### モデルとサービス
- **`lib/models/pachinko_group.dart` [NEW]**
  - `id`, `name`, `members`, `createdAt` を持つ `PachinkoGroup` モデルを作成します。麻雀のように「三麻/四麻」の区分はないため、`type` プロパティは不要です。
- **`lib/services/pachinko/pachinko_group_service.dart` [NEW]**
  - Firestore の `pachinko_groups` コレクションに対するCRUD処理と、Dart側でのソート処理を実装します。
- **`lib/services/pachinko/pachinko_service.dart` [MODIFY]**
  - 過去のパチンコ収支から重複のないメンバー名一覧を取得する `getUniqueMembers()` を追加します。
- **`lib/services/slot/slot_service.dart` [MODIFY]**
  - 過去のスロット収支から重複のないメンバー名一覧を取得する `getUniqueMembers()` を追加します。
- **`lib/services/gamble_member_service.dart` [NEW]** (あるいは各画面で結合)
  - パチンコとスロットの `getUniqueMembers()` のストリームを `rxdart` または手動で結合し、両方の履歴から重複のないメンバーを抽出する統合メソッド（または画面側の処理）を追加します。

### 管理画面
- **`lib/screens/edit/pachinko/pachinko_group_edit_screen.dart` [NEW]**
  - パチンコ・スロット共有のグループ管理画面（一覧・追加・編集）を作成します。
  - 麻雀の `MahjongGroupEditScreen` に準拠したUI（リスト表示、ドラッグでの並び替え、パチンコ台UI風の番号付きセル）を実装します。

### 収支編集画面
- **`lib/screens/edit/pachinko/pachinko_edit_screen.dart` [MODIFY]**
  - 「乗り打ち」選択時に、麻雀と同様の「個人 / グループ」切り替えトグルと選択UIを追加します。
  - 保存されたグループメンバーとの自動判定ロジックを実装します。
- **`lib/screens/edit/slot/slot_edit_screen.dart` [MODIFY]**
  - メンバー入力部分に、麻雀と同様の「個人 / グループ」切り替えトグルと選択UIを追加します。
  - 自動判定ロジックを実装します。

### ホーム画面
- **`lib/screens/home_screen.dart` [MODIFY]**
  - タブが「パチ」または「スロ」の場合に、右下にグループ管理画面（`PachinkoGroupListScreen`）へ遷移するFAB（Floating Action Button）を追加します。

## Verification Plan

### Manual Verification
- ホーム画面で「パチ」「スロ」タブ選択時にグループ管理ボタンが表示されること。
- グループ管理画面で新規グループの作成、編集、削除、メンバーのドラッグ並び替えができること。
- グループ作成時の候補メンバーに、過去のパチンコ・スロット両方の収支に入力したメンバーが表示されること。
- パチンコの収支登録で「乗り打ち」選択時にグループからメンバーを追加できること。
- スロットの収支登録でグループからメンバーを追加できること。
- 既存の収支を編集した際に、グループのメンバーと一致していれば「グループモード」としてグループ名が表示されること。
