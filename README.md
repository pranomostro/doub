Find duplicate files
===================

There are already lots of programs which lint your filesystem. Some of
these include a way to search and delete duplicate files. This is an
attempt to write a small and simple program that just prints duplicate
files. This is a much more flexible way of dealing with duplicate files,
the result can be parsed and any command can be applied with xargs.

Requirements
------------

rc (the plan9 shell), and some basic unix utilities.

Installation
------------

It is as simple as typing

	make install

License
-------

[MIT license](./LICENSE).
