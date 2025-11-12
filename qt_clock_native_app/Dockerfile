# Multi-stage build: build Qt app then run
FROM ubuntu:22.04 AS build
ENV DEBIAN_FRONTEND=noninteractive

# Enable universe and update; install build deps and Qt6 (fallback to Qt5 if needed)
RUN sed -i "s/^# deb/deb/" /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common ca-certificates gnupg && \
    add-apt-repository universe && apt-get update && \
    apt-get install -y --no-install-recommends build-essential cmake git pkg-config \
        qt6-base-dev qt6-base-dev-tools qt6-tools-dev qt6-tools-dev-tools || \
    apt-get install -y --no-install-recommends build-essential cmake git pkg-config \
        qtbase5-dev qttools5-dev qttools5-dev-tools

WORKDIR /app
COPY . /app

# Configure and build
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build --config Release -j$(nproc)

# Runtime image
FROM ubuntu:22.04 AS run
ENV DEBIAN_FRONTEND=noninteractive

# Enable universe and install runtime Qt libs (Qt6 preferred, fallback to Qt5)
RUN sed -i "s/^# deb/deb/" /etc/apt/sources.list && \
    apt-get update && add-apt-repository universe && apt-get update && \
    apt-get install -y --no-install-recommends \
        qt6-base-dev qt6-base-dev-tools qt6-tools-dev qt6-tools-dev-tools || \
    apt-get install -y --no-install-recommends \
        qtbase5-dev qttools5-dev qttools5-dev-tools

WORKDIR /app
COPY --from=build /app/build/elegant_clock /usr/local/bin/elegant_clock

# default command starts the app; it will close itself after 200ms
CMD ["/usr/local/bin/elegant_clock"]
