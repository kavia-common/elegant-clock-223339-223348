# elegant_clock - Qt container build (Qt6 prebuilt base image)

This container now uses a prebuilt Qt6 desktop base image to eliminate failures caused by missing or restricted apt-based Qt dev packages. The image already includes Qt6 toolchains and CMake/Ninja, so we only configure, build, and run.

Why this change:
- Reliability: Avoids apt repository restrictions and mirrors that often block Qt dev packages.
- Speed: No heavy package installs; uses pre-provisioned Qt6.
- Consistency: Same Qt toolchain in build and runtime stages avoids runtime missing-library issues.

Base image:
- Default: ghcr.io/qtproject/qt:6.6-desktop
- If your environment cannot access GHCR, replace the base in the Dockerfile with a similar Qt6 desktop image that provides Qt6::Widgets, cmake and ninja.

Environment setup:
- PATH, CMAKE_PREFIX_PATH, and PKG_CONFIG_PATH are set so CMake can find Qt6.
- A lightweight verification step (qmake -v when available, cmake --version, ninja --version) is executed during build.
- A configure-only check is implicit via: cmake -S . -B build -G Ninja.

Build:
  docker build -t elegant_clock:latest .

Run (the app shows a small label and exits after ~200ms as part of the test harness):
  docker run --rm elegant_clock:latest

Notes:
- We use the same Qt base image for the runtime stage to ensure all required Qt6 runtime libraries are present.
- If the base image uses a different Qt install path, adjust QT_HOME, CMAKE_PREFIX_PATH, and LD_LIBRARY_PATH accordingly in the Dockerfile.
