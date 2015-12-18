#!/bin/bash
help () {
    echo "$0 gallery index width height"
    echo "Make a gallery representative thumb."
}

if [ "$1" = "-h" -o "$1" = "--help" ]; then
    help
    exit 0
fi

if [ $# -lt 4 ]; then
    help
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "$0: $1: no such file" >&2
    exit 1
fi

gallery="$1"
index="$2"
width="$3"
height="$4"

# Find source (image) file
source=$(./thumbpath.py "${gallery}" "${index}")
if [ ! -f "${source}" ]; then
    exit 2
fi

# Compute resizing params
resize_width=$(expr $width \* 150 / 100)
resize_height=$(expr $height \* 150 / 100)

# Compute inout params
directory=$(dirname "${source}")
filename=$(basename "${source}")
ext="${filename##*.}"

# Resize & crop
convert "${source}" -resize ${resize_width}x${resize_height} -gravity center -crop ${width}x${height}+0+0 "${directory}/index.${ext}"
