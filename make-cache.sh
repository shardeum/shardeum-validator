#!/bin/bash

cd npm-cache
for PKG in `cat ../pkg-list.txt`; do 
	wget "$PKG"
done
cd ..

