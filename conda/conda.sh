#1 create a new environment in the AppDir with packages specified with a text-file
conda create -p $TRAVIS_BUILD_DIR/conda/AppDir/usr --file freecad-spec-file.txt --copy

#2 delete unnecessary stuff
rm -rf AppDir/usr/include
find AppDir/usr -name \*.a -delete
mv AppDir/usr/bin AppDir/usr/bin_tmp
mkdir AppDir/usr/bin
cp AppDir/usr/bin_tmp/FreeCAD AppDir/usr/bin/FreeCAD
cp AppDir/usr/bin_tmp/activate AppDir/usr/bin/  
cp AppDir/usr/bin_tmp/python AppDir/usr/bin/
cp AppDir/usr/bin_tmp/widget.py AppDir/usr/bin/
rm -rf AppDir/usr/bin_tmp
#+ deleting some specific libraries not needed. eg.: stdc++

#3 create the appimage
chmod a+x ./AppDir/AppRun
ARCH=x86_64 ../appimagetool-x86_64.AppImage $TRAVIS_BUILD_DIR/conda/AppDir
ARCH=x86_64 ../appimagetool-x86_64.AppImage -u "gh-releases-zsync|FreeCAD|FreeCAD|0.18_pre|FreeCAD*glibc2.12-x86_64.AppImage.zsync" $TRAVIS_BUILD_DIR/conda/AppDir

#4 setting rights for the appimage
mv *.AppImage FreeCAD_0.18_Conda_Py3Qt5_glibc2.12-x86_64.AppImage
chmod +x *.AppImage
mv *.AppImage.zsync FreeCAD_0.18_Conda_Py3Qt5_glibc2.12-x86_64.AppImage.zsync

#5 delete the created environment
rm -rf AppDir/usr

