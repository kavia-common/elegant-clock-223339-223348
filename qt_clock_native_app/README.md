# elegant_clock - Qt container build

This container robustly installs Qt development packages with multiple strategies, preferring Qt6 and falling back to Qt5 or aqtinstall if apt-based installs are restricted. It then builds the app with CMake/Ninja.

Build:
  docker build -t elegant_clock:latest .

Run (the app shows a small label and exits after ~200ms as part of the test harness):
  docker run --rm elegant_clock:latest

Key improvements and verification in Dockerfile:
- Base image explicitly set to Ubuntu 22.04 (jammy) to avoid restricted 24.04 mirrors.
- Explicit /etc/apt/sources.list entries for main, universe, multiverse (including updates, backports, security).
- apt-get update with retry logic.
- Toolchain: build-essential, cmake, ninja-build, pkg-config, GL/X11 headers (libgl1-mesa-dev, xorg-dev).
- Qt6 dev stack attempted first: qt6-base-dev, qt6-base-dev-tools, qt6-tools-dev, qt6-tools-dev-tools, qml6-module-qtquick, qt6-declarative-dev.
- If Qt6 not found, add Qt PPA (ppa:qt/qt6-base) and retry.
- If still not found, fallback to Qt5 dev packages.
- If apt-based Qt unavailable entirely, pivot to aqtinstall: aqt install-qt linux desktop 6.6.2 gcc_64, export PATH and CMAKE_PREFIX_PATH.
- Verification: pkg-config --exists Qt6Core || pkg-config --exists Qt5Core; as final guard, presence of /opt/Qt/6.6.2/gcc_64/bin/qmake; fail early with a clear message otherwise.
- Ensured non-interactive apt (DEBIAN_FRONTEND=noninteractive), used --no-install-recommends, and cleaned apt lists.
- Minimal ldd verification to confirm Qt libraries are linked in the built binary.

Notes:
- If enterprise repositories block both Ubuntu Qt packages and the Qt PPA, the aqtinstall path ensures Qt 6.6.2 is provisioned, and CMAKE_PREFIX_PATH is set so CMake can discover it.
- You may pin a different Qt version in the Dockerfile by changing the aqt install line and PATH/CMAKE_PREFIX_PATH snippets accordingly.
