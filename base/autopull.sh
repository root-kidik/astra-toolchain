. ../autopull_base.sh

download_from_ftp_gnu make 4.4
download_from_ftp_gnu bison 3.8
download_from_ftp_gnu binutils 2.43
download_from_ftp_gnu autoconf 2.72
download_from_ftp_gnu automake 1.17
download_from_ftp_gnu libtool 2.4
download_from_ftp_gnu gcc 14.2.0 https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.gz
download_from_ftp_gnu glibc 2.40

download_from_github_archive_by_tag Kitware CMake v3.30.2
download_from_github_archive_by_tag python cpython v3.12.5
download_from_github_archive_by_tag ninja-build ninja v1.12.1
download_from_github_archive_by_tag curl curl curl-8_9_1
download_from_github_archive_by_tag torvalds linux v4.2
download_from_github_archive_by_tag libffi libffi v3.4.6
download_from_github_archive_by_tag madler zlib v1.3.1
download_from_github_archive_by_tag openssl openssl openssl-3.3.1
download_from_github_archive_by_tag besser82 libxcrypt v4.4.36

download_wget pkgconfig pkg-config-0.29.2 https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz

cd ./gcc && ./contrib/download_prerequisites