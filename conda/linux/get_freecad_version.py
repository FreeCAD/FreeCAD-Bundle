import sys
import os
import subprocess
import platform

platform_dict = {}
platform_dict["Darwin"] = "OSX"

sys_n_arch = platform.platform()
sys_n_arch = sys_n_arch.split("-")
system, arch = sys_n_arch[0], sys_n_arch[2]
if system in platform_dict:
    system = platform_dict[system]

version_info = subprocess.check_output("FreeCADCmd --version", shell=True)
version_info = version_info.decode("utf-8").split(" ")
dev_version = version_info[1]
revision = version_info[3]

print("FreeCAD_{}-{}-{}-{}-conda-Qt5-Py3".format(dev_version, revision, system, arch))