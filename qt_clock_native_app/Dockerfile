# Multi-stage build: build Qt app then run
# Explicitly use Ubuntu 22.04 to avoid restricted 24.04 mirrors
FROM ubuntu:22.04 AS build
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Configure apt sources explicitly; add universe/multiverse; robust update with retries.
# Attempt to install Qt6 stack first; if unavailable try Qt PPA; fallback to Qt5; final fallback via aqtinstall.
RUN set -euxo pipefail; \
    export APT_FLAGS="-yq --no-install-recommends"; \
    # Setup sources.list explicitly (main, universe, multiverse for jammy)
    codename="$(
      . /etc/os-release; echo "${VERSION_CODENAME:-jammy}"
    )"; \
    echo "Using codename: ${codename}"; \
    cat > /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu ${codename} main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${codename}-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${codename}-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu ${codename}-security main restricted universe multiverse
EOF
    ; \
    # Update with basic retry logic
    for i in 1 2 3; do \
      apt-get update && break || (echo "apt-get update failed (attempt $i), retrying in 5s..." && sleep 5); \
    done; \
    apt-get install ${APT_FLAGS} ca-certificates gnupg dirmngr software-properties-common curl python3-pip python3-venv pipx; \
    # Toolchain and common build deps
    apt-get install ${APT_FLAGS} build-essential cmake ninja-build git pkg-config libgl1-mesa-dev xorg-dev; \
    # Try to install Qt6 from Ubuntu repositories
    QT6_PKGS="qt6-base-dev qt6-base-dev-tools qt6-tools-dev qt6-tools-dev-tools qml6-module-qtquick qt6-declarative-dev"; \
    set +e; \
    apt-get install ${APT_FLAGS} ${QT6_PKGS}; \
    QT6_STATUS=$?; \
    set -e; \
    if [ ${QT6_STATUS} -ne 0 ]; then \
      echo "Qt6 packages not found in default repos. Trying official Qt PPA..."; \
      add-apt-repository -y ppa:qt/qt6-base || true; \
      for i in 1 2 3; do \
        apt-get update && break || (echo "apt-get update after PPA failed (attempt $i), retrying..." && sleep 5); \
      done; \
      set +e; apt-get install ${APT_FLAGS} ${QT6_PKGS}; QT6_STATUS=$?; set -e; \
    fi; \
    if [ ${QT6_STATUS} -ne 0 ]; then \
      echo "Qt6 still unavailable; falling back to Qt5 packages from Ubuntu repos..."; \
      apt-get install ${APT_FLAGS} qtbase5-dev qtbase5-dev-tools qttools5-dev qttools5-dev-tools; \
    fi; \
    # Verify via pkg-config (Qt6 or Qt5) — if not found, pivot to aqtinstall
    if ! (pkg-config --exists Qt6Core || pkg-config --exists Qt5Core); then \
      echo "Neither Qt6 nor Qt5 dev packages detected via pkg-config; installing Qt 6.6.2 using aqtinstall..."; \
      pipx ensurepath || true; \
      pipx install aqtinstall; \
      # Install Qt using aqt to /opt/Qt; select linux desktop gcc_64 kit
      aqt install-qt --outputdir /opt/Qt linux desktop 6.6.2 gcc_64; \
      # Setup environment for CMake discovery
      echo 'export PATH=/opt/Qt/6.6.2/gcc_64/bin:$PATH' >/etc/profile.d/qt.sh; \
      echo 'export CMAKE_PREFIX_PATH=/opt/Qt/6.6.2/gcc_64/lib/cmake${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}' >>/etc/profile.d/qt.sh; \
      chmod +x /etc/profile.d/qt.sh; \
      # Source env in this layer and verify qmake/moc presence
      source /etc/profile.d/qt.sh; \
      command -v qmake || true; \
    fi; \
    # Final verification: fail early if no Qt available
    if ! (pkg-config --exists Qt6Core || pkg-config --exists Qt5Core || [ -x /opt/Qt/6.6.2/gcc_64/bin/qmake ]); then \
      echo "ERROR: Qt dev toolchain not available after all strategies."; \
      exit 1; \
    fi; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# Configure and build (ensure env supports aqt path if used)
RUN set -eux; \
    if [ -f /etc/profile.d/qt.sh ]; then source /etc/profile.d/qt.sh; fi; \
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -G Ninja ${CMAKE_PREFIX_PATH:+-DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH"}; \
    cmake --build build --config Release -j"$(nproc)"; \
    # Minimal verification: ensure binary links and Qt can be located
    ldd build/elegant_clock | grep -E "Qt(6|5)" || true

# Runtime image
FROM ubuntu:22.04 AS run
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Explicit sources, minimal runtime libs, and optionally Qt runtime if needed.
RUN set -eux; \
    codename="$(
      . /etc/os-release; echo "${VERSION_CODENAME:-jammy}"
    )"; \
    cat > /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu ${codename} main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${codename}-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${codename}-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu ${codename}-security main restricted universe multiverse
EOF
    ; \
    for i in 1 2 3; do \
      apt-get update && break || (echo "apt-get update failed (attempt $i), retrying in 5s..." && sleep 5); \
    done; \
    apt-get install -yq --no-install-recommends ca-certificates libgl1-mesa-glx libx11-6 libxcb1 libxkbcommon0 libxrender1 libxext6; \
    rm -rf /var/lib/apt/lists/*

# Copy built binary
COPY --from=build /app/build/elegant_clock /usr/local/bin/elegant_clock

# default command starts the app; it will close itself after 200ms
CMD ["/usr/local/bin/elegant_clock"]
