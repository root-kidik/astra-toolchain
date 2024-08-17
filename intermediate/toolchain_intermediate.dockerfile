FROM toolchain:base

ENV NPROC=8
ENV TOOLCHAIN_DIR=/toolchain
ENV PATH="$TOOLCHAIN_DIR/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:"
ENV TOOLCHAIN_LDFLAGS="--sysroot=$TOOLCHAIN_DIR -O2 -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib64 -Wl,--dynamic-linker=$TOOLCHAIN_DIR/usr/lib/ld-linux-x86-64.so.2"
ENV TOOLCHAIN_CFLAGS="$TOOLCHAIN_LDFLAGS"
ENV TOOLCHAIN_CXXFLAGS="$TOOLCHAIN_CFLAGS -std=c++23"
ENV TOOLCHAIN_CC="$TOOLCHAIN_DIR/usr/bin/gcc"
ENV TOOLCHAIN_CXX="$TOOLCHAIN_DIR/usr/bin/g++"

ENV JEMALLOC_SOURCE_DIR=/jemalloc
COPY $JEMALLOC_SOURCE_DIR $JEMALLOC_SOURCE_DIR
RUN cd $JEMALLOC_SOURCE_DIR && \
    CC="$TOOLCHAIN_CC" \
    CXX="$TOOLCHAIN_CXX" \
    CFLAGS="$TOOLCHAIN_CFLAGS" \
    CXXFLAGS="$TOOLCHAIN_CXXFLAGS" \
    LDFLAGS="$TOOLCHAIN_LDFLAGS" \
    $JEMALLOC_SOURCE_DIR/autogen.sh --enable-static=yes --enable-shared=no --prefix=$TOOLCHAIN_DIR/usr && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $JEMALLOC_SOURCE_DIR

ENV ZSTD_SOURCE_DIR=/zstd
ENV ZSTD_BUILD_DIR=$ZSTD_SOURCE_DIR-build
COPY $ZSTD_SOURCE_DIR $ZSTD_SOURCE_DIR
RUN mkdir $ZSTD_BUILD_DIR && cd $ZSTD_BUILD_DIR && \
    cmake -S $ZSTD_SOURCE_DIR/build/cmake -B . \
	-DZSTD_BUILD_STATIC=ON \
        -DZSTD_BUILD_SHARED=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -GNinja && \
    cmake --build . && cmake --install . && \
    cd .. && rm -rf $ZSTD_SOURCE_DIR $ZSTD_BUILD_DIR

ENV BOOST_SOURCE_DIR=/boost
ENV BOOST_BUILD_DIR=$BOOST_SOURCE_DIR-build
COPY $BOOST_SOURCE_DIR $BOOST_SOURCE_DIR
RUN mkdir $BOOST_BUILD_DIR && cd $BOOST_BUILD_DIR && \
    cmake -S $BOOST_SOURCE_DIR -B . \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -GNinja && \
    cmake --build . && cmake --install . && \
    cd .. && rm -rf $BOOST_SOURCE_DIR $BOOST_BUILD_DIR

ENV CRYPTOPP_SOURCE_DIR=/cryptopp-cmake
ENV CRYPTOPP_BUILD_DIR=$CRYPTOPP_SOURCE_DIR-build
COPY $CRYPTOPP_SOURCE_DIR $CRYPTOPP_SOURCE_DIR
RUN mkdir $CRYPTOPP_BUILD_DIR && cd $CRYPTOPP_BUILD_DIR && \
    cmake -S $CRYPTOPP_SOURCE_DIR -B . \
        -DCRYPTOPP_BUILD_TESTING=OFF \
        -DCRYPTOPP_USE_INTERMEDIATE_OBJECTS_TARGET=OFF \
        -DCRYPTOPP_USE_OPENMP=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -GNinja && \
    cmake --build . && cmake --install . && \
    cd .. && rm -rf $CRYPTOPP_SOURCE_DIR $CRYPTOPP_BUILD_DIR

ENV YAMLCPP_SOURCE_DIR=/yaml-cpp
ENV YAMLCPP_BUILD_DIR=$YAMLCPP_SOURCE_DIR-build
COPY $YAMLCPP_SOURCE_DIR $YAMLCPP_SOURCE_DIR
RUN mkdir $YAMLCPP_BUILD_DIR && cd $YAMLCPP_BUILD_DIR && \
    cmake -S $YAMLCPP_SOURCE_DIR -B . \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -GNinja && \
    cmake --build . && cmake --install . && \
    cd .. && rm -rf $YAMLCPP_SOURCE_DIR $YAMLCPP_BUILD_DIR

ENV FMT_SOURCE_DIR=/fmt
ENV FMT_BUILD_DIR=$FMT_SOURCE_DIR-build
COPY $FMT_SOURCE_DIR $FMT_SOURCE_DIR
RUN mkdir $FMT_BUILD_DIR && cd $FMT_BUILD_DIR && \
    cmake -S $FMT_SOURCE_DIR -B . \
        -DFMT_TEST=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -GNinja && \
    cmake --build . && cmake --install . && \
    cd .. && rm -rf $FMT_SOURCE_DIR $FMT_BUILD_DIR

