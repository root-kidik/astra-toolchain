download_wrapper() {
    PACKAGE=$1
    PACKAGE_DIR_TAR=$2
    URL=$3

    mkdir $PACKAGE
    wget -O $PACKAGE_DIR_TAR $URL
    tar -zxvf $PACKAGE_DIR_TAR -C $PACKAGE --strip-components 1
    rm -rf $PACKAGE_DIR_TAR
}

download_from_ftp_gnu () {
    if [ -d "$1" ]; then
        return
    fi

    PACKAGE=$1
    TAG=$2
    PACKAGE_DIR_TAR=$PACKAGE-$TAG.tar.gz

    if [ -z "$3" ]; then
        URL=https://ftp.gnu.org/gnu/$PACKAGE/$PACKAGE_DIR_TAR
    else
        URL=$3
    fi
    
    echo $URL
    download_wrapper $PACKAGE $PACKAGE_DIR_TAR $URL
}

download_from_github_archive_by_tag () {
    if [ -d "$2" ]; then
        return
    fi

    REPO=$1
    PACKAGE=$2
    TAG=$3
    PACKAGE_DIR_TAR=$TAG.tar.gz
    URL=https://github.com/$REPO/$PACKAGE/archive/refs/tags/$PACKAGE_DIR_TAR

    download_wrapper $PACKAGE $PACKAGE_DIR_TAR $URL
}

download_wget() {
    if [ -d "$1" ]; then
        return
    fi

    PACKAGE=$1
    PACKAGE_DIR=$2
    PACKAGE_DIR_TAR=$PACKAGE_DIR.tar.gz
    URL=$3

    download_wrapper $PACKAGE $PACKAGE_DIR_TAR $URL
}

download_from_github() {
    if [ -d "$2" ]; then
        return
    fi

    REPO=$1
    PACKAGE=$2
    git clone https://github.com/$REPO/$PACKAGE.git
    cd $PACKAGE && git submodule update --init --recursive && cd -
}

download_from_github_by_tag() {
    if [ -d "$2" ]; then
        return
    fi

    REPO=$1
    PACKAGE=$2
    TAG=$3
    git clone --depth 1 --branch $TAG https://github.com/$REPO/$PACKAGE.git
    cd $PACKAGE && git submodule update --init --recursive && cd -
}