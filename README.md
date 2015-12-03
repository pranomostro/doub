Find duplicate files
===================

There are already lots of programs which lint
your filesystem. Some of these include a way to
search and delete duplicate files. This is an attempt to
write a small and simple program that just prints
duplicate files. This is a much more flexible way
of dealing with duplicate files, the result can be parsed
and any command can be applied with xargs.

Requirements
------------

rc (the plan 9 shell), and some sort of coreutils.
It hasn't been tested extensively on different platforms,
but it does not use GNU flags or any special behaviour,
it should be fine on every system.

Installation
------------

It is as simple as typing

	make install

License and Thanks
------------------

As always, the MIT license is the license of choice.
Thanks to the people at suckless.org. Their work
helped a lot to develop doub, even if just indirectly.
