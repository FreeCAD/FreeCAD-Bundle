# assume we have a working conda available

export MAMBA_NO_BANNER=1

ARCHITECTURES="osx-64 osx-arm64"
for arch in $ARCHITECTURES
do
    conda_env="APP/FreeCAD.app/Contents/Resources/$arch"
    CONDA_SUBDIR=$arch mamba create -y --copy -c freecad/label/dev -c conda-forge -p ${conda_env} \
        python=3.11 \
        freecad=*.pre \
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
done

# build and install the launcher
cmake -B build -G Ninja launcher
cmake --build build
cp build/FreeCAD APP/FreeCAD.app/Contents/MacOS/FreeCAD

conda_env="APP/FreeCAD.app/Contents/Resources"

mamba run -p ${conda_env}/osx-arm64 python ../scripts/get_freecad_version.py
read -r version_name < bundle_name.txt

echo -e "\################"
echo -e "version_name:  ${version_name}"
echo -e "################"

mamba list -p ${conda_env}/osx-arm64 > APP/FreeCAD.app/Contents/packages.txt
sed -i "" "1s/.*/\nLIST OF PACKAGES:/"  APP/FreeCAD.app/Contents/packages.txt

# Make QuickLook a Universal Binary and copy the plugin into its final location
lipo -create -output QuicklookFCStd ${conda_env}/osx-64/Library/QuickLook/QuicklookFCStd.qlgenerator/Contents/MacOS/QuicklookFCStd ${conda_env}/osx-arm64/Library/QuickLook/QuicklookFCStd.qlgenerator/Contents/MacOS/QuicklookFCStd
mv ${conda_env}/osx-64/Library ${conda_env}/../Library
rm -rf ${conda_env}/osx-arm64/Library
mv QuicklookFCStd ${conda_env}/../Library/

# create the dmg
pip3 install --break-system-packages "dmgbuild[badge_icons]>=1.6.0,<1.7.0"
dmgbuild -s dmg_settings.py "FreeCAD" "${version_name}.dmg"

# create hash
shasum -a 256 ${version_name}.dmg > ${version_name}.dmg-SHA256.txt
