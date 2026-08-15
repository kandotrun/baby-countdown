# Security Policy

## Reporting a vulnerability

公開Issueには、脆弱性の再現手順、未公開の個人情報、資格情報を投稿しないでください。

GitHubの **Report a vulnerability**（Private Vulnerability Reporting）から、影響範囲、再現条件、想定される悪用方法を報告してください。受領後、内容を確認して対応方針を返信します。

## Scope

主な対象は次のとおりです。

- iOSアプリ・Widget Extensionにおける意図しないデータ露出
- App Group / UserDefaultsの扱い
- Web版におけるスクリプト注入や危険な外部通信
- GitHub Actionsからの秘密情報・self-hosted runner露出

医療上の正確性や個別の健康相談はセキュリティ報告の対象外です。このプロジェクトは医療機器ではありません。
