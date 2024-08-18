TOOLCHAIN_DIR=/toolchain
POSTGRES_USER=postgres

mkdir $TOOLCHAIN_DIR/usr/local
mkdir $TOOLCHAIN_DIR/usr/local/pgsql
mkdir $TOOLCHAIN_DIR/usr/local/pgsql/data

useradd -p 1234 -m $POSTGRES_USER
chown postgres $TOOLCHAIN_DIR/usr/local/pgsql/data

su -c '/toolchain/usr/bin/initdb -D /toolchain/usr/local/pgsql/data' $POSTGRES_USER