# Multi-stage build: build Qt app then run
# Prefer Ubuntu 24.04 (Qt6 available in universe/multiverse). If Qt6 not available on mirror, fallback to Qt5.
FROM ubuntu:24.04 AS build
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Enable universe and multiverse; install toolchain and Qt6 (fallback to Qt5)
RUN set -eux; \
    export APT_FLAGS="-yq --no-install-recommends"; \
    apt-get update; \
    apt-get install ${APT_FLAGS} software-properties-common ca-certificates gnupg; \
    add-apt-repository -y universe; \
    add-apt-repository -y multiverse; \
    apt-get update; \
    # Try Qt6 first
    (apt-get install ${APT_FLAGS} \
        build-essential cmake ninja-build git pkg-config \
        libgl1-mesa-dev xorg-dev \
        qt6-base-dev qt6-base-dev-tools qt6-tools-dev qt6-tools-dev-tools \
     ) || ( \
      echo "Qt6 not available, falling back to Qt5"; \
      apt-get update; \
      apt-get install ${APT_FLAGS} \
        build-essential cmake ninja-build git pkg-config \
        libgl1-mesa-dev xorg-dev \
        qtbase5-dev qtbase5-dev-tools qttools5-dev qttools5-dev-tools \
     ); \
    # Verify via pkg-config existence for Qt6 or Qt5
    (pkg-config --exists Qt6Core || pkg-config --exists Qt5Core); \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# Configure and build
RUN set -eux; \
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -G Ninja; \
    cmake --build build --config Release -j"$(nproc)"

# Runtime image
FROM ubuntu:24.04 AS run
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Enable universe and multiverse; install minimal runtime libs
RUN set -eux; \
    export APT_FLAGS="-yq --no-install-recommends"; \
    apt-get update; \
    apt-get install ${APT_FLAGS} software-properties-common ca-certificates gnupg; \
    add-apt-repository -y universe; \
    add-apt-repository -y multiverse; \
    apt-get update; \
    # Prefer Qt6 runtime, fallback to Qt5 runtime
    (apt-get install ${APT_FLAGS} \
        libgl1-mesa-glx libx11-6 libxcb1 libxkbcommon0 libxrender1 libxext6 \
        qt6-base-dev \
     ) || ( \
      apt-get update; \
      apt-get install ${APT_FLAGS} \
        libgl1-mesa-glx libx11-6 libxcb1 libxkbcommon0 libxrender1 libxext6 \
        qtbase5-dev \
     ); \
    apt-get purge -y --auto-remove software-properties-common gnupg || true; \
    rm -rf /var/lib/apt/lists/*

# Copy built binary
COPY --from=build /app/build/elegant_clock /usr/local/bin/elegant_clock

# default command starts the app; it will close itself after 200ms
CMD ["/usr/local/bin/elegant_clock"]
