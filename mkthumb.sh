#!/bin/bash
help () {
    echo "$0 source width height"
    echo "Make a gallery representative thumb."
}

if [ "$1" = "-h" -o "$1" = "--help" ]; then
    help
    exit 0
fi

if [ ! -f "$1" ]; then
    echo "$0: $1: no such file" >&2
    exit 1
fi

source="$1"
width="$2"
height="$3"
resize_width=$(expr $width \* 150 / 100)
resize_height=$(expr $height \* 150 / 100)

directory=$(dirname "${source}")
filename=$(basename "${source}")
ext="${filename##*.}"
convert "${source}" -resize ${resize_width}x${resize_height} -gravity center -crop ${width}x${height}+0+0 "${directory}/index.${ext}"
