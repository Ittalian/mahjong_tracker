# スロット競技の追加

パチンコを参考に、スロット（スロ）カテゴリを新規追加する。  
店舗はパチンコと共有（`category: 'pachinko'` のプレースを使用）し、台の種類はスロット専用のコレクションを別途用意する。  
レビュー機能（台の種類・店舗）もパチンコと同様に実装する。

---

## 変更ファイル一覧

### モデル層

#### [NEW] `lib/models/slot_result.dart`
- フィールド: `id`, `date`, `amount`, `memo`, `createdAt`, `place`, `machine`, `expectedSetting`（予想設定: int 0=未設定, 1〜6）
- `fromFirestore` / `toMap` 実装

#### [MODIFY] `lib/models/machine_type.dart`
- 変更なし（スロット用は別コレクションで管理するため、モデルは共用）

#### [NEW] `lib/models/reviews/slot_machine_review.dart`
- パチンコ機種レビューと同一構造（`machineId`, `overall`, `production`, `payout`, `custom`, `music`, `memo`, `createdAt`, `updatedAt`）

#### [MODIFY] `lib/models/reviews/pachinko_place_review.dart`
- 店舗レビューをパチンコ・スロットで**共通コレクション**として使うため、`setting` フィールドを追加
- フィールド構成: `placeId`, `overall`, `rotation`（回転数: パチンコ用）, `setting`（設定 1〜6: スロット用）, `atmosphere`, `staff`, `memo`, `createdAt`, `updatedAt`
- パチンコレビュー画面では `rotation` を表示、スロットレビュー画面では `setting` を表示（DBは共通、表示を棲み分け）

---

### サービス層

#### [NEW] `lib/services/slot/slot_service.dart`
- コレクション: `slot_results`
- `addResult` / `getResults` / `updateResult` / `deleteResult`
- `updatePlaceNames` / `updateMachineNames`

#### [NEW] `lib/services/slot_machine_type_service.dart`
- コレクション: `slot_machine_types`（パチンコの `machine_types` とは別）
- `addMachineType` / `getMachineTypes` / `updateMachineType` / `deleteMachineType`

#### [MODIFY] `lib/services/reviews/review_service.dart`
- スロット台レビュー: `getSlotMachineReviews` / `saveSlotMachineReview` / `deleteSlotMachineReview`
  - コレクション: `slot_machine_reviews`
- 店舗レビューはパチンコと共通コレクション（`pachinko_place_reviews`）をそのまま流用
  - `PachinkoPlaceReview` に `setting` フィールドが追加されるため、既存メソッドで対応可能

---

### 画面層（編集）

#### [NEW] `lib/screens/edit/slot/slot_edit_screen.dart`
- `BaseEditScreen` を継承
- `categoryType` = `'slot'`
- `buildPlaceField()` をオーバーライドし、`PlaceService.getPlaces('pachinko')` を参照（パチンコ店舗を共有）
- 独自フィールド:
  - 台の種類（`CreatableAutocomplete<MachineType>` - `SlotMachineTypeService` 使用）
  - 予想設定（1〜6のDropdown、0=未設定）

---

### 画面層（レビュー）

#### [NEW] `lib/screens/review/review_slot_tab.dart`
- パチンコレビュータブとほぼ同構造
- 台モード: `SlotMachineReview`（`overall`, `production`, `payout`, `custom`, `music`）
  - `SlotMachineTypeService` で台リストを取得
- 店舗モード: 共通 `PachinkoPlaceReview` を使用
  - パチンコは `rotation` を表示、スロットは `setting` を表示（コレクション・モデルは共通）
  - 店舗リストは `PlaceService.getPlaces('pachinko')` で取得
- フィルタ・ソート機能あり

#### [MODIFY] `lib/screens/review/review_pachinko_tab.dart`
- `PachinkoPlaceReview` に `setting` フィールドが追加されるが、パチンコタブの表示は `rotation` のまま変更なし

---

### ルーター・ホーム画面

#### [MODIFY] `lib/screens/routers/edit_screen_router.dart`
- `case 'slot':` を追加し `SlotEditScreen` を返す

#### [MODIFY] `lib/screens/home_screen.dart`
- `_categories` リストにスロットを追加:
  ```dart
  {
    'id': 'slot',
    'label': 'スロ',
    'display_name': 'スロット',
    'icon': Icons.casino_outlined,
    'type': 'slot'
  }
  ```
- `_handlers` に `'slot'` キーで `SlotService` を登録
- レビューの `switch` に `case 'slot':` を追加し `ReviewSlotTab` を返す

#### [MODIFY] `lib/screens/summary_screen.dart`
- `slotStream` を追加
- `CombineLatestStream.list` にスロットを追加
- カテゴリリストにスロットを追加

---

## 設計上の注意点

> [!IMPORTANT]
> **店舗の共有**: `categoryType = 'slot'` としつつ、`buildPlaceField()` をオーバーライドして `PlaceService.getPlaces('pachinko')` を参照する。新規店舗追加時も `category: 'pachinko'` で保存しパチンコ・スロット双方で見える状態にする。

> [!IMPORTANT]
> **台の種類の分離**: スロットは `SlotMachineTypeService`（コレクション: `slot_machine_types`）を使用。パチンコの台リストとは完全に独立して管理。

> [!NOTE]
> **店舗レビューの共通化**: `pachinko_place_reviews` コレクションを共通利用し、`PachinkoPlaceReview` モデルに `setting`（1〜6）フィールドを追加。パチンコタブでは `rotation` を、スロットタブでは `setting` を表示することで棲み分け。

> [!NOTE]
> **予想設定**: 整数値（1〜6の設定値）として保存。Dropdownで入力。0の場合は「未設定」扱い。

## 検証方法

1. `flutter analyze` でエラーがないことを確認
2. アプリ起動後、ホームのボトムナビに「スロ」が表示されることを確認
3. スロット収支の追加・編集・削除が機能することを確認
4. レビュー画面（台の種類・店舗）が表示・保存できることを確認
5. 店舗データがパチンコ・スロット間で共有されていることを確認
6. パチンコの台リストにスロットの台が混在しないことを確認
7. 合計画面にスロットが表示されることを確認
