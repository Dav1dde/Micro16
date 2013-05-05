#!/bin/sh

python2 ./build.py

mkdir -p /tmp/pack_m16/
cp -r docroot/ /tmp/pack_m16/m16/
cp -r dep/ /tmp/pack_m16/m16/
sed -i -e "s/\.\/dep/\/dep/" /tmp/pack_m16/m16/index.html

pushd /tmp/pack_m16/ >/dev/null
zip -r m16.zip m16/ >/dev/null
mv m16.zip m16/
popd >/dev/null

tar -pczf m16.tar.gz -C /tmp/pack_m16/ m16/

rm -rf /tmp/pack_m16/