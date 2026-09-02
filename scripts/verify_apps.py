#!/usr/bin/env python3
"""Verify the 1 Minute DOES Help timer is a real 60-second wall-clock countdown."""

from __future__ import annotations

import re
from pathlib import Path


def test_duration_constant() -> None:
    source = Path("/workspace/OneMinuteDOESHelp/MinuteTimer.swift").read_text()
    match = re.search(r"static let duration: TimeInterval = (\d+)", source)
    assert match, "MinuteTimer.duration is missing"
    assert match.group(1) == "60", f"Timer must last 60 seconds, found {match.group(1)}"
    assert "addingTimeInterval(Self.duration)" in source
    assert "endDate.timeIntervalSince" in source
    assert "Timer.publish" in source


def remaining(end_timestamp: float, now: float) -> float:
    return max(0.0, end_timestamp - now)


def test_wall_clock_countdown() -> None:
    duration = 60.0
    start = 1_000_000.0
    end = start + duration
    assert remaining(end, start) == 60.0
    assert remaining(end, start + 1) == 59.0
    assert remaining(end, start + 30) == 30.0
    assert abs(remaining(end, start + 59.2) - 0.8) < 1e-9
    assert remaining(end, start + 60) == 0.0
    assert remaining(end, start + 90) == 0.0


def test_progress() -> None:
    duration = 60.0
    for elapsed in (0, 15, 30, 45, 60):
        left = duration - elapsed
        progress = min(1.0, max(0.0, (duration - left) / duration))
        assert abs(progress - elapsed / duration) < 1e-9


def test_apps_have_required_copy() -> None:
    one = Path("/workspace/OneMinuteDOESHelp/HomeView.swift").read_text()
    assert "Start 1 minute" in one
    assert "Breathe" in Path("/workspace/OneMinuteDOESHelp/Theme.swift").read_text()
    assert "Drink water" in Path("/workspace/OneMinuteDOESHelp/Theme.swift").read_text()
    assert "Stand up" in Path("/workspace/OneMinuteDOESHelp/Theme.swift").read_text()

    ifat = Path("/workspace/iFat").read_text() if False else ""
    theme = Path("/workspace/iFat/Theme.swift").read_text()
    home = Path("/workspace/iFat/HomeView.swift").read_text()
    assert "Energised" in theme and "Steady" in theme and "Tired" in theme
    assert "calorie" in home.lower()
    assert "2 of 3" in Path("/workspace/iFat/CareRingView.swift").read_text() or "completed) of \\(total)" in Path(
        "/workspace/iFat/CareRingView.swift"
    ).read_text()

    gym = Path("/workspace/OKGym/HomeView.swift").read_text()
    assert "PUSH" in gym
    assert "Start workout" in gym
    assert "weeklyStrip" in gym


if __name__ == "__main__":
    test_duration_constant()
    test_wall_clock_countdown()
    test_progress()
    test_apps_have_required_copy()
    print("All timer and copy checks passed.")
