PATH="$PATH:$HOME/.local/bin"
DISTRIBUTOR="python love-distributor.py"
NAME=${APPVEYOR_PROJECT_SLUG}
IDENTIFIER=com.apicici.pathfun-editor
COPYRIGHT="© 2021 apicici"
CIMGUI_VERSION="1.83-3"
CLIPPER_VERSION="v1.0"

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
for name in "linux-x64" "macos-x64" "windows-x86" "windows-x64"
do
    mkdir -p "extra-$name"
    wget "https://github.com/apicici/clipper-lua/releases/download/$CLIPPER_VERSION/clipper-lua-$name-$CLIPPER_VERSION.zip"
    unzip -j "clipper-lua-$name-$CLIPPER_VERSION.zip" *.so *.dll *.dylib -d "extra-$name"
    wget "https://github.com/apicici/cimgui-love/releases/download/$CIMGUI_VERSION/cimgui-love-$name-$CIMGUI_VERSION.zip"
    unzip -j "cimgui-love-$name-$CIMGUI_VERSION.zip" *.so *.dll *.dylib -d "extra-$name"
    cd "extra-$name"
    tar -c * -f "../extra-$name.tar"
    cd ..
done

$DISTRIBUTOR linux "$NAME" "game.love" . extra-linux-x64.tar
$DISTRIBUTOR windows -a x86 "$NAME" "game.love" . extra-windows-x86.tar
$DISTRIBUTOR windows -a x64 "$NAME" "game.love" . extra-windows-x64.tar
$DISTRIBUTOR macos "$NAME" "game.love" . "$IDENTIFIER" "$COPYRIGHT" extra-macos-x64.tar