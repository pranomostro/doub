#!/bin/bash

touch content.log distent.log checksums.log
tree -f -i --noreport | grep "[^~]$" >distent.log

echo "Starting to check subfolders"

for ((a=`wc -l < distent.log`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" distent.log`

	if [ -f "$c" ]; then		
		echo "$c" >>content.log
	fi
done

echo "Generating checksums"

for ((a=`wc -l < content.log`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" content.log`
	cat "$c" | md5sum | sed "s/ -//" >> checksums.log
done

cat content.log
echo "Press a key to continue"
read

echo ""
echo "Checking the sums (and if they match, the files)"
echo "Warning, could be slow..."

	cat<<\EOF
The Unix philosophy tells me that I should give you somthing to read while you are waiting
for the result of this so unbearably slow program.
Don't be angry. The first version took 23 hours for around 40 giagabyte, and that one used cmp.
I tried to make it faster.
And the bash is really slow...when you are used to C, like I am. But what can I do?
I would like to just show you the checksums of your files, That would show you the progress.
Yeah, somthing like [checksum], number [number1] of [total] would be great. Okay, let's do this!

And by the way, if you want to tell me that I suck and my programs are slow, just mail me (a.regenfuss@gmx.de).

I will try to reply before the earth falls into the sun.

EOF

for ((a=`wc -l < checksums.log`,b=1;b<a;b++)); do
	let "c=$b+1"
	d=`sed -n "$b p" checksums.log`

	echo "$d, number $b of $a"

	for ((;c<=a;c++));do
		if [ `sed -n "$c p" checksums.log` == $d ]; then
			d=`sed -n "$b p" content.log`
			e=`sed -n "$c p" content.log`

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

rm distent.log content.log  checksums.log

exit 0