ENV CCTZ_SOURCE_DIR=/cctz
ENV CCTZ_BUILD_DIR=$CCTZ_SOURCE_DIR-build
COPY $CCTZ_SOURCE_DIR $CCTZ_SOURCE_DIR
RUN mkdir $CCTZ_BUILD_DIR && cd $CCTZ_BUILD_DIR && \
    cmake -S $CCTZ_SOURCE_DIR -B . \
        -DBUILD_TOOLS=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_TESTING=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -GNinja && \
    cmake --build . && cmake --install . && \
    cd .. && rm -rf $CCTZ_SOURCE_DIR $CCTZ_BUILD_DIR

ENV GOOGLETEST_SOURCE_DIR=/googletest
ENV GOOGLETEST_BUILD_DIR=$GOOGLETEST_SOURCE_DIR-build
COPY $GOOGLETEST_SOURCE_DIR $GOOGLETEST_SOURCE_DIR
RUN mkdir $GOOGLETEST_BUILD_DIR && cd $GOOGLETEST_BUILD_DIR && \
    cmake -S $GOOGLETEST_SOURCE_DIR -B . \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -GNinja && \
    cmake --build . && cmake --install . && \
    cd .. && rm -rf $GOOGLETEST_SOURCE_DIR $GOOGLETEST_BUILD_DIR

ENV BENCHMARK_SOURCE_DIR=/benchmark
ENV BENCHMARK_BUILD_DIR=$BENCHMARK_SOURCE_DIR-build
COPY $BENCHMARK_SOURCE_DIR $BENCHMARK_SOURCE_DIR
RUN mkdir $BENCHMARK_BUILD_DIR && cd $BENCHMARK_BUILD_DIR && \
    cmake -S $BENCHMARK_SOURCE_DIR -B . \
        -DBENCHMARK_USE_BUNDLED_GTEST=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -GNinja && \
    cmake --build . && cmake --install . && \
    cd .. && rm -rf $BENCHMARK_SOURCE_DIR $BENCHMARK_BUILD_DIR

ENV NGHTTP2_SOURCE_DIR=/nghttp2
ENV NGHTTP2_BUILD_DIR=$NGHTTP2_SOURCE_DIR-build
COPY $NGHTTP2_SOURCE_DIR $NGHTTP2_SOURCE_DIR
RUN mkdir $NGHTTP2_BUILD_DIR && cd $NGHTTP2_BUILD_DIR && \
    cmake -S $NGHTTP2_SOURCE_DIR -B . \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_STATIC_LIBS=ON \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_DOC=OFF \
        -DENABLE_FAILMALLOC=OFF \
        -DBUILD_TESTING=OFF \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -GNinja && \
    cmake --build . && cmake --install . && \
    cd .. && rm -rf $NGHTTP2_SOURCE_DIR $NGHTTP2_BUILD_DIR

ENV LIBEV_SOURCE_DIR=/libev
ENV LIBEV_BUILD_DIR=$LIBEV_SOURCE_DIR-build
COPY $LIBEV_SOURCE_DIR $LIBEV_SOURCE_DIR
RUN mkdir $LIBEV_BUILD_DIR && cd $LIBEV_BUILD_DIR && \
    $LIBEV_SOURCE_DIR/configure \
        CC="$TOOLCHAIN_CC" \
        CXX="$TOOLCHAIN_CXX" \
        CFLAGS="$TOOLCHAIN_CFLAGS" \
        CXXFLAGS="$TOOLCHAIN_CXXFLAGS" \
        LDFLAGS="$TOOLCHAIN_LDFLAGS" \
        --with-sysroot=$TOOLCHAIN_DIR \
        --enable-static=yes \
        --enable-shared=no \
        --prefix=$TOOLCHAIN_DIR/usr && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $LIBEV_SOURCE_DIR $LIBEV_BUILD_DIR

ENV CARES_SOURCE_DIR=/c-ares
ENV CARES_BUILD_DIR=$CARES_SOURCE_DIR-build
COPY $CARES_SOURCE_DIR $CARES_SOURCE_DIR
RUN mkdir $CARES_BUILD_DIR && cd $CARES_BUILD_DIR && \
    cmake -S $CARES_SOURCE_DIR -B . \
        -DCARES_STATIC=ON \
        -DCARES_SHARED=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -GNinja && \
    cmake --build . && cmake --install . && \
    cd .. && rm -rf $CARES_SOURCE_DIR $CARES_BUILD_DIR

ENV GRPC_SOURCE_DIR=/grpc
ENV GRPC_BUILD_DIR=$GRPC_SOURCE_DIR-build
COPY $GRPC_SOURCE_DIR $GRPC_SOURCE_DIR
RUN mkdir $GRPC_BUILD_DIR && cd $GRPC_BUILD_DIR && \
    cmake -B . -S $GRPC_SOURCE_DIR \
	    -Dprotobuf_BUILD_SHARED_LIBS=OFF \
        -DgRPC_BUILD_TESTS=OFF \
        -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
        -DgRPC_CARES_PROVIDER=package \
        -DgRPC_SSL_PROVIDER=package \
        -DgRPC_ZLIB_PROVIDER=package \
        -DgRPC_BENCHMARK_PROVIDER=package \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -GNinja && \
    cmake --build . && cmake --install . && \
    cd .. && rm -rf $GRPC_SOURCE_DIR $GRPC_BUILD_DIR

FROM dockerhub.lemz.t/library/astralinux:se1.5
COPY --from=0 $TOOLCHAIN_DIR $TOOLCHAIN_DIR