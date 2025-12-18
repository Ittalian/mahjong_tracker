# 実装計画 - ゲーム結果の詳細表示

ホーム画面に「詳細表示」機能を追加し、プロパティ（例：麻雀のタイプ、レースの賭け式など）ごとに結果をグループ化して、集計された収支を表示できるようにします。

## ユーザーレビューが必要な事項

> [!NOTE]
> `HomeScreen` のカテゴリページ構築ロジックをリファクタリングし、新しいステートフルウィジェット `CategoryView` を作成します。これにより、各タブの表示状態（基本/詳細）を独立して管理します。

## 提案される変更

### UIコンポーネント

#### [MODIFY] [category_view.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/widgets/category_view.dart)
- `CategoryView` ステートフルウィジェットを更新します。
- **状態追加**: `String? _selectedGroupValue` (ドリルダウン用)。
- **UI更新**:
    - **詳細リスト**: 項目タップ時に `_selectedGroupValue` をセット。
    - **詳細表示(ドリルダウン時)**:
        - 上部に「< 戻る」ボタンと、選択中のグループ名を表示。
        - 選択されたグループに対応する結果リストを表示（基本表示と同じ `ResultCard` を使用）。

### ロジック & ヘルパー

#### [MODIFY] [grouping_helper.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/utils/grouping_helper.dart)
- `filterResults(List<dynamic> results, String categoryType, String property, String value)` メソッドを追加。
    - **麻雀/パチンコのMember**: リストに `value` が含まれるかどうかでフィルタリング（`value` が 'ソロ' の場合はメンバーリストが空かどうか）。
    - **その他**: `_getPropertyValue` の結果が `value` と一致するかでフィルタリング。

## 検証計画

### 自動テスト
- `GroupingHelper.filterResults` のユニットテストを追加作成。

### 手動検証
1.  **ドリルダウン動作**:
    - 詳細表示で任意のグループ（メンバー「Aさん」など）をタップ -> そのメンバーが含まれる結果のみが表示されるか確認。
    - 戻るボタンで集計リストに戻れるか確認。
    - 他のプロパティ（機種など）でも同様に確認。
