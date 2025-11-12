# Multi-stage build: build Qt app then run
# Use Ubuntu 22.04 where Qt6 packages are available from universe
FROM ubuntu:22.04 AS build
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Enable universe and update; install build deps and Qt6 (fallback to Qt5 if needed)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends software-properties-common ca-certificates gnupg; \
    add-apt-repository -y universe; \
    apt-get update; \
    # Try Qt6 first with full build stack; if it fails, install Qt5 equivalents.
    (apt-get install -y --no-install-recommends \
        build-essential cmake git pkg-config \
        libgl1-mesa-dev xorg-dev \
        qt6-base-dev qt6-base-dev-tools qt6-tools-dev qt6-tools-dev-tools \
     ) || ( \
      apt-get update; \
      apt-get install -y --no-install-recommends \
        build-essential cmake git pkg-config \
        libgl1-mesa-dev xorg-dev \
        qtbase5-dev qtbase5-dev-tools qttools5-dev qttools5-dev-tools \
     ); \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# Verify Qt availability via minimal configure, then build
# This step ensures CMake finds Qt and fails fast if dev packages are missing.
RUN set -eux; \
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release; \
    cmake --build build --config Release -j"$(nproc)"

# Runtime image
FROM ubuntu:22.04 AS run
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Enable universe and install runtime Qt libraries (prefer Qt6, fallback to Qt5)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends software-properties-common ca-certificates gnupg; \
    add-apt-repository -y universe; \
    apt-get update; \
    (apt-get install -y --no-install-recommends \
        libgl1-mesa-dev xorg-dev \
        qt6-base-dev qt6-base-dev-tools \
     ) || ( \
      apt-get update; \
      apt-get install -y --no-install-recommends \
        libgl1-mesa-dev xorg-dev \
        qtbase5-dev qtbase5-dev-tools \
     ); \
    apt-get purge -y --auto-remove software-properties-common gnupg || true; \
    rm -rf /var/lib/apt/lists/*

# Copy built binary
COPY --from=build /app/build/elegant_clock /usr/local/bin/elegant_clock

# default command starts the app; it will close itself after 200ms
CMD ["/usr/local/bin/elegant_clock"]
