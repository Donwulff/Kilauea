#!/bin/bash
for i in *cam; do echo ">>>>>>>>> $i"; cd $i; ../index.sh; cd ..; done

