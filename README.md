# baby-countdown

予定日までの日数と妊娠週数を表示する、ウィジェット中心の個人向けカウントダウンです。

- Web: Cloudflare Workers Static Assets
- iOS: SwiftUI / WidgetKit / XcodeGen
- 表示: ホーム画面、ロック画面、アプリ本体
- 日付計算: 280日（40週）、JST基準

公開中のデモは <https://baby.kan.run> です。リポジトリ内の予定日はデモ用の初期値であり、iOSアプリ内のDatePickerから変更できます。

> [!IMPORTANT]
> このアプリは医療機器・医療助言ではありません。妊娠週数や予定日に関する判断は、医療機関からの案内を優先してください。

## 構成

- `web/` — 静的Webカウントダウン
- `ios/` — iOSアプリ「うまれるまで」
  - ホーム画面ウィジェット（Small / Medium）
  - ロック画面ウィジェット（円形・インライン・長方形）
  - App Group経由でアプリとウィジェットの予定日を共有
- `scripts/tests/` — Widget方針・公開安全境界の静的検証

## 計算ロジック

- 妊娠期間280日（40週）、基準日 = 予定日 - 280日
- 週数 = 経過日数 / 7
- 初期 `< 14週` / 中期 `14–27週` / 後期 `28週〜`
- すべてJST基準
- iOS実装の正本は `ios/Sources/Shared/BabySchedule.swift`

## iOSビルド

必要なもの：Xcode 26、XcodeGen、iOS 26 Simulator。

```bash
cd ios
xcodegen generate
xcodebuild test \
  -project BabyCountdown.xcodeproj \
  -scheme BabyCountdown \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO
```

実機へ署名する場合は、自分のApple Developer Team、Bundle ID、App Groupへ変更してください。公開設定には個人のTeam IDを固定していません。

## Webを自分のCloudflareアカウントへデプロイ

実デプロイ設定はGit管理しません。サンプルをコピーし、プレースホルダーを自分の値へ置き換えます。

```bash
cp web/wrangler.example.jsonc web/wrangler.jsonc
# account_id、route、zone_nameを編集
cd web
npx wrangler deploy --config wrangler.jsonc
```

`web/wrangler.jsonc`、`.dev.vars*`、`.wrangler/`は`.gitignore`対象です。実account IDやローカル資格情報をコミットしないでください。

## CIの安全境界

- `ios`: 保護された`main`へのpushだけをメンテナー管理のself-hosted macOS runnerでビルド・テストします。runnerの実機名や所有者情報は公開設定に含めません。
- 外部Pull Requestや任意の作業ブランチからActions、self-hosted runner、secretsは起動しません。メンテナーが静的検証後に取り込み、`main`上でフルiOSテストを実行します。
- `pull_request_target`は使用しません。

## プライバシー

- iOSアプリが保存する予定日はApp Groupの`UserDefaults`内だけに保持されます。
- アプリコードには分析SDK、広告SDK、アカウント機能、開発者への予定日の外部送信はありません。
- Web版は静的ページで、リポジトリのコードにはアクセス解析・利用者識別処理を含みません。
- Forkして公開する場合は、自分や第三者の予定日・Bundle ID・ドメインを公開してよいか確認してください。

## 非公式プロジェクト

本リポジトリは個人開発の非公式プロジェクトです。Apple、医療機関その他の第三者による提携・承認を示すものではありません。

## コントリビューションとセキュリティ

- 開発手順: [CONTRIBUTING.md](CONTRIBUTING.md)
- 脆弱性報告: [SECURITY.md](SECURITY.md)

## License

[MIT License](LICENSE)
