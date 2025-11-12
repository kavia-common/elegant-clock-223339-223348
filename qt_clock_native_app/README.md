# elegant_clock - Qt container build

This container installs Qt development packages (Qt6 preferred, falls back to Qt5) by enabling the Ubuntu 'universe' and 'multiverse' repositories and builds the app with CMake/Ninja.

Build:
  docker build -t elegant_clock:latest .

Run (the app shows a small label and exits after ~200ms as part of the test harness):
  docker run --rm elegant_clock:latest

Verification steps performed in Dockerfile:
- Explicitly enabled 'universe' and 'multiverse' (via add-apt-repository -y) and ran apt-get update.
- Installed toolchain: build-essential, cmake, ninja-build, pkg-config, GL/X11 headers (libgl1-mesa-dev, xorg-dev).
- Installed Qt6 dev toolchain (qt6-base-dev, qt6-base-dev-tools, qt6-tools-dev, qt6-tools-dev-tools). If unavailable on mirror, fell back to Qt5.
- Verified availability using pkg-config: pkg-config --exists Qt6Core || pkg-config --exists Qt5Core.
- Executed CMake configure and build to ensure Qt is discoverable.
- Ensured non-interactive apt (DEBIAN_FRONTEND=noninteractive) and cleaned apt lists.

Notes:
- Base image: Ubuntu 24.04 (noble) to maximize Qt6 availability. If your environment mandates 22.04, the Dockerfile logic will still fall back to Qt5 when Qt6 is not present.
- If strict Qt6 is required in all environments, pin ubuntu:24.04 and consider adding a specific mirror or PPA that provides Qt6.
