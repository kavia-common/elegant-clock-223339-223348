#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/elegant-clock-223339-223348/qt_clock_native_app"
mkdir -p "$WS" && cd "$WS"
# If both files exist, skip to preserve any existing project
if [ -f "$WS/CMakeLists.txt" ] && [ -f "$WS/main.cpp" ]; then exit 0; fi
cat > "$WS/main.cpp" <<'CPP'
#include <QApplication>
#include <QLabel>
#include <QTimer>
int main(int argc, char **argv){ QApplication a(argc, argv); QLabel l("Qt Headless Test"); l.show(); // quit shortly to make test deterministic
 QTimer::singleShot(200, &a, &QCoreApplication::quit); return a.exec(); }
CPP
cat > "$WS/CMakeLists.txt" <<'CMAKE'
cmake_minimum_required(VERSION 3.16)
project(elegant_clock LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)
find_package(Qt6 COMPONENTS Widgets QUIET)
if (TARGET Qt6::Widgets)
  set(USE_QT6 TRUE)
endif()
if (NOT USE_QT6)
  find_package(Qt5 COMPONENTS Widgets QUIET)
  if (TARGET Qt5::Widgets)
    set(USE_QT5 TRUE)
  endif()
endif()
add_executable(elegant_clock main.cpp)
if (USE_QT6)
  target_link_libraries(elegant_clock PRIVATE Qt6::Widgets)
elseif (USE_QT5)
  target_link_libraries(elegant_clock PRIVATE Qt5::Widgets)
else()
  message(WARNING "No Qt target found; configure may fail without Qt dev installed")
endif()
enable_testing()
add_test(NAME run_headless_app COMMAND $<TARGET_FILE:elegant_clock>)
CMAKE
mkdir -p build
