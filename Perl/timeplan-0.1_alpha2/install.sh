#!/bin/sh
# very simple and ugly install script
# I'll make something better later

# get info about environment
PREFIX="/usr/local" # change to install somewhere else

if [ "$UID" != "0" ]; then
	echo "You have to be root to install Time Plan"
	exit
fi

# install the files
echo -n "installing..."

mkdir -p $PREFIX/bin
cp timeplan $PREFIX/bin/
chmod 755 $PREFIX/bin/timeplan

mkdir -p $PREFIX/share/timeplan
cp -r data/ $PREFIX/share/timeplan/

mkdir -p $PREFIX/share/doc/timeplan
cp AUTHORS LICENSE README TODO $PREFIX/share/doc/timeplan

echo "done!"
echo "Read the readme for help"
