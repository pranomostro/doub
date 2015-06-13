#!/bin/bash

until [ -e "$raw" -a -e "$fil" -a -e "$sum" -a -e "$srt" ]; do
	con=`echo $RANDOM | md5sum | sed 's/ .*//' | sed 's/.*/\/tmp\/&/'`
	dis=`echo $RANDOM | md5sum | sed 's/ .*//' | sed 's/.*/\/tmp\/&/'`
	sum=`echo $RANDOm | md5sum | sed 's/ .*//' | sed 's/.*/\/tmp\/&/'`
	srt=`echo $RANDOM | md5sum | sed 's/ .*//' | sed 's/.*/\/tmp\/&/'`
	touch $raw $fil $sum $srt
done

dir="$1"; rec="$2"

if [ "$rec" = '-r' ]; then
	du -a $dir | sed 's/^[0-9]\+\t//' | sed '$d' >$fil
else
	ls $dir >$fil
fi

for ((a=`wc -l < $fil`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" $fil`

	if [ -f "$c" ]; then
		echo "$c" >>$raw
	fi
done

for ((a=`wc -l < $raw`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" $raw`
	cat "$c" | md5sum | sed "s/ -//" >> $sum
done

paste $sum $raw >$fil
sort $fil >$srt

for ((a=`wc -l < $srt`,b=1,c=2;c<=a;)); do
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

rm $raw $fil $sum $srt

exit 0
