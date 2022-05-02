#!/bin/bash

set -e

INPUT=$1
COLORS=$2

source $COLORS

rm -fr /tmp/ico_i && mkdir /tmp/ico_i
rm -fr /tmp/ico && mkdir /tmp/ico
cd $INPUT
find . -name "*.svg" | while read ico; do
  echo "$ico"
  OUT=${ico#.\/}
  SUPER_CLASS=${OUT%\/*}
  SUPER_CLASS=${SUPER_CLASS%.*}
  SUPER_CLASS=${SUPER_CLASS%\/*}
  OUT=${OUT//\//-}

  WH=`identify -format '%w-%h' "${ico}"`
  W=${WH%-*}
  H=${WH#*-}

  if (( H > W )); then
    RESIZE_11="-h 11"
    RESIZE_17="-h 17"
  else
    RESIZE_11="-w 11"
    RESIZE_17="-w 17"
  fi

  OUT_B=${OUT/.svg/•.svg}
  rsvg-convert --keep-aspect-ratio $RESIZE_11 -f svg "$ico" -o "/tmp/ico/$OUT_B"
  sed -i 's/fill=\"[^\"]*\"/fill=\"rgb(30%,30%,30%)\"/g' "/tmp/ico/$OUT_B"

  C=${colors[$SUPER_CLASS]}
  C=${C:-$default_color}

  OUT_B=${OUT/.svg/◯.svg}
  rsvg-convert --keep-aspect-ratio $RESIZE_17 -f svg "$ico" -o "/tmp/ico_i/$OUT_B"
  WH=`identify -format '%w-%h' "/tmp/ico_i/$OUT_B"`
  W=${WH%-*}
  H=${WH#*-}

  sed -i "s/fill=\"[^\"]*\"/fill=\"rgb(30%,30%,30%)\"/g" "/tmp/ico_i/$OUT_B"

  OUT_W=${OUT/.svg/⬤.svg}
  sed "s/fill=\"rgb(30%,30%,30%)\"/fill=\"#FFFFFF\"/g" < "/tmp/ico_i/$OUT_B" > "/tmp/ico_i/$OUT_W"

  X=$(((30-$W)/2))
  Y=$(((30-$H)/2))

  ruby -e "puts STDIN.read.gsub('<g transform=\"translate(1,1)\"></g>', '<g transform=\"translate(1,1)\">' + File.readlines('/tmp/ico_i/$OUT_B')[2..-2].join + '</g>')" < ../container.svg > "/tmp/ico/$OUT_B"
  sed -i "/tmp/ico/$OUT_B" \
    -e "s/translate(1,1)/translate($X,$Y)/" \
    -e "s/#ff0000/${C}/" \
    -e "s/#00ff00/#ffffff/"

  ruby -e "puts STDIN.read.gsub('<g transform=\"translate(1,1)\"></g>', '<g transform=\"translate(1,1)\">' + File.readlines('/tmp/ico_i/$OUT_W')[2..-2].join + '</g>')" < ../container.svg > "/tmp/ico/$OUT_W"
  sed -i "/tmp/ico/$OUT_W" \
    -e "s/translate(1,1)/translate($X,$Y)/" \
    -e "s/#00ff00/${C}/" \
    -e "s/#ff0000/#ffffff/"

done
