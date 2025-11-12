# elegant_clock - Qt container build

This container installs Qt development packages (Qt6 preferred, falls back to Qt5) by enabling the Ubuntu 'universe' repo and builds the app with CMake.

Build:
  docker build -t elegant_clock:latest .

Run (the app shows a small label and exits after ~200ms as part of the test harness):
  docker run --rm elegant_clock:latest

Notes:
- The Dockerfile targets Ubuntu 22.04.
- It attempts to install Qt6 first (qt6-base-dev, qt6-tools-*) then falls back to Qt5 (qtbase5-dev, qttools5-dev-*) if Qt6 is unavailable in apt sources.
