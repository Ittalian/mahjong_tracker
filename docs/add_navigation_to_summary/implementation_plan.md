# サマリー画面から各競技ページへの遷移機能実装

## 概要
現在、`summary_screen.dart`は各競技の収支合計を表示していますが、タップしても何も起こりません。この実装では、各競技の要素をタップすると、その競技の詳細ページに遷移できるようにします。

## 提案する変更内容

### HomeScreen ([home_screen.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/screens/home_screen.dart))

#### 変更内容
- `SummaryScreen`に`onNavigateToCategory`コールバックを渡すように修正
- このコールバックは、タップされた競技のインデックスに基づいてPageViewのページを変更する

**実装の詳細:**
```dart
const SummaryScreen(
  onNavigateToCategory: (categoryIndex) {
    _pageController.jumpToPage(categoryIndex);
  },
)
```

### SummaryScreen ([summary_screen.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/screens/summary_screen.dart))

#### 変更内容
1. `onNavigateToCategory`コールバックパラメータを追加
2. 各`ListTile`に`onTap`ハンドラーを追加して、タップされた競技のインデックスをコールバックに渡す

**実装の詳細:**
```dart
class SummaryScreen extends StatelessWidget {
  final Function(int)? onNavigateToCategory;

  const SummaryScreen({
    super.key,
    this.onNavigateToCategory,
  });

  // ... buildメソッド内のListTileに追加
  ListTile(
    onTap: () => onNavigateToCategory?.call(index),
    // ... 既存のプロパティ
  )
}
```

## 検証計画

### 自動テスト
- Flutterアプリケーションが正常にビルドされることを確認

### 手動検証
1. アプリを起動して「合計」タブに移動
2. 各競技（麻雀、競馬、ボートレース、オートレース、競輪、パチンコ）の要素をタップ
3. それぞれの競技の詳細ページに正しく遷移することを確認
4. 遷移先のページが正しい競技のデータを表示していることを確認
