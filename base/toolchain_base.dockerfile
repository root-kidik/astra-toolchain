FROM dockerhub.lemz.t/library/astralinux:se1.5-gcc8.3.0

ENV TOOLCHAIN_TEMP_DIR=/toolchain-temp
ENV TOOLCHAIN_DIR=/toolchain

ENV NPROC=16

ENV PATH=$TOOLCHAIN_TEMP_DIR/usr/bin:$PATH

RUN apt-get update && apt-get install -y gawk bison texinfo flex zlib1g-dev realpath pkg-config

ENV MAKE_SOURCE_DIR=/make
ENV MAKE_BUILD_DIR=$MAKE_SOURCE_DIR-build
COPY $MAKE_SOURCE_DIR $MAKE_SOURCE_DIR
RUN mkdir $MAKE_BUILD_DIR && cd $MAKE_BUILD_DIR && \
    $MAKE_SOURCE_DIR/configure --prefix=$TOOLCHAIN_TEMP_DIR/usr && \
    make -j$NPROC && make install && \
    rm -rf *

ENV BISON_SOURCE_DIR=/bison
ENV BISON_BUILD_DIR=$BISON_SOURCE_DIR-build
COPY $BISON_SOURCE_DIR $BISON_SOURCE_DIR
RUN mkdir $BISON_BUILD_DIR && cd $BISON_BUILD_DIR && \
    $BISON_SOURCE_DIR/configure --prefix=$TOOLCHAIN_TEMP_DIR/usr && \
    make -j$NPROC && make install && \
    rm -rf *

ENV PYTHON_SOURCE_DIR=/cpython
ENV PYTHON_BUILD_DIR=$PYTHON_SOURCE_DIR-build
COPY $PYTHON_SOURCE_DIR $PYTHON_SOURCE_DIR
RUN mkdir $PYTHON_BUILD_DIR && cd $PYTHON_BUILD_DIR && \
    $PYTHON_SOURCE_DIR/configure --prefix=$TOOLCHAIN_TEMP_DIR/usr && \
    make -j$NPROC && make install && \
    rm -rf *

ENV BINUTILS_SOURCE_DIR=/binutils
ENV BINUTILS_BUILD_DIR=$BINUTILS_SOURCE_DIR-build
COPY $BINUTILS_SOURCE_DIR $BINUTILS_SOURCE_DIR
RUN mkdir $BINUTILS_BUILD_DIR && cd $BINUTILS_BUILD_DIR && \
    $BINUTILS_SOURCE_DIR/configure \
       --prefix=$TOOLCHAIN_TEMP_DIR/usr \
       --with-sysroot=$TOOLCHAIN_TEMP_DIR \
       --disable-multilib && \
    make -j$NPROC && make install && \
    rm -rf *

ENV LINUX_SOURCE_DIR=/linux
COPY $LINUX_SOURCE_DIR $LINUX_SOURCE_DIR
RUN cd $LINUX_SOURCE_DIR && \
    make INSTALL_HDR_PATH=$TOOLCHAIN_TEMP_DIR/usr headers_install

ENV GCC_VERSION=14.2.0
ENV GCC_SOURCE_DIR=/gcc
ENV GCC_BUILD_DIR=$GCC_SOURCE_DIR-build
COPY $GCC_SOURCE_DIR $GCC_SOURCE_DIR
RUN mkdir $GCC_BUILD_DIR && cd $GCC_BUILD_DIR && \
    $GCC_SOURCE_DIR/configure \
        --prefix=$TOOLCHAIN_TEMP_DIR \
		--with-build-time-tools=$TOOLCHAIN_TEMP_DIR/bin \
        --enable-languages=c,c++ \
        --disable-bootstrap \
        --disable-multilib \
        --disable-lto \
        --disable-nls && \
    make -j$NPROC all-gcc && make install-gcc

