# release:
1. create branch based on master `release_0.x.y`
2. make changes to github action files
  * source creation must use the related release tag!
  * the bundle scripts must upload to the right release
3. check if git information is filled in correctly `version.h.cmake`
4. run the github action script to create the compressed source files
5. create PR for [conda-forge/freecad-feedstock](https://github.com/conda-forge/freecad-feedstock)
6. once PR is merged change the bundle-scripts to use the conda-forge release packages


# naming convention:

FreeCAD_{{ release }}-{{ revision }}-{{ date }}-{{ system }}-{{ python-version }}.{{ extension }}