# create a new environment in the AppDir
conda create \
    -p AppDir/usr \
    freecad=0.18 calculix blas=*=openblas gitpython \
    numpy matplotlib scipy sympy pandas six pyyaml \
    --copy \
    --no-default-packages \
    -c freecad/label/dev_cf201901 \
    -c conda-forge/label/cf201901 \
    -y


# installing some additional libraries with pip
version_name=$(conda run -p AppDir/usr python get_freecad_version.py)
conda run -p AppDir/usr pip install https://github.com/looooo/freecad_pipintegration/archive/master.zip


conda list -p AppDir/usr

# delete unnecessary stuff
rm -rf AppDir/usr/include
find AppDir/usr -name \*.a -delete
mv AppDir/usr/bin AppDir/usr/bin_tmp
mkdir AppDir/usr/bin
cp AppDir/usr/bin_tmp/FreeCAD AppDir/usr/bin/
cp AppDir/usr/bin_tmp/FreeCADCmd AppDir/usr/bin/
cp AppDir/usr/bin_tmp/ccx AppDir/usr/bin/
cp AppDir/usr/bin_tmp/python AppDir/usr/bin/
cp AppDir/usr/bin_tmp/pip AppDir/usr/bin/
cp AppDir/usr/bin_tmp/pyside2-rcc AppDir/usr/bin/
cp AppDir/usr/bin_tmp/assistant AppDir/usr/bin/
sed -i '1s|.*|#!/usr/bin/env python|' AppDir/usr/bin/pip
rm -rf AppDir/usr/bin_tmp
#+ deleting some specific libraries not needed. eg.: stdc++

# add documentation
cp ../../doc/* AppDir/usr/doc/

# Remove __pycache__ folders and .pyc files
conda deactivate
find . -path "*/__pycache__/*" -delete
find . -name "*.pyc" -type f -delete

# Add libnsl (Fedora 28 and up)
cp ../../libc6/lib/x86_64-linux-gnu/libnsl* AppDir/usr/lib/

# create the appimage
chmod a+x ./AppDir/AppRun
rm *.AppImage
ARCH=x86_64 ../../appimagetool-x86_64.AppImage \
  -u "gh-releases-zsync|FreeCAD|FreeCAD|latest|FreeCAD*glibc2.12-x86_64.AppImage.zsync" \
  AppDir  ${version_name}.AppImage
