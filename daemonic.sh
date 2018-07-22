#!/bin/bash

FIFO=indexque.fifo
if [ ! -p $FIFO ];
then
  mkfifo $FIFO
fi

DIR=`pwd`

exec 3<> $FIFO

while true;
do
  read -u3 dir image
  cd $dir
    $DIR/index.sh $image
  cd ..
done
