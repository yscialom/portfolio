#!/bin/bash

urlencode() {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
	if [ $(LC_CTYPE=C printf '%d' "'$c") -ge 128 ]; then
	    printf '=%02X' "'$c"
	else
            case $c in
		[[^:ascii:]]) printf '=%02X' "'$c" ;;
		[a-zA-Z0-9.~_-]) printf "$c" ;;
		" ") printf '+' ;;
		*) printf '=%02X' "'$c"
            esac
	fi
    done
}

album_exists() {
    source_dir="$1"
    album_title=$(basename "$source_dir")
    album_name=$(urlencode "$album_title")
    dest_dir="$HOME/Images/Photos/web/$album_name"
    if [ -f "$dest_dir/data.json" ] ; then
	return 0
    else
	return 1
    fi
}

album_count=$(ls | grep -c -)
let album_index=0
display_album_progress() {
    echo "$album_index/$album_count ($(expr $album_index \* 100 / $album_count)%)"
}

tmpf=$(tempfile)
ls | grep - > $tmpf
while read srcdir ; do
    display_album_progress
    if ! album_exists "$srcdir" ; then
	./fgal.sh "$srcdir"
    fi
    let album_index++
done < $tmpf
rm $tmpf

album_index=$album_count
display_album_progress
