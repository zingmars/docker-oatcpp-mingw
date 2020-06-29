Docker oatcpp mingw
===

This repository is used to generate an image that contains the [oatcpp](https://github.com/oatpp/oatpp) library compiled for use with mingw64 for cross-compiling Windows executables.

Build with: `docker build -t zingmars/docker-oatcpp-mingw .`

NOTE: This should only be used for testing. Because mingw uses pthreads the performance will suffer. Use MSVC for release builds instead.
