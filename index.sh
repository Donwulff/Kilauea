#!/bin/bash

# set -v

# Get the image pattern to process
#day="*"
#day=`ls -1 *_20*-*.jpg | cut -d'_' -f1-2 | tail -1`
# Processes last hour only
#day=`ls -1 *_20*-*.jpg | cut -d'_' -f1-3 | tail -1`
day=`echo $1 | cut -d'_' -f1-3 | tail -1`

echo -n "Camera: "
pwd
echo "Image:  $1"
echo "Mask:   $day"

PATH=$PATH:/usr/local/bin

# Split it into hours and create a strip for each hour
mkdir -p gallery
ls -1 ${day}_*.jpg ${day}_*.gif | cut -d'_' -f1-3 | uniq | xargs -IX montage -define jpeg:size=128x128 'X_*' -tile x1 -geometry x64+1+1 gallery/X.html
for p in gallery/*.png;
do
  convert $p ${p%%.png}.jpg
  rm -f $p
done

# Combine hourly strips into a day
echo "<!DOCTYPE html><html><head><style>ul { font-size: large; line-height: 200%; }</style></head><body><p>All times are in HST Hawai'i Standard Time (UTC -10:00), no DST.</p><ul>" > index.html
ls -1r *_20*-*.jpg *_20*-*.gif \
  | cut -d'_' -f1-2 | uniq \
  | xargs -IX bash -c 'egrep -h "(title|img|map|area)" gallery/X_*.html | sed -r "s/\.png/\.jpg/;s/<title>[^_]*_[^_]*_(.*)<\/title>/<br \/><div>\1:00<\/div>/" > X.html; echo "<li><a href=\"X.html\">X</a></li>" >> index.html'
echo "</ul></body></html>" >> index.html
rm -f *.shtml
echo "Done"
