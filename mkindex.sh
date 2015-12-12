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
    echo "      width: 300px;"
    echo "      min-height: 250px;"
    echo "      border: 1px solid #000;"
    echo "      display: -moz-inline-stack;"
    echo "      display: inline-block;"
    echo "      vertical-align: top;"
    echo "      margin: 5px;"
    echo "      zoom: 1;"
    echo "      *display: inline;"
    echo "      _height: 250px;"
    echo "    }"
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
    echo "      opacity: 0.6;"
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
    echo "      width: 300px;"
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
    find "$opt_album_dir" -name index.html | sort
}

##
## @brief Build a thumbnail item.
## @param $1 Destination album url
## @param $2 Destination album name
## @param $3 Thumbnail image url
albumitem() {
    echo "    <li class=\"grid-item shadowing interactive\">"
    echo "      <a href=\"$1\" title=\"$2\">"
    echo "        <img src=\"http://placehold.it/300x200\" alt=\"album $2\" />"
    echo "        <p>$2</p>"
    echo "      </a>"
    echo "    </li>"
}

albumname() {
    ./urldecode.sh "$(basename "${1%%/index.html}")"
}

albumimg() {
    echo "http://placehold.it/300x200"
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
