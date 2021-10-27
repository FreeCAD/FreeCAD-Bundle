#!/usr/bin/env python

# call this file from within the FreeCAD git repo
# this script creates a file with the important version information

import sys
import subprocess

# get number of commits:
p1 = subprocess.Popen(["git", "rev-list", "--count", "master"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
p2 = subprocess.Popen(["git", "branch"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
p3 = subprocess.Popen(["git", "log", "-1", "--format=%ci"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
p4 = subprocess.Popen(["git", "rev-parse", "--short", "HEAD"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

out1, err1 = p1.communicate()
out2, err2 = p2.communicate()
out3, err3 = p3.communicate()
out4, err4 = p4.communicate()

rev_number = out1.decode()
branch_name = out2.decode().split(" ")[-1]
commit_date = out3.decode().replace("-", "/").split(" ")
commit_date = commit_date[0] + " " + commit_date[1] + "\n"
commit_hash = out4.decode()


with open(sys.argv[1], "w") as f:
	f.write(f"rev_number: {rev_number}")
	f.write(f"branch_name: {branch_name}")
	f.write(f"commit_date: {commit_date}")
	f.write(f"commit_hash: {commit_hash}")
	
# replace numbers in version.h.cmake file
with open("src/Build/Version.h.cmake", "r+") as f:
	text = f.read()
	text = text.replace("${PACKAGE_WCREF}", rev_number)
	text = text.replace("${PACKAGE_WCDATE}", f"Hash: ({commit_hash}), Date: {commit_date}")
	print(text)
	f.write(text)

p5 = subprocess.Popen(["git", "commit" "-m", "add git information"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
out5, err5 = p5.communicate()
