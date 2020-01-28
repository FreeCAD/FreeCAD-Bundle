# assume we have a working conda available
conda create \
    -p APP/FreeCAD.app/Contents/Resources \
    freecad calculix blas=*=openblas gitpython python=3.8 \
    numpy matplotlib-base scipy sympy pandas six \
    pyyaml jinja2 opencamlib ifcopenshell qt=5.12 \
    freecad.asm3 \
    --copy \
    -c freecad/label/dev \
    -c conda-forge \
    -y

# uninstall some packages not needed
conda uninstall -p APP/FreeCAD.app/Contents/Resources gtk2 gdk-pixbuf  llvmdev clangdev --force -y

version_name=$(conda run -p APP/FreeCAD.app/Contents/Resources python get_freecad_version.py)

# installing some additional libraries with pip
conda run -p APP/FreeCAD.app/Contents/Resources pip install pycollada

conda list -p APP/FreeCAD.app/Contents/Resources > APP/FreeCAD.app/packages.txt
sed -i "1s/.*/\n\nLIST OF PACKAGES:/"  APP/FreeCAD.app/packages.txt


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
cp PP/FreeCAD.app/Contents/Resources/bin_tmp/assistant PP/FreeCAD.app/Contents/Resources/bin/
sed -i "" '1s|.*|#!/usr/bin/env python|' APP/FreeCAD.app/Contents/Resources/bin/pip
rm -rf APP/FreeCAD.app/Contents/Resources/bin_tmp

#copy qt.conf
cp qt.conf APP/FreeCAD.app/Contents/Resources/bin/
cp qt.conf APP/FreeCAD.app/Contents/Resources/libexec/

# Remove __pycache__ folders and .pyc files
find . -path "*/__pycache__/*" -delete
find . -name "*.pyc" -type f -delete

# create the dmg
hdiutil create -volname "${version_name}" -srcfolder ./APP -ov -format UDZO "${version_name}.dmg"

# create hash
shasum -a 256 ${version_name}.dmg > ${version_name}.dmg-SHA256.txt
