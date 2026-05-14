# スロット分析機能の強化

スロットカテゴリにG数・RB・BB情報を追加し、「この店のこの機種は当たりやすい！」という分析ができるようにする。

## 概要

1. **SlotResult モデル拡張**: 合計G数・RB回数・BB回数フィールドを追加
2. **入力UI更新 (EditScreen)**: スロット専用の入力欄を追加（コンパクト3列レイアウト）
3. **一覧カード更新 (ResultCard)**: RB回数・BB回数・大当たり確率を表示
4. **詳細分析更新 (CategoryView + GroupingHelper)**: グループ選択に「複合」を追加し、店舗×機種のクロス集計を表示

---

## 変更ファイル

### モデル層

#### [MODIFY] [slot_result.dart](file:///Users/itta/dev/dart/mahjong_tracker/lib/models/slot_result.dart)
- `totalGames` (int): 合計G数 (デフォルト: 0)
- `rbCount` (int): RB回数 (デフォルト: 0)
- `bbCount` (int): BB回数 (デフォルト: 0)
- `fromFirestore` / `toMap` も対応

---

### サービス層

#### [MODIFY] [category_handler.dart](file:///Users/itta/dev/dart/mahjong_tracker/lib/services/category_handler.dart)
- `CreateResultFunction` の typedef に `totalGames`, `rbCount`, `bbCount` の任意引数を追加

---

### 画面層

#### [MODIFY] [edit_screen.dart](file:///Users/itta/dev/dart/mahjong_tracker/lib/screens/edit_screen.dart)
- スロットカテゴリ用の `totalGames`, `rbCount`, `bbCount` コントローラー追加
- initState でスロット結果の値を読み込む
- スロットフィールドセクションにコンパクトな3列行レイアウト（横並び）で入力欄追加
- バリデーション: 数値のみ許可

#### [MODIFY] [result_card.dart](file:///Users/itta/dev/dart/mahjong_tracker/lib/widgets/result_card.dart)
- SlotResultの場合、以下を表示:
  - RB: X回
  - BB: X回
  - 大当たり確率: 1/X (G数 > 0 の場合、(RB+BB)÷G数)
  - ※未入力(0)時は「-」と表示し、0割り回避

#### [MODIFY] [grouping_helper.dart](file:///Users/itta/dev/dart/mahjong_tracker/lib/utils/grouping_helper.dart)
- `getGroupableProperties` の `slot` に `'compound'` を追加
- `getPropertyLabel` に `'compound'` → `'複合（店舗×機種）'` を追加
- `aggregateResultsAsync` で `property == 'compound'` の場合、店舗×機種キーで集計し、各グループに RB合計・BB合計・G数合計も含める (※未入力(0)のデータは計算から除外)
- `filterResultsAsync` で `property == 'compound'` の場合、対応するフィルタリング処理

#### [MODIFY] [category_view.dart](file:///Users/itta/dev/dart/mahjong_tracker/lib/widgets/category_view.dart)
- `_buildDetailedList` で「複合」グループの場合、収支・合計RB数・合計BB数・RB確率・BB確率・大当たり確率をカードに表示

---

## 複合集計の仕様

| 表示項目 | 計算式 |
|---|---|
| 収支 | 各レコードのamount合計 |
| 合計RB数 | rbCount の合計 |
| 合計BB数 | bbCount の合計 |
| G数合計 | totalGames の合計 |
| RB確率 | 1 / (G数 ÷ RB数) → 1/X 表示 |
| BB確率 | 1 / (G数 ÷ BB数) → 1/X 表示 |
| 大当たり確率 | 1 / (G数 ÷ (RB+BB)) → 1/X 表示 |

> [!NOTE]
> G数が0またはRB/BBが0の場合は「-」表示
