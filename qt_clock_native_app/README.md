# elegant_clock - Qt container build (Qt5 on Ubuntu 20.04)

This container targets Qt5 on Ubuntu 20.04 (focal) to avoid unavailable Qt6 packages in apt sources. It installs Qt5 development packages and common build tools, then configures and builds the app using CMake + Ninja.

Why Qt5:
- Availability: Qt5 packages are widely available in focal with universe enabled.
- Simplicity: No external registries or prebuilt Qt6 images required.
- Compatibility: CMakeLists.txt already supports Qt5 fallback.

Base image:
- Build stage: ubuntu:20.04
- Runtime stage: ubuntu:20.04 (with minimal Qt5 runtime libraries)

Environment setup:
- DEBIAN_FRONTEND=noninteractive ensures non-interactive apt.
- CMAKE_PREFIX_PATH and PKG_CONFIG_PATH are set defensively for Qt5 discovery.
- Lightweight verification runs during build:
  - qmake -v (or -query)
  - cmake --version
  - pkg-config --exists Qt5Core

Build:
  docker build -t elegant_clock:latest .

Run (the app shows a small label and exits after ~200ms as part of the test harness):
  docker run --rm elegant_clock:latest

Notes:
- CMakeLists.txt tries Qt6 first, then Qt5. With this image, Qt5 will be discovered and linked (Qt5::Widgets).
- If you need to force Qt5 discovery in your own projects, ensure:
  - find_package(Qt5 COMPONENTS Widgets REQUIRED)
  - Or export CMAKE_PREFIX_PATH to include Qt5's cmake directories.