ENV GLIBC_SOURCE_DIR=/glibc
ENV GLIBC_BUILD_DIR=$GLIBC_SOURCE_DIR-build
COPY $GLIBC_SOURCE_DIR $GLIBC_SOURCE_DIR
RUN	mkdir $GLIBC_BUILD_DIR && cd $GLIBC_BUILD_DIR && \
    $GLIBC_SOURCE_DIR/configure \
		--prefix=/usr \
		--with-headers=$TOOLCHAIN_TEMP_DIR/usr/include \
		--with-binutils=$TOOLCHAIN_TEMP_DIR/bin \
		--disable-multilib && \
    make install_root=$TOOLCHAIN_TEMP_DIR install-bootstrap-headers=yes install-headers && \
	make -j$NPROC csu/subdir_lib && \
    install csu/crt1.o csu/crti.o csu/crtn.o $TOOLCHAIN_TEMP_DIR/usr/lib && \
	$TOOLCHAIN_TEMP_DIR/bin/x86_64-pc-linux-gnu-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $TOOLCHAIN_TEMP_DIR/usr/lib/libc.so && \
	touch $TOOLCHAIN_TEMP_DIR/usr/include/gnu/stubs.h

RUN cd $GCC_BUILD_DIR && \
	make -j$NPROC all-target-libgcc && \
	make install-target-libgcc

RUN cd $GLIBC_BUILD_DIR && \
    make -j$NPROC && \
    make install_root=$TOOLCHAIN_TEMP_DIR install && \
    rm -rf *

RUN cd $GCC_BUILD_DIR && \
	make -j$NPROC && make install && \
    rm -rf *

# === Production compiler build === #

ENV PATH=$TOOLCHAIN_TEMP_DIR/bin:$PATH

RUN cd $LINUX_SOURCE_DIR && make INSTALL_HDR_PATH=$TOOLCHAIN_DIR/usr headers_install && \
    cd .. && rm -rf $LINUX_SOURCE_DIR 

RUN cd $GLIBC_BUILD_DIR && \
    $GLIBC_SOURCE_DIR/configure \
        --prefix=/usr \
        --with-headers=$TOOLCHAIN_DIR/usr/include \
        --enable-static-nss \
        --disable-multilib \
        --disable-nscd \
        libc_cv_slibdir=/usr/lib && \
    make -j$NPROC && make install_root=$TOOLCHAIN_DIR install && \
    cd .. && rm -rf $GLIBC_SOURCE_DIR $GLIBC_BUILD_DIR

RUN sed '/RTLDLIST=/s@/usr@@g' -i $TOOLCHAIN_DIR/usr/bin/ldd

ENV PATH=$TOOLCHAIN_DIR/usr/bin:$PATH

RUN	cd $BINUTILS_BUILD_DIR && \
    $BINUTILS_SOURCE_DIR/configure \
        CFLAGS="-O2 -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib64 -Wl,--dynamic-linker=$TOOLCHAIN_DIR/usr/lib/ld-linux-x86-64.so.2" \
        LDFLAGS="-O2 -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib64 -Wl,--dynamic-linker=$TOOLCHAIN_DIR/usr/lib/ld-linux-x86-64.so.2" \
        --prefix=$TOOLCHAIN_DIR/usr \
        --with-build-sysroot=$TOOLCHAIN_DIR \
        --enable-gprofng=no \
        --disable-multilib \
        --disable-nls \
        --enable-default-hash-style=gnu && \
    make tooldir=/usr -j$NPROC && make tooldir=/usr install && \
    cd .. && rm -rf $BINUTILS_SOURCE_DIR $BINUTILS_BUILD_DIR

RUN cd $GCC_BUILD_DIR && \
    $GCC_SOURCE_DIR/configure \
        CFLAGS="-O2 -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib64 -Wl,--dynamic-linker=$TOOLCHAIN_DIR/usr/lib/ld-linux-x86-64.so.2" \
        CXXFLAGS="-O2 -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib64 -Wl,--dynamic-linker=$TOOLCHAIN_DIR/usr/lib/ld-linux-x86-64.so.2" \
        LDFLAGS="-O2 -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib64 -Wl,--dynamic-linker=$TOOLCHAIN_DIR/usr/lib/ld-linux-x86-64.so.2" \
        --prefix=$TOOLCHAIN_DIR/usr \
        --with-sysroot=$TOOLCHAIN_DIR \
        --with-build-sysroot=$TOOLCHAIN_DIR \
        --enable-languages=c,c++ \
        --disable-bootstrap \
        --disable-multilib \
        --disable-lto \
        --disable-nls && \
    make -j$NPROC && make install && \
    install -m644 $GCC_SOURCE_DIR/libbacktrace/backtrace.h $TOOLCHAIN_DIR/usr/lib/gcc/x86_64-pc-linux-gnu/$GCC_VERSION/include && \
    install -m644 libbacktrace/backtrace-supported.h $TOOLCHAIN_DIR/usr/lib/gcc/x86_64-pc-linux-gnu/$GCC_VERSION/include && \
    install -m644 libbacktrace/.libs/libbacktrace.a $TOOLCHAIN_DIR/usr/lib/gcc/x86_64-pc-linux-gnu/$GCC_VERSION && \
    cd .. && rm -rf $GCC_SOURCE_DIR $GCC_BUILD_DIR

