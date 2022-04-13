#!/bin/env bash

cd sysstat
for i in $(git tag); do 
	git checkout .
	git checkout $i
	make clean; ./configure 
	grep '<sys/sysmacros.h>' ioconf.c || sed  -i '/#include <sys\/stat.h>/a #include <sys/sysmacros.h>' ioconf.c
	make clean;
	make;
	mv sadf sadf-$i
	git checkout . 
done
