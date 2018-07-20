import os, glob
path = os.path.dirname(__file__)
os.chdir(path)
f = glob.glob("*.AppImage")[0]
v = FreeCAD.Version()
v = "FreeCAD_" + v[0] + "." + v[1] + "." + v[2].split()[0] + "." + "glibc2.17-x86_64.AppImage"
os.rename(os.path.join(path, f), os.path.join(path, v))
exit(0)
