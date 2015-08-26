#!/usr/bin/env bash

IFS='
'

fil=`mktemp doub.XXXXXX`
raw=`mktemp doub.XXXXXX`
sum=`mktemp doub.XXXXXX`
srt=`mktemp doub.XXXXXX`

dir='.'

for i in "$@"; do
	case "$i" in
	-r)	rec='1';;
	*)	dir="$i"
	esac
done

if [ "$rec" = '1' ]; then
	find "$dir" -type f >"$fil"
else
	ls "$dir" >"$raw"

	for c in `cat "$raw"`; do
		if [ -f "$c" ]; then
			echo "$c" >>"$fil"
		fi
	done
fi

for c in `cat "$fil"`; do
	md5sum "$c" | sed "s/ [^ ]\+$//" >> "$sum"
done

paste "$sum" "$fil" >"$raw"
sort "$raw" >"$srt"

awk '{
	if (lastsum==$1) { printf("%s:",lastname); lasteq=1 }
	if (lastsum!=$1&&lasteq==1) { printf("%s\n", lastname); lasteq=0 }
	lastsum=$1; lastname=$2
}' "$srt"

rm "$fil" "$raw" "$sum" "$srt"

exit 0
