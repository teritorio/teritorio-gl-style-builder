#!/bin/bash

set -e

STYLE_DIR=$1

source $STYLE_DIR/.env

curl https://vecto-dev.teritorio.xyz/data/teritorio-${THEME}-ontology-dev.json > teritorio-${THEME}-ontology.json
curl https://drive.teritorio.fr/index.php/s/FWntdw9fF3qnLW7/download > icones_pictos_vectoriel_flat.zip

rm -fr 'icones:pictos:vectoriel_flat'
unzip icones_pictos_vectoriel_flat.zip
rm -fr "icones:pictos:vectoriel_flat/extra"

rm -fr icons_tree
bash -c "`ruby hierarchy.rb teritorio-${THEME}-ontology.json icones\:pictos\:vectoriel_flat/icons icons_tree`"

bash flat_ico.sh icons_tree $STYLE_DIR/colors.sh

rm -f $STYLE_DIR/icons/*•*
rm -f $STYLE_DIR/icons/*◯*
rm -f $STYLE_DIR/icons/*⬤*
cp /tmp/ico/* $STYLE_DIR/icons/
