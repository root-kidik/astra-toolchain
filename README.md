# Toolchain

### How to install?
1. Copy from container `toolchain:userver` folder `/toolchain` to self machine to `/toolchain`
2. Run `/toolchain/init_postgresql.sh`
3. Add in cmake project `set(CMAKE_TOOLCHAIN_FILE /toolchain/Toolchain.cmake)`
*. Every run you must
    - `PATH='/toolchain/usr/bin:$PATH'`
    - `su -c 'cd ~ && /toolchain/usr/bin/pg_ctl -D /toolchain/usr/local/pgsql/data -l logfile start' postgres`

### Base
- [make 4.4](https://ftp.gnu.org/gnu/make/make-4.4.tar.gz)
- [bison 3.8](https://ftp.gnu.org/gnu/bison/bison-3.8.tar.gz)
- [binutils 2.24](https://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz)
- [cpython 3.12.5](https://github.com/python/cpython/archive/refs/tags/v3.12.5.tar.gz)
- [cmake 3.30.2](https://github.com/Kitware/CMake/archive/refs/tags/v3.30.2.tar.gz)
- [ninja 1.12.1](https://github.com/ninja-build/ninja/archive/refs/tags/v1.12.1.tar.gz)
- [linux 4.2](https://github.com/torvalds/linux/archive/refs/tags/v4.2.tar.gz)
- [gcc 14.2.0](https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.gz)
- [glibc 2.40](http://ftp.gnu.org/gnu/glibc/glibc-2.40.tar.gz)
- [openssl 3.3.1](https://github.com/openssl/openssl/archive/refs/tags/openssl-3.3.1.tar.gz)
- [curl 8.9.1](https://github.com/curl/curl/archive/refs/tags/curl-8_9_1.tar.gz)
- [zlib 1.3.1](https://github.com/madler/zlib/archive/refs/tags/v1.3.1.tar.gz)
- [libffi 3.4.6](https://github.com/libffi/libffi/archive/refs/tags/v3.4.6.tar.gz)
- [pkg config 0.29.2](https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz)
- [libxcrypt 4.4.36](https://github.com/besser82/libxcrypt/archive/refs/tags/v4.4.36.tar.gz)
- [autoconf 2.72](https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.gz)
- [automake 1.17](https://ftp.gnu.org/gnu/automake/automake-1.17.tar.gz)
- [libtool 2.4](https://ftp.gnu.org/gnu/libtool/libtool-2.4.tar.gz)

### Intermediate
- [googletest 1.15.2](https://github.com/google/googletest/archive/refs/tags/v1.15.2.tar.gz)
- [benchmark 1.9.0](https://github.com/google/benchmark/archive/refs/tags/v1.9.0.tar.gz)
- [grpc 1.65.5](https://github.com/grpc/grpc/archive/refs/tags/v1.65.5.tar.gz)
- [boost 1.85.0](https://github.com/boostorg/boost/releases/download/boost-1.85.0/boost-1.85.0-cmake.tar.gz)
- [cryptopp 8.9.0](https://github.com/abdes/cryptopp-cmake/archive/refs/tags/CRYPTOPP_8_9_0.tar.gz)
- [yaml-cpp 0.8.0](https://github.com/jbeder/yaml-cpp/archive/refs/tags/0.8.0.tar.gz)
- [fmt 8.1.1](https://github.com/fmtlib/fmt/archive/refs/tags/8.1.1.tar.gz)
- [cctz 2.4](https://github.com/google/cctz/archive/refs/tags/v2.4.tar.gz)
- [nghttp2 v1.62.1](https://github.com/nghttp2/nghttp2/archive/refs/tags/v1.62.1.tar.gz)
- [libev 4.33](http://dist.schmorp.de/libev/libev-4.33.tar.gz)
- [jemalloc 5.3.0](https://github.com/jemalloc/jemalloc/archive/refs/tags/5.3.0.tar.gz)
- [zstd 1.5.6](https://github.com/facebook/zstd/releases/tag/v1.5.6)
- [c-ares 1.33.0](https://github.com/c-ares/c-ares/archive/refs/tags/v1.33.0.tar.gz)
- [postgresql 16.4](https://ftp.postgresql.org/pub/source/v16.4/postgresql-16.4.tar.gz)
- [openldap 2.5.18](https://github.com/openldap/openldap/archive/refs/tags/OPENLDAP_REL_ENG_2_5_18.tar.gz)
- [krb5 1.21.3](https://github.com/krb5/krb5/archive/refs/tags/krb5-1.21.3-final.tar.gz)

### Userver
- [userver](https://github.com/userver-framework/userver.git)
- [api common protos 1.50.0](https://github.com/googleapis/api-common-protos/archive/refs/tags/1.50.0.tar.gz)
- [opentelemetry proto 1.3.2](https://github.com/open-telemetry/opentelemetry-proto/archive/refs/tags/v1.3.2.tar.gz)