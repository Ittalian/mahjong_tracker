# スロット競技追加 タスク

## モデル層
- [x] `lib/models/slot_result.dart` 新規作成
- [x] `lib/models/reviews/slot_machine_review.dart` 新規作成
- [x] `lib/models/reviews/pachinko_place_review.dart` `setting` フィールド追加

## サービス層
- [x] `lib/services/slot/slot_service.dart` 新規作成
- [x] `lib/services/slot_machine_type_service.dart` 新規作成
- [x] `lib/services/reviews/review_service.dart` スロット台レビューメソッド追加

## 画面層（編集）
- [x] `lib/screens/edit/slot/slot_edit_screen.dart` 新規作成

## 画面層（レビュー）
- [x] `lib/screens/review/review_slot_tab.dart` 新規作成

## ルーター・ホーム・合計
- [x] `lib/screens/routers/edit_screen_router.dart` slot ケース追加
- [x] `lib/screens/home_screen.dart` カテゴリ・ハンドラ・レビュー追加
- [x] `lib/screens/summary_screen.dart` スロット合計追加

## 検証
- [x] `flutter analyze` 実行 → error/warning 0件
