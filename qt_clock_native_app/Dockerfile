# Multi-stage build using a prebuilt Qt6 desktop image
# We use a widely available Qt 6 desktop base that includes Qt toolchain and CMake/Ninja.
# Example base: ghcr.io/qtproject/qt:6.6-desktop
# If your registry cannot access ghcr.io, replace the FROM with an equivalent Qt6 desktop image that provides Qt6::Widgets and cmake/ninja.
FROM ghcr.io/qtproject/qt:6.6-desktop AS build

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Ensure typical envs are exported for CMake/Qt discovery.
# Many Qt base images already set these, but we set defensively.
ENV QT_MAJOR=6 \
    QT_VERSION=6.6 \
    QT_HOME=/opt/Qt/6.6.0/gcc_64
# Adjust paths if the base image publishes different locations;
# Common locations include /opt/Qt/<ver>/gcc_64 or /usr/lib/qt6.
ENV PATH="${QT_HOME}/bin:${PATH}"
ENV CMAKE_PREFIX_PATH="${QT_HOME}:${QT_HOME}/lib/cmake:${CMAKE_PREFIX_PATH}"
ENV PKG_CONFIG_PATH="${QT_HOME}/lib/pkgconfig:${PKG_CONFIG_PATH}"

# Lightweight verification of Qt tool availability
RUN set -eux; \
    (qmake -v || echo "qmake not found (some Qt6 builds are cmake-only)"); \
    cmake --version; \
    ninja --version || true

WORKDIR /app
COPY . /app

# Configure and build with CMake + Ninja
RUN set -eux; \
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -G Ninja; \
    cmake --build build --config Release -j"$(nproc)"; \
    # Verify binary is linked to Qt6
    ldd build/elegant_clock | grep -E "Qt6" || true

# Runtime image: use the same Qt base to avoid missing runtime libraries
FROM ghcr.io/qtproject/qt:6.6-desktop AS run
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy the built binary
COPY --from=build /app/build/elegant_clock /usr/local/bin/elegant_clock

# Optional: export runtime library paths if needed by the base image layout
ENV QT_HOME=/opt/Qt/6.6.0/gcc_64
ENV LD_LIBRARY_PATH="${QT_HOME}/lib:${LD_LIBRARY_PATH}"

# default command starts the app; it will close itself after ~200ms by design
CMD ["/usr/local/bin/elegant_clock"]
