# Contributing

IssueやPull Requestを歓迎します。変更は小さく、目的を明確にしてください。

## 開発

```bash
python3 scripts/tests/test_widget_only_contract.py
python3 scripts/tests/test_public_release_contract.py
```

iOSの変更では、XcodeGenでプロジェクトを生成してテストします。

```bash
cd ios
xcodegen generate
xcodebuild test \
  -project BabyCountdown.xcodeproj \
  -scheme BabyCountdown \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO
```

## Pull Requestの条件

- 予定日計算はJST・280日・40週の契約を維持する
- Live Activityを再導入せず、WidgetKit常設表示を維持する
- 実account ID、資格情報、個人の未公開予定日をコミットしない
- `web/wrangler.jsonc`ではなく`web/wrangler.example.jsonc`だけを更新する
- UI変更ではVoiceOver、Dynamic Type、コントラストを考慮する
- 実行したテストをPR本文に記載する

外部Pull Requestや任意の作業ブランチからActionsやself-hosted runnerは起動しません。静的検証後、メンテナーが`main`へ取り込み、フルiOSテストを実行します。
