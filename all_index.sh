#!/bin/bash
DIR=`pwd`
for i in *cam; do echo ">>>>>>>>> $i"; cd $i; ls *2018*.jpg | cut -d'_' -f1-3 | uniq | xargs -IX $DIR/move.pl X_00_00.jpg 1; cd ..; done

