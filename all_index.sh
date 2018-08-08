#!/bin/bash
DIR=`pwd`
HOURS=48
HOST=ec2-user@caelestic.net
KEY=LightsailDefaultPrivateKey-us-east-2.pem
BW=70

for c in *cam;
do
  echo ">>>>>>>>> $c"
  # Sync any images we've missed
  echo "Local to remote"
  rsync -Kaik --no-owner --no-group -e "ssh -i $KEY" $c/ $HOST:/var/lib/data/Kilauea/$c/ --ignore-existing \
    --include "*-*-*/*.jpg" --include "*-*-*/*.gif" -f 'hide,! */' --bwlimit=$BW
  echo "Remote to local"
  rsync -Kaik --no-owner --no-group -e "ssh -i $KEY" $HOST:/var/lib/data/Kilauea/$c/ $c/ --ignore-existing \
    --include "*-*-*/*.jpg" --include "*-*-*/*.gif" -f 'hide,! */' --bwlimit=$BW
  if [ "$c" = "TL-10cam" ] || [ "$c" = "TL-11cam" ];
  then
    echo "Local cleanup"
    fdupes -o name -Nd `find $c -type d -name "*-*-*" | sort | tail -$(($HOURS/24+1)) | paste -s`
  fi
  if [ "$c" = "VTECcam" ];
  then
    EXT=gif
  else
    EXT=jpg
  fi
  cd $c
  ls -1 *2018* | cut -d'_' -f1-3 | uniq | tail -n $HOURS | xargs -IX $DIR/index.pl X_00_00.$EXT 2 256x256
  ls -1 *2018* | cut -d'_' -f1-3 | tail -1 | xargs -IX $DIR/index.pl X_00_00.$EXT 4 256x256
  cd ..
  rsync -Kaik --no-owner --no-group -e "ssh -i $KEY" $c/ $HOST:/var/lib/data/Kilauea/$c/ \
    --include "*.html" --include "gallery/*" -f 'hide,! */' --bwlimit=$BW
  if [ "$c" = "TL-10cam" ] || [ "$c" = "TL-11cam" ];
  then
    echo "Remote cleanup"
    ssh -i $KEY $HOST "cd /var/lib/data/Kilauea; fdupes -o name -Nd `find $c -type d -name \"*-*-*\" | sort | tail -$(($HOURS/24+1)) | paste -s`"
  fi
done

