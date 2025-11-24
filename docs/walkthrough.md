# 麻雀収支管理アプリ Walkthrough

麻雀の収支を管理するFlutterアプリケーションの実装が完了しました。
Firebase (Firestore) をバックエンドに使用し、リアルタイムなデータ同期が可能です。

## 実装された機能

### 1. 収支閲覧画面 (ホーム画面)
- **収支リスト**: 日付順に収支履歴を表示します。
- **合計収支**: 全履歴の合計金額をヘッダーに表示します。プラスなら緑、マイナスなら赤で表示されます。
- **操作**:
    - **タップ**: 編集画面へ遷移します。
    - **長押し**: 削除確認ダイアログを表示します。
    - **FAB (右下ボタン)**: 新規追加画面へ遷移します。

### 2. 収支編集・追加画面
- **日付選択**: カレンダーから日付を選択できます。
- **金額入力**: プラスまたはマイナスの数値を入力します。
- **メモ入力**: 場所や対戦相手などのメモを残せます。
- **保存**: Firestoreにデータを保存し、ホーム画面へ戻ります。

## セットアップ手順 (重要)

このアプリを動作させるためには、Firebaseプロジェクトの設定が必要です。以下の手順に従ってください。

### 1. Firebaseプロジェクトの作成
1. [Firebase Console](https://console.firebase.google.com/) にアクセスし、新しいプロジェクトを作成します。
2. プロジェクト名は任意（例: `mahjong-tracker`）で構いません。

### 2. Firestoreの有効化
1. Firebase Consoleの左メニューから「Build」>「Firestore Database」を選択します。
2. 「データベースの作成」をクリックします。
3. ロケーションを選択し（例: `asia-northeast1`）、セキュリティルールは「テストモード」で開始するか、以下のようなルールを設定します。
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /results/{document=**} {
         allow read, write: if true; // 注: 本番運用時は認証を追加して制限してください
       }
     }
   }
   ```

### 3. アプリとFirebaseの連携
FlutterアプリとFirebaseを連携させるために、`flutterfire_cli` を使用するのが最も簡単です。

1. ターミナルで以下のコマンドを実行し、Firebaseにログインします。
   ```bash
   firebase login
   ```
2. `flutterfire_cli` をインストールしていない場合はインストールします。
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. プロジェクトのルートディレクトリ (`mahjong_tracker`) で以下のコマンドを実行します。
   ```bash
   flutterfire configure
   ```
4. 画面の指示に従い、先ほど作成したFirebaseプロジェクトを選択し、プラットフォーム（Android, iOSなど）を選択します。
5. これにより、`lib/firebase_options.dart` が自動生成されます。

### 4. コードの有効化
`lib/main.dart` を開き、コメントアウトされている部分を解除します。

```dart
// lib/main.dart

import 'firebase_options.dart'; // コメントアウトを解除

// ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // コメントアウトを解除
  );

  runApp(const MyApp());
}
```

### 5. アプリの実行
設定が完了したら、以下のコマンドでアプリを実行します。

```bash
flutter run
```

## ファイル構成
- `lib/main.dart`: アプリのエントリーポイント
- `lib/models/mahjong_result.dart`: データモデル
- `lib/services/firestore_service.dart`: Firestore通信ロジック
- `lib/screens/home_screen.dart`: 一覧画面
- `lib/screens/edit_screen.dart`: 編集・追加画面
- `lib/widgets/result_card.dart`: リストアイテムウィジェット
