import sys
import os
import subprocess
import platform
import jinja2


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
system, arch = sys_n_arch[0], sys_n_arch[2]
if system in platform_dict:
    system = platform_dict[system]

version_info = subprocess.check_output("freecadcmd --version", shell=True)
version_info = version_info.decode("utf-8").split(" ")
dev_version = version_info[1]
revision = version_info[3]

python_version = "".join(get_version("python")[:2])  # eg 37
qt_version = "".join(get_version("qt")[:2])          # eg 512
occt_version = "".join(get_version("occt")[:2])      # eg 73

with open("Info.plist.template") as template_file:
    template_str = template_file.read()
template = jinja2.Template(template_str)
rendered_str = template.render(FREECAD_VERSION="{}-{}".format(dev_version, revision), 
                               APPLICATION_MENU_NAME="FreeCAD-{}-{}".format(dev_version, revision))
with open("APP/FreeCAD.app/Contents/Info.plist", "w") as rendered_file:
    rendered_file.write(rendered_str)

print("FreeCAD_{}-{}-{}-{}-conda-Py{}-Qt{}-Occt{}".format(dev_version, revision, system, arch,
                                                          python_version, qt_version, occt_version))