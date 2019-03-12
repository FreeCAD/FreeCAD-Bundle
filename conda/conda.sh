# create a new environment in the AppDir
conda create \
    -p AppDir/usr \
    freecad calculix blas=*=openblas gitpython\
    --copy \
    --no-default-packages \
    -c freecad/label/dev_cf201901 \
    -c conda-forge/label/cf201901 \
    -y

# activating the environment to install additional tools
# this can be skipped if we create conda-packages from the pip-packages...
# extract the version information
source activate AppDir/usr
FreeCAD --console $TRAVIS_BUILD_DIR/conda/version.py
pip install https://github.com/looooo/freecad.pip/archive/master.zip --no-deps
pip install https://github.com/FreeCAD/freecad.plot/archive/master.zip --no-deps
pip install https://github.com/FreeCAD/freecad.ship/archive/master.zip --no-deps
source activate base

# this will create a huge env. We have to find some ways to make the env smaller
# deleting some packages explicitly?
conda remove -p AppDir/usr --force -y \
    ruamel_yaml conda system tk json-c llvmdev \
    nomkl readline mesalib \
    curl gstreamer libtheora asn1crypto certifi chardet \
    gst-plugins-base idna kiwisolver pycosat pycparser pysocks \
    pytz sip solvespace tornado xorg* cffi \
    cycler python-dateutil cryptography pyqt soqt wheel \
    requests libstdcxx-ng xz sqlite ncurses

conda list -p AppDir/usr

# delete unnecessary stuff
rm -rf AppDir/usr/include
find AppDir/usr -name \*.a -delete
mv AppDir/usr/bin AppDir/usr/bin_tmp
mkdir AppDir/usr/bin
cp AppDir/usr/bin_tmp/FreeCAD AppDir/usr/bin/FreeCAD
cp AppDir/usr/bin_tmp/FreeCAD/FreeCADCmd AppDir/usr/bin/FreeCADCmd
cp AppDir/usr/bin_tmp/FreeCAD/ccx AppDir/usr/bin/ccx
cp AppDir/usr/bin_tmp/python AppDir/usr/bin/
cp AppDir/usr/bin_tmp/pip AppDir/usr/bin/
cp AppDir/usr/bin_tmp/pyside2-rcc AppDir/usr/bin/
sed -i '1s|.*|#!/usr/bin/env python|' AppDir/usr/bin/pip
rm -rf AppDir/usr/bin_tmp
#+ deleting some specific libraries not needed. eg.: stdc++

# create the appimage
chmod a+x ./AppDir/AppRun
FC_VERSION=$(ls *.AppImage)
rm *.AppImage
ARCH=x86_64 ../appimagetool-x86_64.AppImage \
  -u "gh-releases-zsync|FreeCAD|FreeCAD|0.18_pre|FreeCAD*glibc2.12-x86_64.AppImage.zsync" \
  $TRAVIS_BUILD_DIR/conda/AppDir \
  $TRAVIS_BUILD_DIR/conda/$FC_VERSION

