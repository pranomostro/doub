#!/bin/bash

set -eo pipefail

#Since bash doesn't know do { } while (); we have to do this.

fil=`echo /tmp/$RANDOM`; raw=`echo /tmp/$RANDOM`; sum=`echo /tmp/$RANDOM`; srt=`echo /tmp/$RANDOM`

while [ -e "$fil" -o -e "$raw" -o -e "$sum" -o -e "$srt" ]; do
	fil=`echo /tmp/$RANDOM`; raw=`echo /tmp/$RANDOM`; sum=`echo /tmp/$RANDOM`; srt=`echo /tmp/$RANDOM`
done

touch $fil $raw $sum $srt

dir="$1"; rec="$2"

if [ "$rec" = '-r' ]; then
	du -a $dir | sed 's/^[0-9]\+\t//' | sed '$d' >$raw
else
	ls $dir >$raw
fi

for ((a=`wc -l < $raw`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" $raw`

	if [ -f "$c" ]; then
		echo "$c" >>$fil
	fi
done

for ((a=`wc -l < $fil`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" $fil`
	cat "$c" | md5sum | sed "s/ -//" >> $sum
done

paste $sum $fil >$raw
sort $raw >$srt

awk '{
	if (lastsum==$1) { printf("%s ",lastname); lasteq=1 }
	if (lastsum!=$1&&lasteq==1) { printf("%s\n", lastname); lasteq=0 }
	lastsum=$1; lastname=$2
}' $srt

rm $fil $raw $sum $srt

exit 0
