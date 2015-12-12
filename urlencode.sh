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

urlencode "$1"
