#!/bin/bash
set -e

function get_version {
  local changelog=$1
  local line=$( grep -E -m 1 -e "webpthumbnaliler\s(.*)" "$changelog" )
  line=${line//webpthumbnaliler (}
  local version=${line//) *}
  echo $version
}

echo "Packaging webpthumbnailer"

BASE="build"
VERSION=$(get_version DEBIAN/changelog)

echo "Version: $VERSION"

## DELETE THE OLD BUILD FOLDER

if [ -e "$BASE" ]; then
  rm -R "$BASE"
fi
mkdir "$BASE"

## COPY SCRIPTS
mkdir -p "$BASE/usr/bin"
mkdir -p "$BASE/usr/share/webpthumbnailer"
mkdir -p "$BASE/usr/share/thumbnailers"

cp webpthumb.sh "$BASE/usr/bin/webpthumb"
cp webpthumb.py "$BASE/usr/share/webpthumbnailer"
cp webp.thumbnailer "$BASE/usr/share/thumbnailers"

chmod +x "$BASE/usr/bin/webpthumb"
chmod +x "$BASE/usr/share/webpthumbnailer/webpthumb.py"
chmod +r "$BASE/usr/share/thumbnailers/webp.thumbnailer"

## OTHER
mkdir -p "$BASE/usr/share/python3/runtime.d"
cp DEBIAN/webpthumb.rtupdate "$BASE/usr/share/python3/runtime.d"
chmod 755 "$BASE/usr/share/python3/runtime.d/webpthumb.rtupdate"


# DEBIAN FILES

mkdir -p "$BASE/DEBIAN"
cp DEBIAN/postinst "$BASE/DEBIAN/postinst"
cp DEBIAN/prerm "$BASE/DEBIAN/prerm"

cd "$BASE"

find "usr" -type f -print0 | xargs -0 md5sum >> DEBIAN/md5sums


# CREATE CONTROL FILE

cd "DEBIAN"

echo "Package: webpthumbnailer" > control
echo "Version: $VERSION" >> control
echo "Section: web" >> control
echo "Priority: optional" >> control
echo "Architecture: all" >> control
echo "Depends: python3, python3-pil" >> control
echo "Installed-Size: 25" >> control
echo "Maintainer: Francesco Di Baldassarre <f.dibaldassarre@gmail.com>" >> control
echo "Provides: webpthumbnailer" >> control
echo "Description: Create thumbnails for webp images" >> control

# BUILD
cd "../../"

mkdir -p target

fakeroot dpkg-deb --build build/ target/webpthumbnailer_"$VERSION"_all.deb

exit 0
