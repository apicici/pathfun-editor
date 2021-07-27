PATH="$PATH:$HOME/.local/bin"
DISTRIBUTOR="python love-distributor.py"
NAME=${APPVEYOR_PROJECT_SLUG}
IDENTIFIER=com.apicici.pathfun-editor
COPYRIGHT="© 2021 apicici"
CIMGUI_VERSION="1.83-3"
CLIPPER_VERSION="v1.0"

pip install hererocks
hererocks env --lua 5.1 -rlatest
source env/bin/activate
luarocks install moonscript

mkdir -p build
cd build

wget "https://raw.githubusercontent.com/apicici/love-distributor/main/love-distributor.py"

cd ../src
moonc -t "../build/lua" .
for f in `find -L -name "*.lua"`
	do
		mkdir -p "../build/lua/${f%/*}"
		cp "$f" "../build/lua/$f"
	done

cd ../build/lua
zip -9 -r "../game.love" *

cd ..
for suffix in "linux-x64" "macos-x64" "windows-x86" "windows-x64"
do
    mkdir -p "extra-$suffix"
    wget "https://github.com/apicici/clipper-luajit-ffi/releases/download/$CLIPPER_VERSION/clipper-luajit-ffi-$suffix-$CLIPPER_VERSION.zip"
    unzip -j "clipper-luajit-ffi-$suffix-$CLIPPER_VERSION.zip" *.so *.dll *.dylib -d "extra-$suffix"
    wget "https://github.com/apicici/cimgui-love/releases/download/$CIMGUI_VERSION/cimgui-love-$suffix-$CIMGUI_VERSION.zip"
    unzip -j "cimgui-love-$suffix-$CIMGUI_VERSION.zip" *.so *.dll *.dylib -d "extra-$suffix"
    cd "extra-$suffix"
    tar -c * -f "../extra-$suffix.tar"
    cd ..
done

$DISTRIBUTOR linux "$NAME" "game.love" .. extra-linux-x64.tar
$DISTRIBUTOR windows -a x86 "$NAME" "game.love" .. extra-windows-x86.tar
$DISTRIBUTOR windows -a x64 "$NAME" "game.love" .. extra-windows-x64.tar
$DISTRIBUTOR macos "$NAME" "game.love" .. "$IDENTIFIER" "$COPYRIGHT" extra-macos-x64.tar

cd ..
for suffix in "linux-x64" "macos-x64" "windows-x86" "windows-x64"
do
    zip -j "$NAME-$suffix.zip" ".appveyor/LICENSE.md" ".appveyor/LOVE_LICENSE.txt"
done
