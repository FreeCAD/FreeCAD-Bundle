import os, glob
path = os.path.dirname(__file__)
os.chdir(path)
v = FreeCAD.Version()
v = "FreeCAD_" + v[0] + "." + v[1] + "." + v[2].split()[0] + "_Conda_Py3Qt5_glibc2.12-x86_64.AppImage"
f = open(v, "w") 
f.close()
exit(0)

