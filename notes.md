# release:
1. create branch based on master release_0.x.y
2. make changes to github action files
  * source creation must use the related release branch/tag
  * the bundle scripts must upload to the right relese
3. run the github action script to create the compressed source files
4. create PR for conda-forge/freecad-feedstock
5. once PR is merged change the bundle-scripts to use the conda-forge release packages
