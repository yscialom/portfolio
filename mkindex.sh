#!/bin/bash
help () {
    echo "$0 --albums albums_directory"
    echo -n "Outputs on stdout an HTML index page linking all albums found in "
    echo "albums_directory."
}

#
## PARAMS
#
TITLE=Title

#
## ARGS reading
#
opt_album_dir="."

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
        opt_album_dir="$(realpath --relative-to="$PWD" "$2")"
        shift
        shift
        ;;
    *) help
       exit 1
       ;;
    esac
done

#
## Print page
#
mkheader() {
    echo "<!doctype html>"
    echo "<html>"
    echo "<head>"
    echo "  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
    echo "  <title>${TITLE}</title>"
    echo "  <meta name=\"author\" content=\"Jake Rocheleau\">"
    echo "  <link rel=\"shortcut icon\" href=\"http://designshack.net/favicon.ico\">"
    echo "  <link rel=\"icon\" href=\"http://designshack.net/favicon.ico\">"
    echo "  <link rel=\"stylesheet\" type=\"text/css\" href=\"css/index.css\">"
    echo "  <link rel=\"stylesheet\" type=\"text/css\" href=\"http://fonts.googleapis.com/css?family=Kavoon\">"
    echo "</head>"
    echo ""
    echo "<body>"
}

mkfooter() {
    echo "</body>"
    echo "</html>"
}

mkstartlist() {
    echo "  <div id=\"container\">"
    echo "    <ul id=\"thumbs\">"
}

mkendlist() {
    echo "    </ul>"
    echo "  </div>"
}

listalbums() {
    find "$opt_album_dir" -name index.html
}

##
## @brief Build a thumbnail item.
## @param $1 Destination album url
## @param $2 Destination album name
## @param $3 Thumbnail image url
albumitem() {
    echo "      <li class=\"clearfix\">"
    echo "        <img src=\"$3\" />"
    echo "        <div class=\"meta\">"
    echo "          <h4>what?</h4>"
    echo "          <span><a href=\"$1\">$2</a></span>"
    echo "        </div>"
    echo "      </li>"
}

albumname() {
    echo "album name"
}

albumimg() {
    echo "http://placehold.it/150x200"
}

mkheader
mkstartlist
for album in $(listalbums) ; do
    album_name=$(albumname "$album")
    album_img=$(albumimg  "$album")
    albumitem "${album}" "${album_name}" "${album_img}"
done
mkendlist
mkfooter
