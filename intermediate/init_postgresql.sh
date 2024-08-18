TOOLCHAIN_DIR=/toolchain

mkdir $TOOLCHAIN_DIR/usr/local
mkdir $TOOLCHAIN_DIR/usr/local/pgsql
mkdir $TOOLCHAIN_DIR/usr/local/pgsql/data
adduser postgres
chown postgres $TOOLCHAIN_DIR/usr/local/pgsql/data
su - postgres

TOOLCHAIN_DIR=/toolchain

$TOOLCHAIN_DIR/usr/bin/initdb -D $TOOLCHAIN_DIR/usr/local/pgsql/data
$TOOLCHAIN_DIR/usr/bin/pg_ctl -D $TOOLCHAIN_DIR/usr/local/pgsql/data -l logfile start
$TOOLCHAIN_DIR/usr/bin/createdb test