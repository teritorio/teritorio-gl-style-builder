#!/bin/bash

set -e

STYLE_DIR=$1

source $STYLE_DIR/.env

curl "$DOC/gviz/tq?tqx=out:csv&sheet=POI_liste_teritorio" > data-vectoriel-$THEME.csv
curl https://drive.teritorio.fr/index.php/s/CXyoE3ZNfMBnbMp/download > icones_pictos_vectoriel.zip

rm -fr 'icones:pictos:vectoriel'
unzip icones_pictos_vectoriel.zip
rm -fr "icones:pictos:vectoriel/reserve"
rm -fr "icones:pictos:vectoriel/extra"

source $STYLE_DIR/colors.sh
bash flat_ico.sh

rm -f $STYLE_DIR/icons/*•*
rm -f $STYLE_DIR/icons/*◯*
rm -f $STYLE_DIR/icons/*⬤*
cp /tmp/ico/* $STYLE_DIR/icons/

ruby unmatched.rb $STYLE_DIR $THEME < data-vectoriel-$THEME.csv
