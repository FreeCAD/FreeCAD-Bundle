# assume we have a working conda available
conda create \
    -p APP/FreeCAD.app/Contents/Resources \
    freecad calculix blas=*=openblas \
    --copy \
    --no-default-packages \
    -c freecad/label/testing \
    -c conda-forge \
    -y

# activating the environment to install additional tools
# this can be skipped if we create conda-packages from the pip-packages...
# extract the version information
source activate APP/FreeCAD.app/Contents/Resources
FreeCAD --console $TRAVIS_BUILD_DIR/conda/version.py
pip install https://github.com/looooo/freecad_pipintegration/archive/master.zip
source activate base

# this will create a huge env. We have to find some ways to make the env smaller
# deleting some packages explicitly? 
conda remove -p APP/FreeCAD.app/Contents/Resources --force -y \
    ruamel_yaml conda system tk json-c llvmdev \
    nomkl readline mesalib \
    curl gstreamer libtheora asn1crypto certifi chardet \
    gst-plugins-base idna kiwisolver pycosat pycparser pysocks \
    pytz sip solvespace tornado xorg* cffi \
    cycler python-dateutil cryptography pyqt soqt wheel \
    requests libstdcxx-ng xz sqlite ncurses

conda list -p APP/FreeCAD.app/Contents/Resources

# delete unnecessary stuff
rm -rf APP/FreeCAD.app/Contents/Resources/include
find APP/FreeCAD.app/Contents/Resources -name \*.a -delete
mv APP/FreeCAD.app/Contents/Resources/bin APP/FreeCAD.app/Contents/Resources/bin_tmp
mkdir APP/FreeCAD.app/Contents/Resources/bin
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/FreeCAD APP/FreeCAD.app/Contents/Resources/bin/FreeCAD
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/FreeCAD APP/FreeCAD.app/Contents/Resources/bin/
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/python APP/FreeCAD.app/Contents/Resources/bin/
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/pip APP/FreeCAD.app/Contents/Resources/bin/
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/pyside2-rcc APP/FreeCAD.app/Contents/Resources/bin/
sed -i "" '1s|.*|#!/usr/bin/env python|' APP/FreeCAD.app/Contents/Resources/bin/pip
rm -rf APP/FreeCAD.app/Contents/Resources/bin_tmp

hdiutil create -volname FreeCAD_0.18-16027-OSX-x86_64-Qt5-Py3 -srcfolder ./APP -ov -format UDZO FreeCAD_0.18-16027-OSX-x86_64-Qt5-Py3.dmg