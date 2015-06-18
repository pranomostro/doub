#!/bin/bash

set -eo pipefail

until [ -e "$fil" -a -e "$raw" -a -e "$sum" -a -e "$srt" ]; do
	fil=`echo $RANDOM | md5sum | sed 's/ .*//' | sed 's/.*/\/tmp\/&/'`
	raw=`echo $RANDOM | md5sum | sed 's/ .*//' | sed 's/.*/\/tmp\/&/'`
	sum=`echo $RANDOm | md5sum | sed 's/ .*//' | sed 's/.*/\/tmp\/&/'`
	srt=`echo $RANDOM | md5sum | sed 's/ .*//' | sed 's/.*/\/tmp\/&/'`
	touch $fil $raw $sum $srt
done

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

len=`wc -l "$srt" | awk '{ print $1 }'`

for ((a=1; a<"$len"; a++)); do
	b=`expr "$a" + 1`

	sum1=`sed -n "$a"p "$srt" | awk '{ print $1 }'`
	sum2=`sed -n "$b"p "$srt" | awk '{ print $1 }'`

	if [ "$sum1" = "$sum2" ]; then
		echo -n `sed -n "$a"p "$srt" | awk '{ print $2 }'`
	fi

	while [ "$sum1" = "$sum2" ]; do
		b=`expr "$b" + 1`

		sum2=`sed -n "$b"p "$srt" | awk '{ print $1 }'`

		if [ "$sum1" = "$sum2" ]; then
			echo -n `sed -n "$b"p "$srt" | awk '{ print $2 }'`
		fi
	done

	if [ "$sum1" = "$sum2" ]; then echo -e '\n'; fi

	a="$b"
done

rm $fil $raw $sum $srt

exit 0
