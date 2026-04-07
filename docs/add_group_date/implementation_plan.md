# 詳細グループオプションへの「日付」追加とUI改善

「詳細のグループオプション」に「日付」を追加し、期間選択（週間・月間・年間・カスタム）のUIを実装、およびグラフの横向き表示を行う実装計画です。

## User Review Required

> [!IMPORTANT]
> 「日付」でグループ化する際、選択された期間によって以下のようデータをまとめる（グループ化する）単位を変えるのが見やすくておすすめですが、この仕様で進めてよろしいでしょうか？
> 
> - **週間を選択**: 日単位で集計（例: `4/1`, `4/2` ... 過去7日分または今週）
> - **月間を選択**: 日単位で集計（例: `4/1`, `4/2` ... 過去30日分または今月）
> - **年間を選択（デフォルト）**: 月単位で集計（例: `2023/4`, `2023/5` ... 過去12ヶ月分または今年）
> - **カスタムを選択**: 選択期間が90日を超える場合は「月単位」、それ以下の場合は「日単位」で集計
> 
> ※もし常に「日単位 (`yyyy/MM/dd`)」で集計したい等のご希望があれば教えてください。

> [!IMPORTANT]
> グラフ画面（`ChartScreen`）の「横画面表示」について、
> **「グラフ画面を開いた際に、自動的に端末の向き（画面）を横向きに回転・固定させる」** という解釈で合っていますでしょうか？
> （グラフ自体は現在も指で横にスクロール可能ですが、画面全体を強制的に横向きにする対応を想定しています）

## Proposed Changes

### Configuration
#### [MODIFY] pubspec.yaml
- （必要であれば）横画面固定を行うための設定 `SystemChrome.setPreferredOrientations` のため、`flutter/services.dart` は標準で使えますが、カレンダー選択用に使いやすいパッケージ（例：標準の `showDateRangePicker` を使用するため特別なパッケージ追加は不要）を用います。

---

### UI Components

#### [MODIFY] lib/widgets/category_view.dart
- **ラジオボタン（期間選択）の追加**:
  - `_selectedGroupProperty` が `date` の場合に表示される、おしゃれな SegmentedButton または カスタムラジオボタン（週間・月間・年間・カスタム）を配置。
  - デフォルト状態は「年間」に設定。
- **カスタムカレンダーの表示**:
  - `showDateRangePicker` を利用し、「カスタム」が選択された時にカレンダーダイアログを表示して開始日・終了日を取得。
- **データフィルタリングの適用**:
  - 選択された期間に従って `results` を今日の日付から計算して事前に絞り込み（フィルター）。
  - 週間＝今日から過去7日
  - 月間＝今日から過去30日（または今月1日〜末日）
  - 年間＝今日から過去365日（または今年1月〜12月）

#### [MODIFY] lib/utils/grouping_helper.dart
- **グループオプションにDateを追加**:
  - `getGroupableProperties` に `date` を追加。
  - `getPropertyLabel` で `date` を「日付」として返す。
- **日付の集計ロジック**:
  - 期間（日単位、月単位など）に応じたグルーピングを `aggregateResults` に追加。結果データの `date` フィールドを用いて日付フォーマット文字列を生成してグループキーにする。

---

### Screens

#### [MODIFY] lib/screens/chart_screen.dart
- **横画面の強制設定**:
  - `initState` 内で `SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])` を呼び出し。
  - `dispose` 内で `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])` に戻す処理を追加し、元の画面に戻った時に縦向きに復旧させる。

## Open Questions

- 期間の計算について、「週間」は **「過去7日間（今日含む）」** か、カレンダー上の **「今週の日曜〜土曜」** のどちらがイメージに近いですか？（デフォルトでは「過去7日間、過去30日間、過去365日間」で計算する想定です）

## Verification Plan

### Automated Tests
- 今回は主にUIと表示ロジックの変更であるため、Flutterのビルドチェックを通す。

### Manual Verification
- 詳細タブで「日付」を選択し、ラジオボタンが表示されることの確認。
- デフォルトが年間になっているかの確認。
- 各期間（週間・月間・年間）で、今日を基準に正しく絞り込み＆グラフ化されることの確認。
- カスタム選択時にカレンダーが開き、任意の日付範囲で絞り込みができることの確認。
- グラフ表示ボタンを押した際に、画面が横向きで表示され、戻ると縦向きに戻ることの確認。
