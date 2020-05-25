# assume we have a working conda available
conda create \
    -p AppDir/usr \
    freecad calculix blas=*=openblas gitpython \
    numpy matplotlib-base scipy sympy pandas six \
    pyyaml opencamlib ifcopenshell boost-cpp=1.72 \
    freecad.asm3 libredwg pycollada appimage-updater-bridge \
    lxml xlutils olefile requests \
    blinker opencv qt.py gdal \
    --copy \
    -c freecad/label/dev \
    -c conda-forge \
    -y

# uninstall some packages not needed
conda uninstall -p AppDir/usr gtk2 gdk-pixbuf llvm-tools \
                              llvmdev clangdev clang clang-tools \
                              clangxx libclang libllvm9 --force -y

version_name=$(conda run -p AppDir/usr python get_freecad_version.py)

conda list -p AppDir/usr > AppDir/packages.txt
sed -i "1s/.*/\n\nLIST OF PACKAGES:/"  AppDir/packages.txt

# delete unnecessary stuff
rm -rf AppDir/usr/include
find AppDir/usr -name \*.a -delete
mv AppDir/usr/bin AppDir/usr/bin_tmp
mkdir AppDir/usr/bin
cp AppDir/usr/bin_tmp/freecad AppDir/usr/bin/
cp AppDir/usr/bin_tmp/freecadcmd AppDir/usr/bin/
cp AppDir/usr/bin_tmp/ccx AppDir/usr/bin/
cp AppDir/usr/bin_tmp/python AppDir/usr/bin/
cp AppDir/usr/bin_tmp/pip AppDir/usr/bin/
cp AppDir/usr/bin_tmp/pyside2-rcc AppDir/usr/bin/
cp AppDir/usr/bin_tmp/assistant AppDir/usr/bin/
sed -i '1s|.*|#!/usr/bin/env python|' AppDir/usr/bin/pip
rm -rf AppDir/usr/bin_tmp
#+ deleting some specific libraries not needed. eg.: stdc++

#copy qt.conf
cp qt.conf AppDir/usr/bin/
cp qt.conf AppDir/usr/libexec/

# Remove __pycache__ folders and .pyc files
# find . -path "*/__pycache__/*" -delete
# find . -name "*.pyc" -type f -delete

# reduce size
rm -rf AppDir/usr/conda-meta/
rm -rf AppDir/usr/doc/global/
rm -rf AppDir/usr/share/gtk-doc/
rm -rf AppDir/usr/lib/cmake/

find . -name "*.h" -type f -delete
find . -name "*.cmake" -type f -delete

# Add libnsl (Fedora 28 and up)
cp ../../libc6/lib/x86_64-linux-gnu/libnsl* AppDir/usr/lib/

# Add documentation
mkdir -p AppDir/usr/share/doc/FreeCAD/
cp ../../doc/* AppDir/usr/share/doc/FreeCAD/

# create the appimage
chmod a+x ./AppDir/AppRun
rm *.AppImage
ARCH=x86_64 ../../appimagetool-x86_64.AppImage \
  -u "gh-releases-zsync|FreeCAD|FreeCAD|$DEPLOY_RELEASE|FreeCAD*glibc2.12-x86_64.AppImage.zsync" \
  AppDir  ${version_name}.AppImage

# create hash
shasum -a 256 ${version_name}.AppImage > ${version_name}.AppImage-SHA256.txt
