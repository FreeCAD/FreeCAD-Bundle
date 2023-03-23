import sys
import os
import subprocess
import platform
from datetime import datetime

import freecad
import FreeCAD


package_manager = "conda"
system = platform.platform().split("-")[0]
arch = platform.processor()

if arch == "i386":
    # no idea how to get proper architecture for mac"
    arch = "x86_64"

# doing this manually for windows
if system == "Windows":
    arch = "x86_64"

python_verson = platform.python_version().split(".")
python_verson = "py" + python_verson[0] + python_verson[1]
date = str(datetime.now()).split(" ")[0]

version_info = FreeCAD.Version()
dev_version = version_info[0] + "." + version_info[1] + "." + version_info[2]
revision = version_info[3].split(" ")[0]

if system == "macOS":
    import jinja2
    print("create plist from template")
    if arch != "arm":
        osx_directory = "osx"
    else:
        osx_directory = "osx-arm64"
    osx_directory = os.path.join(os.path.dirname(__file__), "..", osx_directory)
    with open(os.path.join(osx_directory, "Info.plist.template")) as template_file:
        template_str = template_file.read()
    template = jinja2.Template(template_str)
    rendered_str = template.render(FREECAD_VERSION="{}-{}".format(dev_version, revision), 
                                   APPLICATION_MENU_NAME="FreeCAD-{}-{}".format(dev_version, revision))
    with open(os.path.join(osx_directory, "APP", "FreeCAD.app", "Contents", "Info.plist"), "w") as rendered_file:
        rendered_file.write(rendered_str)

if "DEPLOY_RELEASE" in os.environ and os.environ["DEPLOY_RELEASE"] == "weekly-builds":
    dev_version = "weekly-builds"
    revision_separator = "-"
else:
    revision_separator = ""
    revision = ""


bundle_name = f"FreeCAD_{dev_version}{revision_separator}{revision}-{date}-{package_manager}-{system}-{arch}-{python_verson}"

with open("bundle_name.txt", "w") as bundle_name_file:
    bundle_name_file.write(bundle_name)
