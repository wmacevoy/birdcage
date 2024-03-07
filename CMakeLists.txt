# Define the minimum required version of CMake
cmake_minimum_required(VERSION 3.10)

# Define your project name and the language used
project(birdcage LANGUAGES CXX)

# Set the C++ standard to C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include header files
include_directories(include)

# Define source files for the library
file(GLOB SOURCES "src/*.cpp")

# Add a library target for the static library
add_library(birdcage_static STATIC ${SOURCES})

# Add a library target for the shared library
add_library(birdcage_shared SHARED ${SOURCES})

# Set output names for libraries if you want to differentiate them
set_target_properties(birdcage_static PROPERTIES OUTPUT_NAME birdcage)
set_target_properties(birdcage_shared PROPERTIES OUTPUT_NAME birdcage)

# OPTIONAL: Set the position independent code property for the static library if it will be used with shared libraries
set_property(TARGET birdcage_static PROPERTY POSITION_INDEPENDENT_CODE ON)

# Enable testing functionalities
enable_testing()

# Add the tests subdirectory
add_subdirectory(tests)
