#!/bin/sh

bootstrap () {
	sudo apt-get -y install build-essential libssl-dev git libsqlite3-dev pkg-config

	# set g++ 4.9 on ubuntu 14.04: 
	sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
	sudo apt-get -y update
	sudo apt-get -y install gcc-4.9 g++-4.9
	sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9

	mkdir -p "$DEPS_DIR_SRC"
}

boost () {
	mkdir -p "$DEPS_DIR_SRC"
	cd "$DEPS_DIR_SRC"

	echo "downloading boost 1.67.0 ..."
	wget -o /tmp/boostdownload.log https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz 

	echo "untar boost ..."
	tar xzf boost_1_67_0.tar.gz
	cd boost_1_67_0

	echo "configuring boost ..."
	./bootstrap.sh \
	        --prefix="$DEPS_DIR" \
	        --with-libraries=chrono,system,filesystem,random \
	        --with-toolset=gcc > /tmp/boostconf.log

	echo "builing boost ..."
	./b2 toolset=gcc cxxflags="-std=c++11" link=static install > /tmp/boostbuild.log
}

libtorrent () {
	mkdir -p "$DEPS_DIR_SRC"
	cd "$DEPS_DIR_SRC"

	echo "downloading libtorrent 1.1.7 ..."
	wget -o /tmp/lbtdownload.log https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_1_7/libtorrent-rasterbar-1.1.7.tar.gz

	echo "untar libtorrent ..."
	tar xzf libtorrent-rasterbar-1.1.7.tar.gz
	cd libtorrent-rasterbar-1.1.7

	echo "patching libtorrent ..."
	sed -i '47i #include <boost/next_prior.hpp>' "include/libtorrent/ip_filter.hpp"
	sed -i '56i #include <boost/next_prior.hpp>' "src/kademlia/routing_table.cpp"

	echo "configuring libtorrent ..."
	CXXFLAGS="-std=c++11" CPPFLAGS="-std=c++11" ./configure \
        --prefix="$DEPS_DIR" \
        --disable-shared --enable-static \
        --enable-encryption \
        --with-boost="$DEPS_DIR" > /tmp/lbtconf.log


	echo "building libtorrent ..."
	make install > /tmp/ltbbuild.conf
}


export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

DEPS_DIR=~/dev/deps
DEPS_DIR_SRC=$DEPS_DIR/src

bootstrap
boost
libtorrent
