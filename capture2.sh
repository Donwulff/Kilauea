#!/bin/sh
CAMS="TL-10 TL-11 LAVA VTEC"

FIFO=`pwd`/indexque.fifo
if [ ! -p $FIFO ];
then
  mkfifo $FIFO
fi

for cam in $CAMS;
  do mkdir -p ${cam}cam/tmp
done

PATH=$PATH:/usr/loca/bin

while true;
do
  for cam in $CAMS;
  do
    cd ${cam}cam
    mkdir -p bad
    cd tmp
    if [ "${cam}" = "LAVA" ];
    then
      IMG=image.jpg
      wget -N http://lavacam.org/image.jpg
    else
      if [ "${cam}" = "VTEC" ]
      then
        IMG=latest_rti.gif
        wget -N https://iono.jpl.nasa.gov/RT/latest_rti.gif
      else
        IMG=${cam}.jpg
        wget -N http://images.punatraffic.com/SnapShot/640x480/${IMG}
      fi
    fi
    cd ..
    EXT=${IMG##*.}
    IMG=tmp/$IMG
    if ! cmp `ls -1tr *.${EXT} | tail -1` ${IMG};
    then
      name=${cam}_`TZ=HST stat -c%y ${IMG} | cut -c1-19 | tr " :" "__"`.${EXT}
      if [ -f ${IMG} ] && [ ! -f $name ];
      then
        echo "Checking integrity"
        if ! convert ${IMG} -define jpeg:size=256x256 -geometry 128x tmp.png 2>&1 | grep "convert";
        then
          mv tmp.png MT.png
          cp -a ${IMG} $name
          if [ $(( `stat -c "%Z" $name` / 60 % 10 )) -gt 7 ];
          then
            echo -e "${cam}cam\t$name" >$FIFO &
          fi
        else
          cp -a ${IMG} bad/$name
        fi
      fi
    fi
    cd ..
  done
  echo "Sleeping..."
  sleep 7
done