RUN rm -rf $TOOLCHAIN_TEMP_DIR

# === Production tools build === #

ENV PATH="$TOOLCHAIN_DIR/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:"

ENV TOOLCHAIN_LDFLAGS="--sysroot=$TOOLCHAIN_DIR -O2 -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib -Wl,--rpath=$TOOLCHAIN_DIR/usr/lib64 -Wl,--dynamic-linker=$TOOLCHAIN_DIR/usr/lib/ld-linux-x86-64.so.2"
ENV TOOLCHAIN_CFLAGS="$TOOLCHAIN_LDFLAGS"
ENV TOOLCHAIN_CXXFLAGS="$TOOLCHAIN_CFLAGS -std=c++23"

ENV TOOLCHAIN_CC="$TOOLCHAIN_DIR/usr/bin/gcc"
ENV TOOLCHAIN_CXX="$TOOLCHAIN_DIR/usr/bin/g++"

RUN cd $MAKE_BUILD_DIR && \
    $MAKE_SOURCE_DIR/configure \
        CC="$TOOLCHAIN_CC" \
        CXX="$TOOLCHAIN_CXX" \
        CFLAGS="$TOOLCHAIN_CFLAGS" \
        CXXFLAGS="$TOOLCHAIN_CXXFLAGS" \
        LDFLAGS="$TOOLCHAIN_LDFLAGS" \
        --prefix=$TOOLCHAIN_DIR/usr && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $MAKE_SOURCE_DIR $MAKE_BUILD_DIR 

RUN cd $BISON_BUILD_DIR && \
    $BISON_SOURCE_DIR/configure \
        CC="$TOOLCHAIN_CC" \
        CXX="$TOOLCHAIN_CXX" \
        CFLAGS="$TOOLCHAIN_CFLAGS" \
        CXXFLAGS="$TOOLCHAIN_CXXFLAGS" \
        LDFLAGS="$TOOLCHAIN_LDFLAGS" \
        --prefix=$TOOLCHAIN_DIR/usr && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $BISON_SOURCE_DIR $BISON_BUILD_DIR

ENV PKGCONFIG_SOURCE_DIR=/pkgconfig
ENV PKGCONFIG_BUILD_DIR=$PKGCONFIG_SOURCE_DIR-build
COPY $PKGCONFIG_SOURCE_DIR $PKGCONFIG_SOURCE_DIR
RUN mkdir $PKGCONFIG_BUILD_DIR && cd $PKGCONFIG_BUILD_DIR && \
    $PKGCONFIG_SOURCE_DIR/configure \
        CC="$TOOLCHAIN_CC -fPIC" \
        CFLAGS="$TOOLCHAIN_CFLAGS -fPIC" \
        LDFLAGS="$TOOLCHAIN_LDFLAGS -fPIC" \
        --prefix=$TOOLCHAIN_DIR/usr \
        --enable-static=yes \
        --enable-shared=no \
        --with-internal-glib && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $PKGCONFIG_SOURCE_DIR $PKGCONFIG_BUILD_DIR

ENV ZLIB_SOURCE_DIR=/zlib
ENV ZLIB_BUILD_DIR=$ZLIB_SOURCE_DIR-build
COPY $ZLIB_SOURCE_DIR $ZLIB_SOURCE_DIR
RUN mkdir $ZLIB_BUILD_DIR && cd $ZLIB_BUILD_DIR && \
    export CC="$TOOLCHAIN_CC -fPIC" && \
    export CFLAGS="$TOOLCHAIN_CFLAGS -fPIC" && \
    export LDFLAGS="$TOOLCHAIN_LDFLAGS -fPIC" && \  
    $ZLIB_SOURCE_DIR/configure \
        --static \
        --prefix=$TOOLCHAIN_DIR/usr && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $ZLIB_SOURCE_DIR $ZLIB_BUILD_DIR

