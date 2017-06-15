#!/bin/sh

# Installing FRR on Debian from scratch

apt-get update
apt-get install -y git autoconf automake libtool make gawk \
   libreadline-dev texinfo libjson-c-dev pkg-config bison flex \
   python-pip libc-ares-dev python3-dev
pip install pytest 
addgroup --system --gid 92 frr
addgroup --system --gid 85 frrvty
adduser --system --ingroup frr --home /var/run/frr/ --gecos "FRR suite" --shell /bin/false frr
usermod -a -G frrvty frr
wget https://github.com/FRRouting/frr/archive/frr-2.0.tar.gz
mkdir /tmp/frr
tar -xzf frr-2.0.tar.gz -C /tmp/frr --strip-components 1
cd /tmp/frr
./bootstrap.sh
./configure \
    --prefix=/usr/local/frr \
#    --sbindir=/usr/local/sbin \
#    --bindir=/usr/local/bin \
#    --localstatedir=/usr/local/frr/var \
    --enable-user=frr \
    --enable-group=frr \
    --enable-vty-group=frrvty \
    --enable-configfile-mask=0640 \
    --enable-logfile-mask=0640 \
    --disable-ripd \
    --disable-ripngd \
    --disable-isisd \
    --disable-ospf6d \
    --enable-multipath=8 \
    --enable-shell-access \
    --enable-rtadv
make
make check
make install
mkdir -p /usr/local/frr/var
cd /usr/local/frr/etc
cat > zebra.conf <<EOL
hostname FRRouter
password zebra
log stdout
EOL
cp zebra.conf ospfd.conf
cp zebra.conf bgpd.conf
cp zebra.conf vtysh.conf
chown -R frr:frr /usr/local/frr
