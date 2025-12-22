# グラフ表示画面の実装計画

## 概要
競技ごとの詳細表示で集計された数値データ（`GroupingHelper.aggregateResults`の結果）を棒グラフで視覚化する画面を作成します。データ数が多い場合は横スクロールで対応します。

## ユーザー確認事項

> [!IMPORTANT]
> この実装では、Flutterで人気のグラフライブラリ`fl_chart`を使用します。このライブラリは高機能で美しいグラフを簡単に作成できます。

## 提案する変更

### 依存関係の追加

#### [MODIFY] [pubspec.yaml](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/pubspec.yaml)
- `fl_chart: ^0.69.0` をdependenciesに追加

---

### グラフ表示画面の作成

#### [NEW] [chart_screen.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/screens/chart_screen.dart)
新しいグラフ表示画面を作成します：
- 集計データを受け取り棒グラフで表示
- 横スクロール対応（データ数に応じて動的に幅を調整）
- グラフの色を収支の正負で変更（プラス：緑、マイナス：赤）
- タップでデータの詳細を表示

---

### 既存画面の修正

#### [MODIFY] [category_view.dart](file:///c:/Users/bothm/dev_Dart/Flutter_Project/mahjong_tracker/lib/widgets/category_view.dart)
詳細表示モード時にグラフ表示ボタンを追加：
- リスト表示とグラフ表示を切り替えるボタンを詳細表示エリアに追加
- グラフボタンをタップすると`ChartScreen`に遷移

## 検証計画

### 手動検証
1. アプリを起動し、任意の競技を選択
2. 「詳細」モードに切り替え
3. グラフ表示ボタンをタップ
4. 棒グラフが正しく表示されることを確認
5. データ数が多い場合、横スクロールが機能することを確認
6. 収支がプラスのバーが緑、マイナスのバーが赤で表示されることを確認