ENV OPENSSL_SOURCE_DIR=/openssl
ENV OPENSSL_BUILD_DIR=$OPENSSL_SOURCE_DIR-build
COPY $OPENSSL_SOURCE_DIR $OPENSSL_SOURCE_DIR
RUN mkdir $OPENSSL_BUILD_DIR && cd $OPENSSL_BUILD_DIR && \
    $OPENSSL_SOURCE_DIR/config \
        CC="$TOOLCHAIN_CC" \
        CXX="$TOOLCHAIN_CXX" \
        CFLAGS="$TOOLCHAIN_CFLAGS" \
        CXXFLAGS="$TOOLCHAIN_CXXFLAGS" \
        LDFLAGS="$TOOLCHAIN_LDFLAGS" \
        --prefix=$TOOLCHAIN_DIR/usr \
        no-shared && \
    make -j$NPROC && make install_sw && \
    cd .. && rm -rf $OPENSSL_SOURCE_DIR $OPENSSL_BUILD_DIR

ENV AUTOCONF_SOURCE_DIR=/autoconf
ENV AUTOCONF_BUILD_DIR=$AUTOCONF_SOURCE_DIR-build
COPY $AUTOCONF_SOURCE_DIR $AUTOCONF_SOURCE_DIR
RUN mkdir $AUTOCONF_BUILD_DIR && cd $AUTOCONF_BUILD_DIR && \
    $AUTOCONF_SOURCE_DIR/configure \
        CC="$TOOLCHAIN_CC" \
        CXX="$TOOLCHAIN_CXX" \
        CFLAGS="$TOOLCHAIN_CFLAGS" \
        CXXFLAGS="$TOOLCHAIN_CXXFLAGS" \
        LDFLAGS="$TOOLCHAIN_LDFLAGS" \
        --prefix=$TOOLCHAIN_DIR/usr && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $AUTOCONF_SOURCE_DIR $AUTOCONF_BUILD_DIR

ENV AUTOMAKE_SOURCE_DIR=/automake
ENV AUTOMAKE_BUILD_DIR=$AUTOMAKE_SOURCE_DIR-build
COPY $AUTOMAKE_SOURCE_DIR $AUTOMAKE_SOURCE_DIR
RUN mkdir $AUTOMAKE_BUILD_DIR && cd $AUTOMAKE_BUILD_DIR && \
    $AUTOMAKE_SOURCE_DIR/configure \
        CC="$TOOLCHAIN_CC" \
        CXX="$TOOLCHAIN_CXX" \
        CFLAGS="$TOOLCHAIN_CFLAGS" \
        CXXFLAGS="$TOOLCHAIN_CXXFLAGS" \
        LDFLAGS="$TOOLCHAIN_LDFLAGS" \
        --prefix=$TOOLCHAIN_DIR/usr && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $AUTOMAKE_SOURCE_DIR $AUTOMAKE_BUILD_DIR

ENV LIBTOOL_SOURCE_DIR=/libtool
ENV LIBTOOL_BUILD_DIR=$LIBTOOL_SOURCE_DIR-build
COPY $LIBTOOL_SOURCE_DIR $LIBTOOL_SOURCE_DIR
RUN mkdir $LIBTOOL_BUILD_DIR && cd $LIBTOOL_BUILD_DIR && \
    $LIBTOOL_SOURCE_DIR/configure \
        CC="$TOOLCHAIN_CC" \
        CXX="$TOOLCHAIN_CXX" \
        CFLAGS="$TOOLCHAIN_CFLAGS" \
        CXXFLAGS="$TOOLCHAIN_CXXFLAGS" \
        LDFLAGS="$TOOLCHAIN_LDFLAGS" \
        --prefix=$TOOLCHAIN_DIR/usr && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $LIBTOOL_SOURCE_DIR $LIBTOOL_BUILD_DIR

ENV LIBFFI_SOURCE_DIR=/libffi
ENV LIBFFI_BUILD_DIR=$LIBFFI_SOURCE_DIR-build
COPY $LIBFFI_SOURCE_DIR $LIBFFI_SOURCE_DIR
RUN cd $LIBFFI_SOURCE_DIR && ./autogen.sh && \
    mkdir $LIBFFI_BUILD_DIR && cd $LIBFFI_BUILD_DIR && \
    $LIBFFI_SOURCE_DIR/configure \
        CC="$TOOLCHAIN_CC" \
        CXX="$TOOLCHAIN_CXX" \
        CFLAGS="$TOOLCHAIN_CFLAGS" \
        CXXFLAGS="$TOOLCHAIN_CXXFLAGS" \
        LDFLAGS="$TOOLCHAIN_LDFLAGS" \
        --prefix=$TOOLCHAIN_DIR/usr && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $LIBFFI_SOURCE_DIR $LIBFFI_BUILD_DIR

