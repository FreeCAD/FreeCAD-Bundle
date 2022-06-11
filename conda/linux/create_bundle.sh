#!/bin/bash

export MAMBA_NO_BANNER=1
conda_env="AppDir/usr"
echo -e "\nCreate the environment"


mamba create \
  -p ${conda_env} \
  freecad occt=7.5 vtk=9 python=3.10 calculix blas=*=openblas gitpython \
  numpy matplotlib-base scipy sympy pandas six \
  pyyaml opencamlib ifcopenshell libredwg pycollada \
  appimage-updater-bridge lxml xlutils olefile requests \
  openglider blinker opencv qt.py nine docutils \
  --copy -c freecad/label/dev -c conda-forge -y
  

mamba run -p ${conda_env} python ../scripts/get_freecad_version.py
read -r version_name < bundle_name.txt

echo -e "\################"
echo -e "version_name:  ${version_name}"
echo -e "################"

echo -e "\nInstall freecad.appimage_updater"
mamba run -p ${conda_env} pip install https://github.com/looooo/freecad.appimage_updater/archive/master.zip

echo -e "\nUninstall some packages not needed"
conda uninstall -p ${conda_env} libclang --force -y

mamba list -p ${conda_env} > AppDir/packages.txt
sed -i "1s/.*/\n\nLIST OF PACKAGES:/" AppDir/packages.txt

echo -e "\nDelete unnecessary stuff"
rm -rf ${conda_env}/include
find ${conda_env} -name \*.a -delete
mv ${conda_env}/bin ${conda_env}/bin_tmp
mkdir ${conda_env}/bin
cp ${conda_env}/bin_tmp/freecad ${conda_env}/bin/
cp ${conda_env}/bin_tmp/freecadcmd ${conda_env}/bin/
cp ${conda_env}/bin_tmp/ccx ${conda_env}/bin/
cp ${conda_env}/bin_tmp/python ${conda_env}/bin/
cp ${conda_env}/bin_tmp/pip ${conda_env}/bin/
cp ${conda_env}/bin_tmp/pyside2-rcc ${conda_env}/bin/
cp ${conda_env}/bin_tmp/assistant ${conda_env}/bin/
sed -i '1s|.*|#!/usr/bin/env python|' ${conda_env}/bin/pip
rm -rf ${conda_env}/bin_tmp

echo -e "\nCopy qt.conf"
cp qt.conf ${conda_env}/bin/
cp qt.conf ${conda_env}/libexec/

echo -e "\nCopy Icon and Desktop file"
mkdir -p ${conda_env}/share/icons/default/
cp AppDir/freecad_weekly.png ${conda_env}/share/icons/default/freecad_weekly.png
mkdir -p ${conda_env}/share/applications/
cp AppDir/freecad_weekly.desktop ${conda_env}/share/applications/freecad_weekly.desktop

# Remove __pycache__ folders and .pyc files
find . -path "*/__pycache__/*" -delete
# find . -name "*.pyc" -type f -delete

# reduce size
rm -rf ${conda_env}/conda-meta/
rm -rf ${conda_env}/doc/global/
rm -rf ${conda_env}/share/gtk-doc/
rm -rf ${conda_env}/lib/cmake/

find . -name "*.h" -type f -delete
find . -name "*.cmake" -type f -delete

echo -e "\nAdd libnsl (Fedora 28 and up)"
cp ../../libc6/lib/x86_64-linux-gnu/libnsl* ${conda_env}/lib/

if [ ${ADD_DOCS} ]
then
  echo -e "\nAdd documentation"
  mkdir -p ${conda_env}/share/doc/FreeCAD
  cp ../../doc/* ${conda_env}/share/doc/FreeCAD
fi

if [ "$DEPLOY_RELEASE" = "weekly-builds" ]; then
  export tag="weekly-builds"
else
  export tag="latest"
fi

echo -e "\nCreate the appimage"
chmod a+x ./AppDir/AppRun
ARCH=x86_64 ../../appimagetool-x86_64.AppImage \
  -u "gh-releases-zsync|FreeCAD|FreeCAD-Appimage|$tag|FreeCAD*.AppImage.zsync" \
  AppDir  ${version_name}.AppImage

echo -e "\nCreate hash"
shasum -a 256 ${version_name}.AppImage > ${version_name}.AppImage-SHA256.txt
