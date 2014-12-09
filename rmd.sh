#!/bin/bash

if [ -e /tmp/content.log -o -e /tmp/distent.log -o checksums.log ]
then	
	echo "error: temporary files still exist..."
	exit
fi

touch /tmp/content.log /tmp/distent.log /tmp/checksums.log
tree -f -i --noreport | grep "[^~]$" >/tmp/distent.log

for ((a=`wc -l < /tmp/distent.log`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" /tmp/distent.log`

	if [ -f "$c" ]; then		
		echo "$c" >>/tmp/content.log
	fi
done

for ((a=`wc -l < /tmp/content.log`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" /tmp/content.log`
	cat "$c" | md5sum | sed "s/ -//" >> /tmp/checksums.log
done

for ((a=`wc -l < /tmp/checksums.log`,b=1;b<a;b++)); do
	let "c=$b+1"
	d=`sed -n "$b p" /tmp/checksums.log`

	for ((;c<=a;c++));do
		if [ `sed -n "$c p" /tmp/checksums.log` == $d ]; then
			d=`sed -n "$b p" /tmp/content.log`
			e=`sed -n "$c p" /tmp/content.log`

			cmp -s -i 0 "$d" "$e"
			if (($?==0)); then
				rm "$d"
				break
			fi
		fi
   	done
done

rm /tmp/distent.log /tmp/content.log  /tmp/checksums.log
