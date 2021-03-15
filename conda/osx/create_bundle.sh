# assume we have a working conda available
conda create \
    -p APP/FreeCAD.app/Contents/Resources \
    freecad=0.19.1 calculix blas=*=openblas gitpython netgen=6.2.1808 \
    numpy matplotlib-base scipy=1.4.1 sympy pandas pythonocc-core six \
    pyyaml jinja2 opencamlib ifcopenshell boost-cpp=1.72 \
    freecad.asm3 libredwg pycollada openglider \
    lxml xlutils olefile requests \
    blinker opencv qt.py nine docutils \
    --copy \
    -c freecad/label/dev \
    -c conda-forge \
    -y

# uninstall some packages not needed
conda uninstall -p APP/FreeCAD.app/Contents/Resources gtk2 gdk-pixbuf  llvmdev clangdev --force -y

version_name=$(conda run -p APP/FreeCAD.app/Contents/Resources python get_freecad_version.py)

conda list -p APP/FreeCAD.app/Contents/Resources > APP/FreeCAD.app/Contents/packages.txt
sed -i "1s/.*/\n\nLIST OF PACKAGES:/"  APP/FreeCAD.app/Contents/packages.txt


# delete unnecessary stuff
rm -rf APP/FreeCAD.app/Contents/Resources/include
find APP/FreeCAD.app/Contents/Resources -name \*.a -delete
mv APP/FreeCAD.app/Contents/Resources/bin APP/FreeCAD.app/Contents/Resources/bin_tmp
mkdir APP/FreeCAD.app/Contents/Resources/bin
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/freecad APP/FreeCAD.app/Contents/Resources/bin/
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/freecadcmd APP/FreeCAD.app/Contents/Resources/bin
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/ccx APP/FreeCAD.app/Contents/Resources/bin/
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/python APP/FreeCAD.app/Contents/Resources/bin/
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/pip APP/FreeCAD.app/Contents/Resources/bin/
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/pyside2-rcc APP/FreeCAD.app/Contents/Resources/bin/
cp APP/FreeCAD.app/Contents/Resources/bin_tmp/assistant APP/FreeCAD.app/Contents/Resources/bin/
sed -i "" '1s|.*|#!/usr/bin/env python|' APP/FreeCAD.app/Contents/Resources/bin/pip
rm -rf APP/FreeCAD.app/Contents/Resources/bin_tmp

#copy qt.conf
cp qt.conf APP/FreeCAD.app/Contents/Resources/bin/
cp qt.conf APP/FreeCAD.app/Contents/Resources/libexec/

# mpmath fix:
rm APP/FreeCAD.app/Contents/Resources/lib/python3.8/site-packages/mpmath/ctx_mp_python.py
cp ../modifications/ctx_mp_python.py APP/FreeCAD.app/Contents/Resources/lib/python3.8/site-packages/mpmath/ctx_mp_python.py

# Remove __pycache__ folders and .pyc files
find . -path "*/__pycache__/*" -delete
find . -name "*.pyc" -type f -delete

# create the dmg
hdiutil create -volname "${version_name}" -srcfolder ./APP -ov -format UDZO "${version_name}.dmg"

# create hash
shasum -a 256 ${version_name}.dmg > ${version_name}.dmg-SHA256.txt
