#!/bin/bash
OLDPATH=$PATH
PATH=$PATH:$HOME/tmp/fgallery

urlencode() {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
	if [ $(LC_CTYPE=C printf '%d' "'$c") -ge 128 ]; then
	    printf '%%%02X' "'$c"
	else
            case $c in
		[[^:ascii:]]) printf '%%%02X' "'$c" ;;
		[a-zA-Z0-9.~_-]) printf "$c" ;;
		" ") printf '+' ;;
		*) printf '%%%02X' "'$c"
            esac
	fi
    done
}
 
source_dir="$1"
album_title=$(basename "$source_dir")
album_name=$(urlencode "$album_title")
dest_dir="$HOME/Images/Photos/web/$album_name"

echo Creating gallery in $dest_dir ...
test -d "$dest_dir" && rm -fr "$dest_dir"
fgallery -j5 -i --index "../index.html" "$source_dir" "$dest_dir" "$album_title"

PATH=$OLDPATH
