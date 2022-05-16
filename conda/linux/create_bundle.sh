#!/bin/bash

echo -e "\nCreate the environment"
conda create \
  -p AppDir/usr \
  freecad occt=7.5 vtk=9 python=3.9 calculix blas=*=openblas gitpython \
  numpy matplotlib-base scipy sympy pandas six \
  pyyaml opencamlib ifcopenshell pythonocc-core \
  freecad.asm3 libredwg pycollada appimage-updater-bridge \
  lxml xlutils olefile requests openglider \
  blinker opencv qt.py nine docutils \
  --copy \
  -c freecad/label/dev \
  -c conda-forge \
  -y

echo -e "\nInstall freecad.appimage_updater"
conda run -p AppDir/usr pip install https://github.com/looooo/freecad.appimage_updater/archive/master.zip

echo -e "\nUninstall some packages not needed"
conda uninstall -p AppDir/usr libclang --force -y

version_name=$(conda run -p AppDir/usr python ../scripts/get_freecad_version.py)
echo -e "\################"
echo -e "version_name:  ${version_name}"
echo -e "################"

conda list -p AppDir/usr > AppDir/packages.txt
sed -i "1s/.*/\n\nLIST OF PACKAGES:/" AppDir/packages.txt

echo -e "\nDelete unnecessary stuff"
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

echo -e "\nCopy qt.conf"
cp qt.conf AppDir/usr/bin/
cp qt.conf AppDir/usr/libexec/

echo -e "\nCopy Icon and Desktop file"
mkdir -p AppDir/usr/share/icons/default/
cp AppDir/freecad_weekly.png AppDir/usr/share/icons/default/freecad_weekly.png
mkdir -p AppDir/usr/share/applications/
cp AppDir/freecad_weekly.desktop AppDir/usr/share/applications/freecad_weekly.desktop

# Remove __pycache__ folders and .pyc files
find . -path "*/__pycache__/*" -delete
# find . -name "*.pyc" -type f -delete

# reduce size
rm -rf AppDir/usr/conda-meta/
rm -rf AppDir/usr/doc/global/
rm -rf AppDir/usr/share/gtk-doc/
rm -rf AppDir/usr/lib/cmake/

find . -name "*.h" -type f -delete
find . -name "*.cmake" -type f -delete

echo -e "\nAdd libnsl (Fedora 28 and up)"
cp ../../libc6/lib/x86_64-linux-gnu/libnsl* AppDir/usr/lib/

if [ ${ADD_DOCS} ]
then
  echo -e "\nAdd documentation"
  mkdir -p AppDir/usr/share/doc/FreeCAD
  cp ../../doc/* AppDir/usr/share/doc/FreeCAD
fi

if [ "$DEPLOY_RELEASE" = "weekly-builds" ]; then
  export tag="weekly-builds"
else
  export tag="latest"
fi

echo -e "\nCreate the appimage"
chmod a+x ./AppDir/AppRun
ARCH=x86_64 ../../appimagetool-x86_64.AppImage \
  -u "gh-releases-zsync|FreeCAD|FreeCAD-Appimage|$tag|FreeCAD*glibc2.12-x86_64.AppImage.zsync" \
  AppDir  ${version_name}.AppImage

echo -e "\nCreate hash"
shasum -a 256 ${version_name}.AppImage > ${version_name}.AppImage-SHA256.txt
