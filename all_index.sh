#!/bin/bash
for i in *cam; do cd $i; ../index.sh; cd ..; done
