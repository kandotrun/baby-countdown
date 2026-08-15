#!/usr/bin/env python3
"""iOS版が常設ウィジェット専用であることを検証する。"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
IOS = ROOT / "ios"

obsolete_files = [
    IOS / "Sources/App/LiveActivityManager.swift",
    IOS / "Sources/Shared/BabyCountdownAttributes.swift",
    IOS / "BabyCountdownWidgets/CountdownLiveActivityWidget.swift",
    ROOT / "scripts/tests/test_live_activity_from_any_week.py",
]
for path in obsolete_files:
    assert not path.exists(), f"Live Activity用ファイルが残っています: {path.relative_to(ROOT)}"

for path in [*IOS.rglob("*.swift"), *IOS.rglob("*.plist"), ROOT / "README.md"]:
    text = path.read_text()
    for forbidden in (
        "ActivityKit",
        "LiveActivity",
        "NSSupportsLiveActivities",
        "ライブアクティビティ",
        "Dynamic Island",
        "fullTermWeeks",
        "isFullTerm",
    ):
        assert forbidden not in text, f"{path.relative_to(ROOT)} に {forbidden} が残っています"

content = (IOS / "Sources/App/ContentView.swift").read_text()
bundle = (IOS / "BabyCountdownWidgets/BabyCountdownWidgetBundle.swift").read_text()
readme = (ROOT / "README.md").read_text()
assert "ウィジェットを追加" in content, "アプリにウィジェット追加案内がありません"
assert "JST 0時" in content, "ウィジェットの自動更新時刻が案内されていません"
assert "アプリを毎日開く必要はありません" in content, "常設ウィジェットの案内が不足しています"
assert 'WidgetCenter.shared.reloadTimelines(ofKind: "CountdownWidget")' in content, "予定日変更時にウィジェットが更新されません"
assert bundle.count("CountdownWidget()") == 1, "Widget bundleはCountdownWidgetだけにしてください"
assert "ウィジェット中心" in readme, "READMEにウィジェット中心の方針がありません"
print("widget-only contract: PASS")
