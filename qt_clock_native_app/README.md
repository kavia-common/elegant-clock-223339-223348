# elegant_clock - Qt container build

This container installs Qt development packages (Qt6 preferred, falls back to Qt5) by enabling the Ubuntu 'universe' repo and builds the app with CMake.

Build:
  docker build -t elegant_clock:latest .

Run (the app shows a small label and exits after ~200ms as part of the test harness):
  docker run --rm elegant_clock:latest

Verification steps performed in Dockerfile:
- Explicitly enabled 'universe' (via add-apt-repository -y universe) and ran apt-get update.
- Installed build essentials and Qt6 dev toolchain; if unavailable, fell back to Qt5 dev packages.
- Included GL/X11 headers (libgl1-mesa-dev, xorg-dev) to satisfy Qt GUI build requirements.
- Executed a minimal CMake configure and full build to verify Qt is discoverable.
- Cleaned apt lists to keep image size small and ensured non-interactive apt.

Notes:
- Base image: Ubuntu 22.04 (jammy). Qt6 is available from 'universe'; if mirrors lack Qt6, fallback to Qt5 is automatic.
- For environments where Qt6 is required strictly, consider switching to ubuntu:24.04 or pinning a mirror that contains Qt6.
