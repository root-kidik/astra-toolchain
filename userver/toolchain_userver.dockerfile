FROM toolchain:intermediate

ENV NPROC=8
ENV TOOLCHAIN_DIR=/toolchain
ENV PATH="$TOOLCHAIN_DIR/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:"
ENV TOOLCHAIN_LDFLAGS="--sysroot=$TOOLCHAIN_DIR -O2 -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib64 -Wl,--dynamic-linker=$TOOLCHAIN_DIR/usr/lib/ld-linux-x86-64.so.2"
ENV TOOLCHAIN_CFLAGS="$TOOLCHAIN_LDFLAGS"
ENV TOOLCHAIN_CXXFLAGS="$TOOLCHAIN_CFLAGS -std=c++23"
ENV TOOLCHAIN_CC="$TOOLCHAIN_DIR/usr/bin/gcc"
ENV TOOLCHAIN_CXX="$TOOLCHAIN_DIR/usr/bin/g++"

ENV APICOMMONPROTOS_SOURCE_DIR=/api-common-protos
COPY $APICOMMONPROTOS_SOURCE_DIR $APICOMMONPROTOS_SOURCE_DIR

ENV OPENTELEMETRY_PROTO_SOURCE_DIR=/opentelemetry-proto
COPY $OPENTELEMETRY_PROTO_SOURCE_DIR $OPENTELEMETRY_PROTO_SOURCE_DIR

# userver
ENV USERVER_SOURCE_DIR=/userver
COPY $USERVER_SOURCE_DIR $USERVER_SOURCE_DIR
RUN python3 -m pip install setuptools Jinja2 requests websockets voluptuous pytest_asyncio==0.21.2 zstd yandex-taxi-testsuite PyYaml uvloop grpcio grpcio-tools && \
    cd $USERVER_SOURCE_DIR && \
    cmake -S . -B build_release \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -DUSERVER_INSTALL=ON \
        -DUSERVER_FEATURE_GRPC=ON \
        -DUSERVER_FEATURE_OTLP=ON \
        -DUSERVER_DISABLE_PHDR_CACHE=ON \
        -DUSERVER_CHECK_PACKAGE_VERSIONS=OFF \
        -DUSERVER_PIP_USE_SYSTEM_PACKAGES=ON \
        -DUSERVER_PIP_OPTIONS='--no-index' \
        -DUSERVER_GOOGLE_COMMON_PROTOS=$APICOMMONPROTOS_SOURCE_DIR \
        -DUSERVER_OPENTELEMETRY_PROTO=$OPENTELEMETRY_PROTO_SOURCE_DIR \
        -GNinja && \
    cmake -S . -B build_debug \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -DUSERVER_INSTALL=ON \
        -DUSERVER_FEATURE_GRPC=ON \
        -DUSERVER_FEATURE_OTLP=ON \
        -DUSERVER_DISABLE_PHDR_CACHE=ON \
        -DUSERVER_CHECK_PACKAGE_VERSIONS=OFF \
        -DUSERVER_PIP_USE_SYSTEM_PACKAGES=ON \
        -DUSERVER_PIP_OPTIONS='--no-index' \
        -DUSERVER_GOOGLE_COMMON_PROTOS=$APICOMMONPROTOS_SOURCE_DIR \
        -DUSERVER_OPENTELEMETRY_PROTO=$OPENTELEMETRY_PROTO_SOURCE_DIR \
        -DUSERVER_SANITIZE="ub addr" \
        -GNinja && \
    cmake --build build_release && cmake --install build_release && \
    cmake --build build_debug && cmake --install build_debug && \
    cd .. && rm -rf $USERVER_SOURCE_DIR $USERVER_BUILD_DIR $APICOMMONPROTOS_SOURCE_DIR $OPENTELEMETRY_PROTO_SOURCE_DIR

FROM dockerhub.lemz.t/library/astralinux:se1.5
COPY --from=0 $TOOLCHAIN_DIR $TOOLCHAIN_DIR