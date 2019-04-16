# # assume we have a working conda available
conda create \
    -p APP/FreeCAD.app/Contents/Resources \
    freecad calculix blas=*=openblas gitpython \
    numpy matplotlib scipy sympy pandas six pyyaml jinja2 \
    --copy \
    --no-default-packages \
    -c freecad/label/dev \
    -c conda-forge \
    -y


# installing some additional libraries with pip
version_name=$(conda run -p APP/FreeCAD.app/Contents/Resources python get_freecad_version.py)
conda run -p APP/FreeCAD.app/Contents/Resources pip install https://github.com/looooo/freecad_pipintegration/archive/master.zip

# this will create a huge env. We have to find some ways to make the env smaller
# deleting some packages explicitly? 
conda remove -p APP/FreeCAD.app/Contents/Resources --force -y \
    ruamel_yaml conda system tk json-c llvmdev \
    nomkl readline mesalib \
    gstreamer libtheora asn1crypto certifi chardet \
    gst-plugins-base idna kiwisolver pycosat pycparser pysocks \
    sip solvespace tornado xorg* cffi \
    cryptography-vectors pyqt soqt wheel \
    requests libstdcxx-ng xz sqlite ncurses jinja2

conda list -p APP/FreeCAD.app/Contents/Resources

# # delete unnecessary stuff
rm -rf APP/FreeCAD.app/Contents/Resources/include
find APP/FreeCAD.app/Contents/Resources -name \*.a -delete
mv APP/FreeCAD.app/Contents/Resources/bin APP/FreeCAD.app/Contents/Resources/bin_tmp
mkdir APP/FreeCAD.app/Contents/Resources/bin
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/FreeCAD APP/FreeCAD.app/Contents/Resources/bin/
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/FreeCADCmd APP/FreeCAD.app/Contents/Resources/bin
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/ccx APP/FreeCAD.app/Contents/Resources/bin/
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/python APP/FreeCAD.app/Contents/Resources/bin/
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/pip APP/FreeCAD.app/Contents/Resources/bin/
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/pyside2-rcc APP/FreeCAD.app/Contents/Resources/bin/
cp PP/FreeCAD.app/Contents/Resources/bin_tmp/assistant PP/FreeCAD.app/Contents/Resources/bin/
sed -i "" '1s|.*|#!/usr/bin/env python|' APP/FreeCAD.app/Contents/Resources/bin/pip
rm -rf APP/FreeCAD.app/Contents/Resources/bin_tmp

# create the dmg
hdiutil create -volname "${version_name}" -srcfolder ./APP -ov -format UDZO "${version_name}.dmg"
