#!/bin/bash

if [ $# -ge 1 ]; then
	rec=`echo $* | grep -o 'r'`
	ver=`echo $* | grep -o 'v'`
fi


if [ -e ~/.content.log -o -e ~/.distent.log -o -e ~/.checksums.log -o -e ~/.sorted.log ]; then
	echo "error: temporary files still exist..." >/dev/stderr
	if [ "$ver" = 'v' ]; then
		echo "Is another instance of this script still running or was the last one not terminated well?"
		echo "For running this script, delete ~/.content.log, ~/.checksums.log, ~/.sorted.log and ~/.distent.log and restart this script."
	fi
	exit 1
fi

touch ~/.content.log ~/.distent.log ~/.checksums.log ~/.sorted.log

if [ "$rec" = 'r' ]; then
	tree -f -i --noreport | grep "[^~.]$" >~/.distent.log
else
	ls | grep "[^~.]$" >~/.distent.log
fi

if [ "$ver" = 'v' ]; then
	echo "Starting to check subfolders"
fi

for ((a=`wc -l < ~/.distent.log`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" ~/.distent.log`

	if [ -f "$c" ]; then		
		echo "$c" >>~/.content.log
	fi
done

if [ "$ver" = 'v' ]; then
	echo "Generating checksums"
fi

for ((a=`wc -l < ~/.content.log`,b=1;b<=a;b++)); do
	c=`sed -n "$b p" ~/.content.log`
	cat "$c" | md5sum | sed "s/ -//" >> ~/.checksums.log
done

paste ~/.checksums.log ~/.content.log >~/.distent.log
sort ~/.distent.log >~/.sorted.log


if [ "$ver" = 'v' ]; then
	cat ~/.content.log
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
fi
for ((a=`wc -l < ~/.checksums.log`,b=1,c=2;c<=a;)); do
	d=`sed -n "$b p" ~/.sorted.log | awk -e '{ print $1 }'`
	e=`sed -n "$c p" ~/.sorted.log | awk -e '{ print $1 }'`

	if [ "$ver" = 'v' ]; then
		echo "$d, number $b of $a"
	fi

	if [ $d == $e ]; then
		f=`cat ~/.sorted.log | sed -n "${b}s/[0-9a-f]\+ \t//p"`
		g=`cat ~/.sorted.log | sed -n "${c}s/[0-9a-f]\+ \t//p"`
		cmp -s "$f" "$g"
		if(($?==0));then
			if [ "$ver" == 'v' ]; then
				echo "Deleting $g, keeping $f."
			fi
			rm $g
		fi
		let "c=$c+1"
	else
		let "b=$c"
		let "c=$b+1"
	fi
done

rm ~/.distent.log ~/.content.log  ~/.checksums.log ~/.sorted.log

exit 0
