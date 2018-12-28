# assume we have a working conda available
conda create \
    -p FreeCAD.app/Contents/Resources \
    freecad calculix blas=*=openblas \
    --copy \
    --no-default-packages \
    -c freecad/label/dev \
    -c conda-forge \
    -y

# activating the environment to install additional tools
# this can be skipped if we create conda-packages from the pip-packages...
# extract the version information
source activate FreeCAD.app/Contents/Resources
FreeCAD --console $TRAVIS_BUILD_DIR/conda/version.py
pip install https://github.com/looooo/freecad_pipintegration/archive/master.zip
source activate base

# this will create a huge env. We have to find some ways to make the env smaller
# deleting some packages explicitly? 
conda remove -p FreeCAD.app/Contents/Resources --force -y \
    ruamel_yaml conda system tk json-c llvmdev \
    nomkl readline mesalib \
    curl gstreamer libtheora asn1crypto certifi chardet \
    gst-plugins-base idna kiwisolver pycosat pycparser pysocks \
    pytz sip solvespace tornado xorg* cffi \
    cycler python-dateutil cryptography pyqt soqt wheel \
    requests libstdcxx-ng xz sqlite ncurses

conda list -p FreeCAD.app/Contents/Resources

# delete unnecessary stuff
rm -rf FreeCAD.app/Contents/Resources/include
find FreeCAD.app/Contents/Resources -name \*.a -delete
mv FreeCAD.app/Contents/Resources/bin FreeCAD.app/Contents/Resources/bin_tmp
mkdir FreeCAD.app/Contents/Resources/bin
cp FreeCAD.app/Contents/Resources/bin_tmp/FreeCAD FreeCAD.app/Contents/Resources/bin/FreeCAD
cp FreeCAD.app/Contents/Resources/bin_tmp/FreeCAD FreeCAD.app/Contents/Resources/bin/
cp FreeCAD.app/Contents/Resources/bin_tmp/python FreeCAD.app/Contents/Resources/bin/
cp FreeCAD.app/Contents/Resources/bin_tmp/pip FreeCAD.app/Contents/Resources/bin/
cp FreeCAD.app/Contents/Resources/bin_tmp/pyside2-rcc FreeCAD.app/Contents/Resources/bin/
sed -i '1s|.*|#!/usr/bin/env python|' FreeCAD.app/Contents/Resources/bin/pip
rm -rf FreeCAD.app/Contents/Resources/bin_tmp

# linking the executeable
ln -s FreeCAD.app/Contents/Resources/bin/FreeCAD FreeCAD.app/Contents/MacOS/FreeCAD