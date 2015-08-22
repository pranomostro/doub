#!/usr/bin/env bash

fil='/tmp/fil'.$$
raw='/tmp/raw'.$$
sum='/tmp/sum'.$$
srt='/tmp/srt'.$$

touch "$fil" "$raw" "$sum" "$srt"

for i in "$@"; do
	case "$i" in
	-r)	rec='1';;
	*)	dir="$i"
	esac
done

if [ "$rec" = '1' ]; then
	du -a "$dir" | sed 's/^[0-9]\+\t//' | sed '$d' >"$raw"
else
	ls "$dir" >"$raw"
fi

for c in `cat "$raw"`; do
	if [ -f "$c" ]; then
		echo "$c" >>"$fil"
	fi
done

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
