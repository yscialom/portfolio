#!/usr/bin/python3
import sys
import os
import json

def help():
    print("USAGE:", file=sys.stderr)
    print("\t%s gallery index" % sys.argv[0], file=sys.stderr)
    print("\tPrint the #index file from gallery", file=sys.stderr)

ERRORS = {
    "success": 0,
    "argv": 1,
    "inputfile": 2,
    "index": 3,
    "result": 4,
}
    

def error(strerr, ret):
    print("%s: %s" % (sys.argv[0], strerr), file=sys.stderr)
    print("", file=sys.stderr)
    help()
    sys.exit(ret)

if len(sys.argv) < 2:
    error("missing arguments", ERRORS["argv"])

gallerypath = sys.argv[1]
jsonpath = os.path.join(gallerypath, "data.json")
try:
    jsondata = open(jsonpath, "r")
    jsontree = json.loads(jsondata.read())
except IOError:
    error("%s: can't read file." % sys.argv[0], ERRORS["inputfile"])

try:
    thumbindex = int(sys.argv[2])
except ValueError:
    error("not an integer: %s" % sys.argv[2], ERRORS["index"])

try:
    filepath = os.path.join(gallerypath, jsontree["data"][thumbindex]["file"][0])
except IndexError:
    error("%s: not a valid index" % thumbindex, ERRORS["index"])

if os.path.isfile(filepath):
    print(filepath)
else:
    error("%s: no such file" % filepath, ERRORS["result"])

sys.exit(ERRORS["success"])
