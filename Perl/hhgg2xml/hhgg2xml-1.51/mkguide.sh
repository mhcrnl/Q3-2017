#!/bin/sh

if [ "x$1" == "x" ]; then
    echo "Syntax: mkguide [Palm|Win32]"
    exit
fi

hhgg2xml --single --mode=TRML_$1 C0.h2g2
hhgg2xml --single --mode=TRML_$1 A*.h2g2
hhgg2xml --single --mode=TRML_$1 C*.h2g2
