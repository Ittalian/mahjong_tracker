# 麻雀収支管理アプリ 実装計画

FlutterとFirebase (Firestore) を使用して、麻雀の収支を管理するアプリケーションを作成します。

## ユーザーレビューが必要な事項

> [!IMPORTANT]
> **Firebaseの設定について**
> アプリのコードは作成しますが、実際に動作させるためには、ユーザーご自身でFirebaseプロジェクトを作成し、設定ファイル（`google-services.json` や `firebase_options.dart`）をプロジェクトに追加する必要があります。今回はコードベースの構築までを行います。

## 提案する変更

### プロジェクト構成
- **ディレクトリ**: `C:\Users\bothm\.gemini\antigravity\scratch\mahjong_tracker`
- **フレームワーク**: Flutter
- **データベース**: Cloud Firestore

### データモデル
#### `MahjongResult`
- `id`: String (ドキュメントID)
- `date`: DateTime (対局日)
- `amount`: int (収支金額、プラス/マイナス)
- `memo`: String (メモ、場所など)
- `createdAt`: DateTime (作成日時、ソート用)

### 画面構成

#### 1. 収支閲覧画面 (ホーム画面)
- **機能**:
    - 収支リストの表示（日付順）
    - 合計収支の表示
    - 編集画面への遷移（リストアイテムタップ）
    - 削除機能（リストアイテムのスワイプまたは長押しで確認ダイアログ表示）
    - 追加画面への遷移（フローティングアクションボタン）

#### 2. 収支編集・追加画面
- **機能**:
    - 新規追加と既存データの編集を兼ねる
    - 日付ピッカー
    - 金額入力フィールド（キーボードは数値用）
    - メモ入力フィールド
    - 保存ボタン

#### 3. 削除機能
- **機能**:
    - 削除確認ダイアログを表示し、「OK」でFirestoreからドキュメントを削除

### ファイル構成案

#### [NEW] lib/
- `main.dart`: エントリーポイント、Firebase初期化
- `models/mahjong_result.dart`: データモデル
- `services/firestore_service.dart`: Firestoreとの通信ロジック
- `screens/home_screen.dart`: 一覧画面
- `screens/edit_screen.dart`: 追加・編集画面
- `widgets/result_card.dart`: 一覧の各行のウィジェット

## 検証計画

### 自動テスト
- 今回は小規模アプリのため、ユニットテストは省略し、実装コードの正確性を重視します。

### 手動検証
- アプリがビルド可能であることを確認します (`flutter build apk --debug` 等)。
- *注: Firebase接続設定がない環境では実行時にエラーになるため、コードの静的解析と構造の正しさを検証します。*
