#!/bin/sh

# RunScript.sh
# Spectrum3D
#
# Created by Garth Griffin on 5/12/10.
# Copyright Garth Griffin 2010. 

if [ $# = 0 ]; then
	echo "Usage: ./RunObjCScript <script.m>"
	exit 1
fi

infile=$1
executable=${infile%%.*}

gcc -framework Foundation -std=c99 $infile -o $executable
./$executable
rm -f $executable