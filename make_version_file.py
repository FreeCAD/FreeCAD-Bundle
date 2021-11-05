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
commit_date = commit_date[0] + " " + commit_date[1]
commit_hash = out4.decode()

rev_number = rev_number.replace("\n", "")
branch_name = branch_name.replace("\n", "")
commit_date = commit_date.replace("\n", "")
commit_hash = commit_hash.replace("\n", "")

with open(sys.argv[1], "w") as f:
	f.write(f"rev_number: {rev_number}\n")
	f.write(f"branch_name: {branch_name}\n")
	f.write(f"commit_date: {commit_date}\n")
	f.write(f"commit_hash: {commit_hash}\n")
	
# replace numbers in version.h.cmake file
with open("src/Build/Version.h.cmake", "r") as f:
	text = f.read()
	text = text.replace("${PACKAGE_WCREF}", f"{rev_number} (Git)")
	text = text.replace("${PACKAGE_WCDATE}", commit_date)
	
with open("src/Build/Version.h.cmake", "w") as f:
	f.write(text)

p6 = subprocess.Popen(["git", "-c", "user.name='ghaction'", "-c", "user.email='gh@action.org'",
		       "commit", "-a", "-m", "add git information"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

out6, err6 = p6.communicate()
		     		       
print(out6.decode())
print(err6.decode())
