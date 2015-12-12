#!/bin/bash

urldecode() {
    local url_encoded=$(echo "$1" | sed -e 's/+/ /g' -e's/=\([0-9A-Fa-f]\{2\}\)/%00\1/g')
    printf '%b' "${url_encoded//%/\\u}"
}

urldecode "$1"
