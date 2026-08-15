# AGENTS.md

このリポジトリで作業するエージェント向け。

## 基本

- iOS は XcodeGen (`ios/project.yml`) が唯一のプロジェクト定義。`.xcodeproj` は生成物なのでコミットしない。
- Swift 6 / iOS 26 / iPhone のみ。公開設定にはApple Developer Team IDを固定しない（CI は `CODE_SIGNING_ALLOWED=NO`）。実機署名時は各自のTeam IDをローカルで指定する。
- 日付計算はすべて JST。妊娠計算の唯一の正解は `ios/Sources/Shared/BabySchedule.swift`（280日・40週・Web版と一致させる）。
- テスト追加時は Web 版との数値一致を確認する基準ケース（2026-08-03 → 残り217日 / 9週0日 / 63日目）を残す。

## iOS表示方針

- ホーム画面・ロック画面ウィジェット中心。再開操作を前提とする常駐表示には戻さない。
- アプリ本体は予定日の設定とウィジェット追加案内のみを担う。
- ウィジェットはJST 0時に日次更新し、予定日変更時には即時再読み込みする。

## CI

- `main`へのpushだけを、メンテナー管理のself-hosted macOS runnerで実行する。外部Pull Requestや任意ブランチのコードをself-hosted runnerで実行しない。
- ワークフローの選択ラベル: `[self-hosted, macOS, ARM64, baby-countdown-ci]`。runnerの実機名や所有者情報はリポジトリへ記載しない。

## 予定日の変更

アプリ内DatePickerで変更可能（App Groupに保存）。コード上のデモ初期値は
`BabySchedule.defaultDueDate`で管理する。利用者固有の予定日やApp Group内の保存値はコミットしない。
