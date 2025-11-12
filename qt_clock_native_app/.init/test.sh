#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/elegant-clock-223339-223348/qt_clock_native_app"
cd "$WS"
# Start Xvfb on :99 if not already running; ensure cleanup
XVFB_PID=""
if ! command -v Xvfb >/dev/null 2>&1; then
  echo "Xvfb not found on PATH. Install Xvfb (package xvfb) and retry." >&2
  exit 10
fi
if ! pgrep -f "Xvfb :99" >/dev/null 2>&1; then
  Xvfb :99 -screen 0 1024x768x24 >/tmp/xvfb.log 2>&1 &
  XVFB_PID=$!
  trap 'if [ -n "${XVFB_PID}" ]; then kill ${XVFB_PID} 2>/dev/null || true; fi' EXIT
  # wait for X server
  for i in {1..10}; do sleep 0.5; xdpyinfo -display :99 >/dev/null 2>&1 && break || true; done
  xdpyinfo -display :99 >/dev/null 2>&1 || { echo "Xvfb failed to start (see /tmp/xvfb.log)" >&2; exit 20; }
else
  XVFB_PID=$(pgrep -f "Xvfb :99" | head -n1)
fi
export DISPLAY=:99
# Prefer offscreen plugin if user set it; otherwise keep DISPLAY
: ${QT_QPA_PLATFORM:=""}
if [ -z "${QT_QPA_PLATFORM}" ]; then
  export QT_QPA_PLATFORM="offscreen"
fi
# Source persistent Qt env if present (non-fatal)
[ -f /etc/profile.d/qt_env.sh ] && . /etc/profile.d/qt_env.sh || true
# Verify CMake and ctest
if ! command -v cmake >/dev/null 2>&1; then
  echo "cmake not found on PATH. Install cmake >=3.16 and retry." >&2
  exit 11
fi
if ! command -v ctest >/dev/null 2>&1; then
  echo "ctest not found on PATH. Ensure CMake's ctest is available." >&2
  exit 12
fi
# Configure and build deterministically in build/
mkdir -p build
cmake -S . -B build -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release >/dev/null || { echo "cmake configure failed" >&2; exit 21; }
JOBS=$(nproc 2>/dev/null || echo 2)
cmake --build build -- -j"$JOBS" >/dev/null || { echo "build failed" >&2; exit 22; }
# Run ctest with per-test timeout (seconds)
CTEST_TIMEOUT=5
ctest --output-on-failure -C Release --timeout $CTEST_TIMEOUT || { echo "ctest failed" >&2; exit 23; }
# Clean exit; trap will clean Xvfb if we started it
exit 0
