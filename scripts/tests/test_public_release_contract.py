#!/usr/bin/env python3
"""公開リポジトリとしての安全境界を静的に検証する。"""
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]

required_files = [
    ROOT / "AGENTS.md",
    ROOT / "LICENSE",
    ROOT / "SECURITY.md",
    ROOT / "CONTRIBUTING.md",
    ROOT / "web/wrangler.example.jsonc",
]
for path in required_files:
    assert path.exists(), f"公開用ファイルがありません: {path.relative_to(ROOT)}"

tracked = set(
    subprocess.check_output(["git", "ls-files"], cwd=ROOT, text=True).splitlines()
)
for path in required_files:
    assert path.relative_to(ROOT).as_posix() in tracked, f"公開用ファイルが未追跡です: {path.relative_to(ROOT)}"
assert "web/wrangler.jsonc" not in tracked, "実デプロイ設定を追跡しないでください"
assert "web/wrangler.example.jsonc" in tracked, "公開用Wranglerサンプルが未追跡です"

example = (ROOT / "web/wrangler.example.jsonc").read_text()
assert "YOUR_CLOUDFLARE_ACCOUNT_ID" in example
assert "example.com" in example
assert not re.search(r'"account_id"\s*:\s*"[0-9a-f]{32}"', example), "実account IDがサンプルに残っています"

project = (ROOT / "ios/project.yml").read_text()
assert "DEVELOPMENT_TEAM:" not in project, "個人のApple Team IDを公開設定に固定しないでください"

agents = (ROOT / "AGENTS.md").read_text()
readme = (ROOT / "README.md").read_text()
public_metadata = "\n".join((agents, readme, project))
assert not re.search(r"DEVELOPMENT_TEAM(?:\s*[:=+]|\s+)\s*[A-Z0-9]{10}", public_metadata), "Apple Team IDが公開メタデータに残っています"
assert not re.search(r"/Users/[A-Za-z0-9._-]+", public_metadata), "個人のmacOSホームパスが公開メタデータに残っています"
assert not re.search(r"self-hosted runner（[^）]*(?:Mac|macOS)[^）]*）", public_metadata), "個人所有runnerの説明が公開メタデータに残っています"

for phrase in ("## プライバシー", "外部送信", "wrangler.example.jsonc", "非公式"):
    assert phrase in readme, f"READMEに公開時の説明が不足しています: {phrase}"

ios_workflow = (ROOT / ".github/workflows/ios.yml").read_text()
for phrase in ("push:", "branches: [main]", "self-hosted", "permissions:", "contents: read", "persist-credentials: false", "python3 scripts/tests/test_public_release_contract.py"):
    assert phrase in ios_workflow, f"trusted iOS CIの設定不足: {phrase}"
for forbidden in ('branches: ["**"]', "pull_request:", "pull_request_target:", "secrets."):
    assert forbidden not in ios_workflow, f"外部PRからtrusted CIを起動しないでください: {forbidden}"

for line in ios_workflow.splitlines():
    if "uses:" in line:
        assert re.search(r"uses:\s+[^@]+@[0-9a-f]{40}(?:\s|$)", line), f"Actionを完全SHAで固定してください: {line.strip()}"

print("public release contract: PASS")
