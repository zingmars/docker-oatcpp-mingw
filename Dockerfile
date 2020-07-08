FROM debian:sid-slim
RUN apt update && apt install git gcc g++ build-essential cmake mingw-w64 -y && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/oatpp/oatpp.git && cd /oatpp
# Make mingw use posix threads
RUN update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix
# Work around oat++ using varying case for some include files
RUN cd /usr/x86_64-w64-mingw32/include && ln -s winsock2.h Winsock2.h &&  ln -s winsock2.h WinSock2.h && ln -s ws2tcpip.h WS2tcpip.h
# Make oat++ use mingw
RUN sed -i '/Print config/i set(CMAKE_SYSTEM_NAME Windows)\nset(TOOLCHAIN_PREFIX x86_64-w64-mingw32)\nset(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)\nset(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)\nset(CMAKE_FIND_ROOT_PATH /usr/${TOOLCHAIN_PREFIX})\nset(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)\nset(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)\nset(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)\nset(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DWINVER=0x0601 -D_WIN32_WINNT=0x0601 -DNTDDI_VERSION=0x06010000")' /oatpp/CMakeLists.txt
# Make oat++ to link with winsock libraries. For some reason cmake won't trigger the MINGW variable on Linux.
RUN sed -i '/OATPP_ADD_LINK_LIBS=${OATPP_ADD_LINK_LIBS}/i SET(OATPP_ADD_LINK_LIBS "${OATPP_ADD_LINK_LIBS} -lwsock32 -lws2_32")' /oatpp/src/CMakeLists.txt
# Build and install
RUN cd /oatpp && mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DOATPP_BUILD_TESTS=OFF .. && make -j$(nproc) && make install && cd ../.. && rm -rf oatpp
