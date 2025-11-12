cmake_minimum_required(VERSION 3.16)
project(elegant_clock LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)

# Prefer Qt5 (primary), then fall back to Qt6 if present.
find_package(Qt5 COMPONENTS Widgets QUIET)
if (TARGET Qt5::Widgets)
  set(USE_QT5 TRUE)
else()
  find_package(Qt6 COMPONENTS Widgets QUIET)
  if (TARGET Qt6::Widgets)
    set(USE_QT6 TRUE)
  endif()
endif()

add_executable(elegant_clock main.cpp)

if (USE_QT5)
  target_link_libraries(elegant_clock PRIVATE Qt5::Widgets)
elseif (USE_QT6)
  target_link_libraries(elegant_clock PRIVATE Qt6::Widgets)
else()
  message(WARNING "No Qt target found; configure may fail without Qt dev installed")
endif()

enable_testing()
add_test(NAME run_headless_app COMMAND $<TARGET_FILE:elegant_clock>)
