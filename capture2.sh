#!/bin/sh

# These cams have different base URL's, may update more frequently, and not set timestamp correctly.
# Consequently run in faster loop, compare result to last image, and throttle gallery updates.

CAMS="LAVA VTEC TL-10 TL-11"

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
    if ! cmp ${IMG} last;
    then
      tstamp=`TZ=HST stat -c%y ${IMG} | cut -c1-19 | tr " :" "__"`
      dstamp=`echo "$tstamp" | cut -c1-10`
      name=${cam}_${tstamp}.${EXT}
      if [ -f ${IMG} ] && [ ! -f $name ];
      then
        echo "Checking integrity"
        if ! convert ${IMG} -define jpeg:size=256x256 -geometry 128x tmp.png 2>&1 | grep "convert";
        then
          mv tmp.png MT.png
          mkdir -p $dstamp
          cp -a ${IMG} $dstamp/$name
          ln -sf $dstamp/$name last
          if [ $(( `stat -c "%Z" ${IMG}` / 60 % 10 )) -gt 6 ];
          then
            /bin/echo -e "${cam}cam\t$name" >$FIFO &
          fi
        else
          cp -a ${IMG} bad/$name
          ln -sf bad/$name last
        fi
      fi
    fi
    cd ..
  done
  echo "Sleeping..."
  sleep 3
done
