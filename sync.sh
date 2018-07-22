#!/bin/bash
rsync -Kai jsantala@caelestic.org:/mnt/Kilauea/ . --ignore-existing --include '*cam/*_20*.jpg' --include '*cam/gallery/*.jpg' --include '*cam/*.html' --include '*cam/gallery/*.html' -f 'hide,! */' -e 'ssh -p221' --bwlimit=70
