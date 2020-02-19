import sys
import os
import subprocess
import platform

def get_version(package_name):
    """
    returns the version given by conda list as a list of numbers (str)
    """
    proc = subprocess.Popen(["conda", "list", package_name],
                            stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    out, err = proc.communicate()
    out = out.decode("utf-8")
    version = out.split("\n{} ".format(package_name))[1].split()[0]
    return version.split(".")

platform_dict = {}
platform_dict["Darwin"] = "OSX"

sys_n_arch = platform.platform()
sys_n_arch = sys_n_arch.split("-")
system, arch = sys_n_arch[0], sys_n_arch[4]
if system in platform_dict:
    system = platform_dict[system]

version_info = subprocess.check_output("freecadcmd --version", shell=True)
version_info = version_info.decode("utf-8").split(" ")
dev_version = version_info[1]
revision = version_info[3]

python_version = "".join(get_version("python")[:2])  # eg 37
qt_version = "".join(get_version("qt")[:2])          # eg 512
occt_version = "".join(get_version("occt")[:2])      # eg 73

print("FreeCAD_{}-{}-{}-Conda_Py{}-Qt{}-Occt{}-glibc2.12-x86_64".format(dev_version, revision, system,
                                                                        python_version, qt_version, occt_version))
