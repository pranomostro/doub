#!/bin/bash

until [ -e "$con" -a -e "$dis" -a -e "$sum" -a -e "$srt" ]; do
	con=`echo $RANDOM | md5sum | sed 's/ .*//' | sed 's/.*/\/tmp\/&/'`
	dis=`echo $RANDOM | md5sum | sed 's/ .*//' | sed 's/.*/\/tmp\/&/'`
	sum=`echo $RANDOm | md5sum | sed 's/ .*//' | sed 's/.*/\/tmp\/&/'`
	srt=`echo $RANDOM | md5sum | sed 's/ .*//' | sed 's/.*/\/tmp\/&/'`
	touch $con $dis $sum $srt
done

dir="$1"; rec="$2"

if [ "$rec" = '-r' ]; then
	du -a $dir | sed 's/^[0-9]\+\t//' | sed '$d' >$dis
else
	ls $dir >$dis
fi

for ((a=`wc -l < $dis`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" $dis`

	if [ -f "$c" ]; then
		echo "$c" >>$con
	fi
done

for ((a=`wc -l < $con`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" $con`
	cat "$c" | md5sum | sed "s/ -//" >> $sum
done

paste $sum $con >$dis
sort $dis >$srt

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

rm $con $dis $sum $srt

exit 0
