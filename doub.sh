#!/bin/bash

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

for ((a=`wc -l < $sum`,b=1,c=2;c<=a;)); do
	d=`sed -n "$b p" $srt | awk -e '{ print $1 }'`
	e=`sed -n "$c p" $srt | awk -e '{ print $1 }'`

	if [ $d == $e ]; then
		f=`cat $srt | sed -n "${b}s/[0-9a-f]\+ \t//p"`
		g=`cat $srt | sed -n "${c}s/[0-9a-f]\+ \t//p"`

		if cmp -s "$f" "$g"; then echo $g;fi

		let "c=$c+1"
	else
		let "b=$c"
		let "c=$b+1"
	fi
done

rm $fil $raw $sum $srt

exit 0
