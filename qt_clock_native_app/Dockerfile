# Qt5-based multi-stage build on Ubuntu 20.04 (focal)
# This image installs Qt5 dev packages and common C++ build tools.
# We explicitly target Qt5 to avoid unavailable Qt6 packages in apt sources.

FROM ubuntu:20.04 AS build

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Enable 'universe' repository and install Qt5 + build tools
RUN set -eux; \
    sed -i 's/^# deb/deb/' /etc/apt/sources.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      software-properties-common \
      ca-certificates \
      build-essential \
      cmake \
      ninja-build \
      pkg-config \
      qtbase5-dev \
      qtbase5-dev-tools \
      qttools5-dev \
      qttools5-dev-tools \
      libgl1-mesa-dev \
      xorg-dev; \
    rm -rf /var/lib/apt/lists/*

# Common Qt5 environment discovery hints
# Many CMake projects can auto-detect Qt5 with the installed cmake + Qt5 cmake config files.
# CMAKE_PREFIX_PATH is set defensively to help find Qt5.
ENV QT_MAJOR=5
ENV QMAKE=qmake
ENV CMAKE_PREFIX_PATH="/usr/lib/x86_64-linux-gnu/cmake:/usr/lib/cmake:${CMAKE_PREFIX_PATH}"
ENV PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:${PKG_CONFIG_PATH}"

# Lightweight verification of Qt5 availability
RUN set -eux; \
    (qmake -v || qmake -query || true); \
    cmake --version; \
    (pkg-config --exists Qt5Core && echo "pkg-config: Qt5Core found") || (echo "pkg-config: Qt5Core not found but may still be available via CMake configs"; true)

WORKDIR /app
COPY . /app

# Configure and build with CMake + Ninja
# The CMakeLists.txt attempts Qt6 first, then Qt5. With Qt5 installed, it should link to Qt5::Widgets.
RUN set -eux; \
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -G Ninja; \
    cmake --build build --config Release -j"$(nproc)"; \
    # Verify binary is linked to Qt5
    ldd build/elegant_clock | grep -E "Qt5" || true

# Runtime image: slim Ubuntu with necessary runtime libs for Qt5
FROM ubuntu:20.04 AS run

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal runtime libraries for Qt5 GUI apps
RUN set -eux; \
    sed -i 's/^# deb/deb/' /etc/apt/sources.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      qtbase5-dev \
      libgl1 \
      libx11-6 \
      libxext6 \
      libxrender1 \
      libxkbcommon0 \
      libxkbcommon-x11-0 \
      libxcb1 \
      libxcb-xinerama0 \
      libxcb-render0 \
      libxcb-shape0 \
      libxcb-xfixes0 \
      libxcb-shm0 \
      libxcb-icccm4 \
      libxcb-image0 \
      libxcb-keysyms1 \
      libxcb-randr0 \
      libxcb-render-util0 \
      libxcb-util1 \
      libx11-xcb1; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Copy the built binary
COPY --from=build /app/build/elegant_clock /usr/local/bin/elegant_clock

# Default command starts the app; it will close itself after ~200ms by design
CMD ["/usr/local/bin/elegant_clock"]
