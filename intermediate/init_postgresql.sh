TOOLCHAIN_DIR=/toolchain
POSTGRES_USER=postgres

mkdir $TOOLCHAIN_DIR/usr/local
mkdir $TOOLCHAIN_DIR/usr/local/pgsql
mkdir $TOOLCHAIN_DIR/usr/local/pgsql/data

useradd -p 1234 -m $POSTGRES_USER
chown postgres $TOOLCHAIN_DIR/usr/local/pgsql/data

su -c '$TOOLCHAIN_DIR/usr/bin/initdb -D $TOOLCHAIN_DIR/usr/local/pgsql/data' $POSTGRES_USER
su -c 'cd ~ && $TOOLCHAIN_DIR/usr/bin/pg_ctl -D $TOOLCHAIN_DIR/usr/local/pgsql/data -l logfile start' $POSTGRES_USER