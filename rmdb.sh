#!/bin/bash

if [ -e /tmp/content.log -o -e /tmp/distent.log -o -e /tmp/checksums.log ]
then	
	echo "error: temporary files still exist..."
	echo "Is another instance of this script still running or was the last one not terminated well?"
	echo "For running this script, delete /tmp/content.log, /tmp/tmp/checksums.log and /tmp/distent.log and restart this script."
	exit 1
fi

touch /tmp/content.log /tmp/distent.log /tmp/tmp/checksums.log

if [ $1 == -r ]; then
	tree -f -i --noreport | grep "[^~.]$" >/tmp/distent.log
else
	ls | grep "[^~.]$" >/tmp/distent.log
fi

echo "Starting to check subfolders"

for ((a=`wc -l < /tmp/distent.log`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" /tmp/distent.log`

	if [ -f "$c" ]; then		
		echo "$c" >>/tmp/content.log
	fi
done

echo "Generating checksums"

for ((a=`wc -l < /tmp/content.log`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" /tmp/content.log`
	cat "$c" | md5sum | sed "s/ -//" >> /tmp/checksums.log
done

cat /tmp/content.log
echo "Press a key to continue"
read

echo ""
echo "Checking the sums (and if they match, the files)"
echo "Warning, could be slow..."

	cat<<\EOF
The Unix philosophy tells me that I should give you somthing to read while you are waiting
for the result of this so unbearably slow program.
Don't be angry. The first version took 23 hours for around 40 gigabyte, and that one used cmp.
I tried to make it faster.
And the bash is really slow...when you are used to C, like I am. But what can I do?
I would like to just show you the checksums of your files, That would show you the progress.
Yeah, somthing like [checksum], number [number1] of [total] would be great. Okay, let's do this!

And by the way, if you want to tell me that I suck and my programs are slow, just mail me (a.regenfuss@gmx.de).

I will try to reply before the earth falls into the sun.

EOF

for ((a=`wc -l < /tmp/checksums.log`,b=1;b<a;b++)); do
	let "c=$b+1"
	d=`sed -n "$b p" /tmp/checksums.log`

	echo "$d, number $b of $a"

	for ((;c<=a;c++));do
		if [ `sed -n "$c p" /tmp/checksums.log` == $d ]; then
			d=`sed -n "$b p" /tmp/content.log`
			e=`sed -n "$c p" /tmp/content.log`

			cmp -s -i 0 "$d" "$e"
			if (($?==0)); then
				echo "Deleting $d"
				echo "Keeping $e"
				echo ""
				rm "$d"
				break
			fi
		fi
   	done
done

rm /tmp/distent.log /tmp/content.log  /tmp/checksums.log

exit 0