ENV CMAKE_SOURCE_DIR=/CMake
ENV CMAKE_BUILD_DIR=$CMAKE_SOURCE_DIR-build
COPY $CMAKE_SOURCE_DIR $CMAKE_SOURCE_DIR
RUN mkdir $CMAKE_BUILD_DIR && cd $CMAKE_BUILD_DIR && \
    $CMAKE_SOURCE_DIR/bootstrap \
        CC="$TOOLCHAIN_CC" \
        CXX="$TOOLCHAIN_CXX" \
        CFLAGS="$TOOLCHAIN_CFLAGS" \
        CXXFLAGS="$TOOLCHAIN_CXXFLAGS" \
        LDFLAGS="$TOOLCHAIN_LDFLAGS" \
        --prefix=$TOOLCHAIN_DIR/usr \
        --parallel=$NPROC && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $CMAKE_SOURCE_DIR $CMAKE_BUILD_DIR

COPY Toolchain.cmake $TOOLCHAIN_DIR/Toolchain.cmake

ENV NINJA_SOURCE_DIR=/ninja
ENV NINJA_BUILD_DIR=$NINJA_SOURCE_DIR-build
COPY $NINJA_SOURCE_DIR $NINJA_SOURCE_DIR
RUN mkdir $NINJA_BUILD_DIR && cd $NINJA_BUILD_DIR && \
    cmake -B . -S $NINJA_SOURCE_DIR \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake && \
    cmake --build . --parallel $NPROC && cmake --install . && \
    cd .. && rm -rf $NINJA_SOURCE_DIR $NINJA_BUILD_DIR 

ENV CURL_SOURCE_DIR=/curl
ENV CURL_BUILD_DIR=$CURL_SOURCE_DIR-build
COPY $CURL_SOURCE_DIR $CURL_SOURCE_DIR
RUN mkdir $CURL_BUILD_DIR && cd $CURL_BUILD_DIR && \
    cmake -B . -S $CURL_SOURCE_DIR \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_STATIC_LIBS=ON \
        -DBUILD_STATIC_CURL=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_DIR/usr \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_DIR/Toolchain.cmake \
        -GNinja && \
    cmake --build . && cmake --install . && \
    cd .. && rm -rf $CURL_SOURCE_DIR $CURL_BUILD_DIR

ENV CRYPTX_SOURCE_DIR=/libxcrypt
ENV CRYPTX_BUILD_DIR=$CRYPTX_SOURCE_DIR-build
COPY $CRYPTX_SOURCE_DIR $CRYPTX_SOURCE_DIR
RUN cd $CRYPTX_SOURCE_DIR && ./autogen.sh && \
    mkdir $CRYPTX_BUILD_DIR && cd $CRYPTX_BUILD_DIR && \
    $CRYPTX_SOURCE_DIR/configure \
        CC="$TOOLCHAIN_CC -fPIC" \
        CFLAGS="$TOOLCHAIN_CFLAGS -fPIC" \
        LDFLAGS="$TOOLCHAIN_LDFLAGS -fPIC" \
        --enable-static=yes \
        --enable-shared=no \
        --prefix=$TOOLCHAIN_DIR/usr && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $CRYPTX_SOURCE_DIR $CRYPTX_BUILD_DIR

RUN cd $PYTHON_BUILD_DIR && \
    $PYTHON_SOURCE_DIR/configure \
        CC="$TOOLCHAIN_CC" \
        CXX="$TOOLCHAIN_CXX" \
        CFLAGS="$TOOLCHAIN_CFLAGS" \
        CXXFLAGS="$TOOLCHAIN_CXXFLAGS" \
        LDFLAGS="$TOOLCHAIN_LDFLAGS" \
        --prefix=$TOOLCHAIN_DIR/usr \
        --with-openssl=$TOOLCHAIN_DIR/usr && \
    make -j$NPROC && make install && \
    cd .. && rm -rf $PYTHON_SOURCE_DIR $PYTHON_BUILD_DIR

FROM dockerhub.lemz.t/library/astralinux:se1.5
COPY --from=0 $TOOLCHAIN_DIR $TOOLCHAIN_DIR