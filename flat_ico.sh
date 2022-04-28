#!/bin/bash

set -e

declare -A colors
colors['products']='#F25C05'
colors['convenience']='#00a0a4'
colors['services']='#2a62ac'
colors['safety']='#e42224'
colors['mobility']='#008ecf'
colors['amenity']='#2a62ac'
colors['remarkable']='#e50980'
colors['culture']='#76009e'
colors['hosting']='#99163a'
colors['catering']='#F5B700'
colors['leisure']='#00A757'
colors['public_landmark']='#1D1D1B'
colors['shopping']='#808080'
default_color='rgba(255, 255, 255, 1)'



rm -fr /tmp/ico_i && mkdir /tmp/ico_i
rm -fr /tmp/ico && mkdir /tmp/ico
cd icones:pictos:vectoriel
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
  sed -i 's/fill:[^;]*/fill:rgb(30%,30%,30%)/g' "/tmp/ico/$OUT_B"

  C=${colors[$SUPER_CLASS]}
  C=${C:-$default_color}

  OUT_B=${OUT/.svg/◯.svg}
  rsvg-convert --keep-aspect-ratio $RESIZE_17 -f svg "$ico" -o "/tmp/ico_i/$OUT_B"
  WH=`identify -format '%w-%h' "/tmp/ico_i/$OUT_B"`
  W=${WH%-*}
  H=${WH#*-}

  sed -i "s/fill:[^;]*/fill:rgb(30%,30%,30%)/g" "/tmp/ico_i/$OUT_B"

  OUT_W=${OUT/.svg/⬤.svg}
  sed "s/fill:rgb(30%,30%,30%)/fill:#FFFFFF/g" < "/tmp/ico_i/$OUT_B" > "/tmp/ico_i/$OUT_W"

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
