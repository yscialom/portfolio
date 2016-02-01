#!/bin/bash

help() {
    echo "$0 [ -a | --albums albums_root_directory ] [ -d | --destination gallery_destination_directory ] [ -i | --include regexp ]"
}

#
## Checks
#
bins="cut expr fgallery grep ls realpath rm tempfile wc"
for bin in ${bins}; do
    echo -n "checking $bin ... "
    if which ${bin} > /dev/null; then
        echo "found."
    else
        echo "not found."
        exit 1
    fi
done

#
## ARGS reading
#
opt_albums_root="."
opt_dst_root="${opt_albums_root}/web"
opt_album_include_filter=""

while [ $# -ge 1 ] ; do
    case "$1" in
    -h|--help)
        help
        exit 0
        ;;
    -a|--albums)
        if [ $# -lt 2 ] ; then
            help
            exit 1
        fi
        opt_albums_root=$(realpath --relative-to="$PWD" "$2")
        shift
        shift
        ;;
    -d|--destination)
        if [ $# -lt 2 ] ; then
            help
            exit 1
        fi
        opt_dst_root=$(realpath --relative-to="$PWD" "$2")
        shift
        shift
        ;;
    -i|--include)
        if [ $# -lt 2 ] ; then
            help
            exit 1
        fi
        opt_album_include_filter="$2"
        shift
        shift
        ;;
    *) help
       exit 1
       ;;
    esac
done

if [ ! -d "${opt_dst_root}" ]; then
    mkdir -p "${opt_dst_root}"
fi

#
## ALBUM PROCESSING HELPER FUNCTIONS
#

##
## @brief Get gallery title (displayable name).
## @param $1 Absolute or relative path of source album.
##
gallery_title() {
    echo -n $(basename "$1")
}

##
## @brief Get gallery name (technical name).
## @param $1 Absolute or relative path of source album.
##
gallery_name() {
    title=$(gallery_title "$1")
    ./urlencode.sh "${title}"
}

##
## @brief Test whether a gallery exists
## @param $1 Absolute or relative path of source album.
## @retval 0 If gallery for @a $1 already exists;
## @retval 1 otherwise.
##
gallery_exists() {
    gallery_name=$(gallery_name "$1")
    dest_dir="${opt_dst_root}/${gallery_name}"
    if [ -f "$dest_dir/data.json" ] ; then
	    return 0
    else
	    return 1
    fi
}

##
## @brief Test whether a gallery must be ignored
## @param $1 Absolute or relative path of source album.
## @retval 0 If gallery for @a $1 must be ignored;
## @retval 1 otherwise.
##
gallery_exclude() {
    gallery_name=$(gallery_name "$1")
    src_dir="${opt_albums_root}/${gallery_name}"
    if [ -f "${src_dir}/.fgalignore" ] ; then
	    return 0
    else
	    return 1
    fi
}

##
## @brief Create a gallery from an album
## @param $1 Absolute path of source album.
## @param $2 Gallery name.
## @param $3 Gallery title.
##
gallery_create() {
    album_url="$1"
    gallery_name="$2"
    gallery_title="$3"
    dest_dir="${opt_dst_root}/${gallery_name}"
    echo "Creating gallery in ${dest_dir} ..."
    test -d "${dest_dir}" && rm -fr "${dest_dir}"
    fgallery -j5 -i --index "../../index.html" "$album_url" "$dest_dir" "$gallery_title"
}

##
## @brief List albums
##
album_list() {
    if [ "x${opt_album_include_filter}y" == "xy" ]; then
        ls"${opt_albums_root}"
    else
        ls "${opt_albums_root}" | grep -E "${opt_album_include_filter}"
    fi
}

##
## @brief Display gallery creation progress.
## @param $1 Current gallery count.
## @param $2 Total number of galleries.
##
display_progress() {
    gallery_index=$1
    gallery_count=$2
    echo "$album_index/$album_count ($(expr $album_index \* 100 / $album_count)%)"
}


#
## GALLERIES CREATION
#
# Build album list
tmpf=$(tempfile)
album_list > "${tmpf}"
album_count=$(wc -l ${tmpf} | cut -d\  -f1)

# Process albums
let album_index=0
while read album_name ; do
    album_url=$(realpath "${opt_albums_root}"/"${album_name}")
    display_progress $album_index $album_count
    if ! ( gallery_exists "${album_url}" || gallery_exclude "${album_url}" ) ; then
        gallery_name=$(gallery_name "${album_url}")
        gallery_title=$(gallery_title "${album_url}")
	    gallery_create "${album_url}" "${gallery_name}" "${gallery_title}"
    fi
    let album_index++
done < $tmpf
rm $tmpf

# Display End of Work
display_progress $album_count $album_count
