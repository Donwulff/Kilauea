#!/bin/bash
for i in *cam; do echo ">>>>>>>>> $i"; cd $i; ls *2018* | cut -d'_' -f1-3 | uniq | xargs -IX ../index.pl X_00_00.jpg 2; cd ..; done

