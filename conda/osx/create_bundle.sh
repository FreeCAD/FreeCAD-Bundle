# assume we have a working conda available

conda_env="APP/FreeCAD.app/Contents/Resources"

mamba create -y --copy -c freecad/label/dev -c conda-forge -p ${conda_env} \
    python=3.11 \
    freecad=*dev \
    noqt6 \
    blas=*=openblas \
    blinker \
    calculix \
    docutils \
    ifcopenshell \
    jinja2 \
    lark \
    lxml \
    matplotlib-base \
    nine \
    numpy \
    occt \
    olefile \
    opencamlib \
    opencv \
    pandas \
    pycollada \
    pythonocc-core \
    pyyaml \
    requests \
    scipy \
    six \
    sympy \
    vtk \
    xlutils

# delete unnecessary stuff
rm -rf ${conda_env}/include
find ${conda_env} -name \*.a -delete
mv ${conda_env}/bin ${conda_env}/bin_tmp
mkdir ${conda_env}/bin
cp ${conda_env}/bin_tmp/freecad ${conda_env}/bin/
cp ${conda_env}/bin_tmp/freecadcmd ${conda_env}/bin
cp ${conda_env}/bin_tmp/ccx ${conda_env}/bin/
cp ${conda_env}/bin_tmp/python ${conda_env}/bin/
cp ${conda_env}/bin_tmp/pip ${conda_env}/bin/
cp ${conda_env}/bin_tmp/pyside2-rcc ${conda_env}/bin/
cp ${conda_env}/bin_tmp/gmsh ${conda_env}/bin/
cp ${conda_env}/bin_tmp/dot ${conda_env}/bin/
cp ${conda_env}/bin_tmp/unflatten ${conda_env}/bin/
sed -i "" '1s|.*|#!/usr/bin/env python|' ${conda_env}/bin/pip
rm -rf ${conda_env}/bin_tmp

#copy qt.conf
cp qt.conf ${conda_env}/bin/
cp qt.conf ${conda_env}/libexec/

# Remove __pycache__ folders and .pyc files
find . -path "*/__pycache__/*" -delete
find . -name "*.pyc" -type f -delete

# fix problematic rpaths and reexport_dylibs for signing
# see https://github.com/FreeCAD/FreeCAD/issues/10144#issuecomment-1836686775
# and https://github.com/FreeCAD/FreeCAD-Bundle/pull/203
mamba run -p ${conda_env} python ../scripts/fix_macos_lib_paths.py ${conda_env}/lib

# build and install the launcher
cmake -B build launcher
cmake --build build
mkdir -p APP/FreeCAD.app/Contents/MacOS
cp build/FreeCAD APP/FreeCAD.app/Contents/MacOS/FreeCAD

mamba run -p ${conda_env} python ../scripts/get_freecad_version.py
read -r version_name < bundle_name.txt

echo -e "\################"
echo -e "version_name:  ${version_name}"
echo -e "################"

mamba list -p ${conda_env} > APP/FreeCAD.app/Contents/packages.txt
sed -i "" "1s/.*/\nLIST OF PACKAGES:/"  APP/FreeCAD.app/Contents/packages.txt

# copy the plugin into its final location
mv ${conda_env}/Library ${conda_env}/../Library

# create the dmg
pip3 install --break-system-packages "dmgbuild[badge_icons]>=1.6.0,<1.7.0"
dmgbuild -s dmg_settings.py "FreeCAD" "${version_name}.dmg"

# create hash
shasum -a 256 ${version_name}.dmg > ${version_name}.dmg-SHA256.txt
