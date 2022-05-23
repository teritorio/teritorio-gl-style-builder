#!/bin/bash

set -e

STYLE_DIR=$1

source $STYLE_DIR/.env

curl https://vecto.teritorio.xyz/data/teritorio-${THEME}-ontology-latest.json > teritorio-${THEME}-ontology.json
curl https://drive.teritorio.fr/index.php/s/FWntdw9fF3qnLW7/download > icones_pictos_vectoriel_flat.zip

rm -fr 'icones:pictos:vectoriel_flat'
unzip icones_pictos_vectoriel_flat.zip

echo "Duplicates SVG content:"
find icones:pictos:vectoriel_flat | xargs md5sum | sort | uniq -w 32 -D

echo "Duplicate names in icons/extra"
find icones:pictos:vectoriel_flat | cut -d '/' -f 3 | sort | uniq -D

rm -fr "icones:pictos:vectoriel_flat/extra"

rm -fr icons_tree
bash -c "`ruby hierarchy.rb teritorio-${THEME}-ontology.json icones\:pictos\:vectoriel_flat/icons icons_tree`"

ruby flat_ico.rb teritorio-${THEME}-ontology.json icons_tree

rm -f $STYLE_DIR/icons/*•*
rm -f $STYLE_DIR/icons/*◯*
rm -f $STYLE_DIR/icons/*⬤*
cp /tmp/ico/* $STYLE_DIR/icons/
