#!/usr/bin/env bash
set -euo pipefail
# Validation script: build, start, probe, stop the Qt binary under short watchdog
WS="/home/kavia/workspace/code-generation/elegant-clock-223339-223348/qt_clock_native_app"
cd "$WS"
XVFB_PID=""
USE_OFFSCREEN=0
if ! pgrep -f "Xvfb :99" >/dev/null 2>&1; then
  Xvfb :99 -screen 0 1024x768x24 >/tmp/xvfb_val.log 2>&1 &
  XVFB_PID=$!
  trap 'if [ -n "${XVFB_PID}" ]; then kill ${XVFB_PID} 2>/dev/null || true; fi' EXIT
  for i in {1..10}; do sleep 0.5; xdpyinfo -display :99 >/dev/null 2>&1 && break || true; done
  xdpyinfo -display :99 >/dev/null 2>&1 || USE_OFFSCREEN=1
else
  XVFB_PID=$(pgrep -f "Xvfb :99" | head -n1)
fi
if [ "$USE_OFFSCREEN" -eq 0 ]; then export DISPLAY=:99; else export QT_QPA_PLATFORM=offscreen; fi
. /etc/profile.d/qt_env.sh 2>/dev/null || true
# Build (idempotent)
mkdir -p build
cmake -S . -B build -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release >/dev/null || { echo "cmake configure failed" >&2; exit 30; }
JOBS=$(nproc 2>/dev/null || echo 2)
cmake --build build -- -j"$JOBS" >/dev/null || { echo "build failed" >&2; exit 31; }
BIN="$WS/build/elegant_clock"
[ -x "$BIN" ] || { echo "build binary missing: $BIN" >&2; exit 32; }
# Run with timeout to avoid indefinite hang (5s)
TMP_OUT=/tmp/elegant_clock.out
TMP_ERR=/tmp/elegant_clock.err
timeout 5s "$BIN" >"$TMP_OUT" 2>"$TMP_ERR" &
APP_PID=$!
sleep 0.5
if ! ps -p "$APP_PID" >/dev/null 2>&1; then echo "app failed to start" >&2; sed -n '1,200p' "$TMP_ERR" || true; exit 33; fi
ps -p "$APP_PID" -o pid,cmd
# Attempt graceful shutdown
kill "$APP_PID" 2>/dev/null || true
set +e
wait "$APP_PID"
WAIT_RET=$?
set -e
echo "app exit status: $WAIT_RET"
echo "--- STDOUT ---"; sed -n '1,200p' "$TMP_OUT" || true
echo "--- STDERR ---"; sed -n '1,200p' "$TMP_ERR" || true
if [ -n "${XVFB_PID}" ]; then kill ${XVFB_PID} 2>/dev/null || true; fi
if [ "$WAIT_RET" -eq 0 ]; then echo "validation: OK"; else echo "validation: FAILED with exit $WAIT_RET" >&2; exit 40; fi
