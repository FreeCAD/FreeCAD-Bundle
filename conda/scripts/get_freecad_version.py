import sys
import os
import subprocess
import platform
import datetime

platform_dict = {}
platform_dict["macOS"] = "OSX"

system = platform.platform().split("-")[0]
if system in platform_dict:
    system = platform_dict[system]

arch = platform.processor()

# doing this manually for windows
if system == "Windows":
    arch = "x86_64"

python_verson = platform.python_version().split(".")
python_verson = "py" + python_verson[0] + python_verson[1]
date = str(datetime.datetime.now()).split(" ")[0]

version_info = subprocess.check_output("freecadcmd --version", shell=True)
version_info = version_info.decode("utf-8").split(" ")
dev_version = version_info[1]
revision = version_info[3]
revision = revision.rstrip("\n")

if system == "OSX":
    import jinja2
    osx_directory = os.path.join(os.path.dirname(__file__), "..", "osx")
    with open(os.path.join(osx_directory, "Info.plist.template")) as template_file:
        template_str = template_file.read()
    template = jinja2.Template(template_str)
    rendered_str = template.render(FREECAD_VERSION="{}-{}".format(dev_version, revision), 
                                   APPLICATION_MENU_NAME="FreeCAD-{}-{}".format(dev_version, revision))
    with open(os.path.join(osx_directory, "APP", "FreeCAD.app", "Contents", "Info.plist"), "w") as rendered_file:
        rendered_file.write(rendered_str)

if "DEPLOY_RELEASE" in os.environ and os.environ["DEPLOY_RELEASE"] == "weekly-builds":
    dev_version = "weekly-builds"

print("FreeCAD_{}-{}-{}-{}-{}-{}".format(dev_version, revision, date, system, arch, python_verson))
