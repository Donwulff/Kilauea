#!/bin/sh
CAMS="KEcam KWcam KIcam K2cam F1cam SO2cam PScam PNcam PTcam PEcam PWcam R3cam PGcam HPcam POcam MUcam MOcam SPcam MLcam MTcam M1cam M2cam M3cam"

FIFO=`pwd`/indexque.fifo
if [ ! -p $FIFO ];
then
  mkfifo $FIFO
fi

for cam in $CAMS;
  do mkdir -p $cam
done

PATH=$PATH:/usr/loca/bin

while true;
do
  for cam in $CAMS;
  do
    EXT=jpg
    IMG=M.jpg
    cd ${cam}
    mkdir -p bad
    wget -N https://volcanoes.usgs.gov/observatories/hvo/cams/${cam}/images/${IMG}
    if [ ! -f MT.png ] | [ ${IMG} -nt MT.png ];
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
          /bin/echo -e "$cam\t$name" >$FIFO &
        else
          cp -a ${IMG} bad/$name
        fi
      fi
    fi
    cd ..
  done
  echo "Sleeping..."
  sleep 29
done
