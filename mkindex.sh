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
THUMB_WIDTH=250
THUMB_HEIGHT=250

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
    echo "  <meta name=\"author\" content=\"Yankel Scialom\">"
    echo "  <link rel=\"shortcut icon\" href=\"/favicon.ico\">"
    echo "  <link rel=\"icon\" href=\"/favicon.ico\">"
    echo "  <style>"
    echo "    ul {"
    echo "      list-style: none;"
    echo "      text-align: center;"
    echo "    }"
    echo ""
    echo "    .grid-item {"
    echo "      width: ${THUMB_WIDTH}px;"
    echo "      min-height: $(expr $THUMB_HEIGHT + 50)px;"
    echo "      border: 1px solid #000;"
    echo "      display: -moz-inline-stack;"
    echo "      display: inline-block;"
    echo "      vertical-align: top;"
    echo "      margin: 5px;"
    echo "      zoom: 1;"
    echo "      *display: inline;"
    echo "      _height: $(expr $THUMB_HEIGHT + 50)px;"
    echo "    }"
    echo ""
    echo "    .shadowing {"
    echo "      -webkit-box-shadow: 1px 0px 4px #8f8e88;"
    echo "      -moz-box-shadow: 1px 0px 4px #8f8e88;"
    echo "      -o-box-shadow: 1px 0px 4px #8f8e88;"
    echo "      box-shadow: 1px 0px 4px #8f8e88;"
    echo "    }"
    echo ""
    echo "    .shadowing:hover {"
    echo "      -webkit-box-shadow: 4px 0px 8px #8f8e88;"
    echo "      -moz-box-shadow: 4px 0px 8px #8f8e88;"
    echo "      -o-box-shadow: 4px 0px 8px #8f8e88;"
    echo "      box-shadow: 4px 0px 8px #8f8e88;"
    echo "    }"
    echo ""
    echo "    .interactive {"
    echo "      opacity: 0.7;"
    echo "      -webkit-transition: all 0.4s ease;"
    echo "      -moz-transition: all 0.4s ease;"
    echo "      -ms-transition: all 0.4s ease;"
    echo "      -o-transition: all 0.4s ease;"
    echo "      transition: all 0.4s ease;"
    echo "    }"
    echo "    "
    echo "    .interactive:hover {"
    echo "      opacity: 1.0;"
    echo "    }"
    echo ""
    echo "    p {"
    echo "      text-align: center;"
    echo "      position: relative;"
    echo "      width: ${THUMB_WIDTH}px;"
    echo "    }"
    echo "  </style>"
    echo "</head>"
    echo ""
    echo "<body>"
}

mkfooter() {
    echo "</body>"
    echo "</html>"
}

mkstartlist() {
    echo "  <ul id=\"thumbs\">"
}

mkendlist() {
    echo "  </ul>"
}

listalbums() {
    find "$opt_album_dir" -name index.html | sed 's@/\?index.html$@@' | sort
}

##
## @brief Build a thumbnail item.
## @param $1 Destination album url
## @param $2 Destination album name
## @param $3 Thumbnail image url
albumitem() {
    echo "    <li class=\"grid-item shadowing interactive\">"
    echo "      <a href=\"$1\" title=\"$2\">"
    echo "        <img src=\"$3\" alt=\"album $2\" />"
    echo "        <p>$2</p>"
    echo "      </a>"
    echo "    </li>"
}

albumname() {
    ./urldecode.sh "$(basename "${1%%/index.html}")"
}

##
## @brief Get the album's representative image url
## @param $1 Destination album url
albumimg() {
    local thumb=$(echo -n "$1"/files/index.* | cut -d' ' -f1)

    if [ ! -f "${thumb}" ]; then
        tmpfile=$(tempfile)
        find "$1/files" -type f -exec file {} \; | grep -o -P '^.+: \w+ image' | cut -d: -f1 > $tmpfile
        thumb=$(head -n1 $tmpfile)
        rm $tmpfile
        ./mkthumb.sh "${thumb}" ${THUMB_WIDTH} ${THUMB_HEIGHT}
        thumb=$(echo -n "$1"/files/index.* | cut -d' ' -f1)
    fi
    echo ${thumb}
}

mkheader
mkstartlist
for album in $(listalbums) ; do
    album_name=$(albumname "$album")
    album_img=$(albumimg  "$album")
    albumitem "${album}/index.html" "${album_name}" "${album_img}"
done
mkendlist
mkfooter
