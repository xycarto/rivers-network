#!/bin/bash

TIF=$1
BASE=$( basename $TIF .tif)
DATA_DIR="data"
IN_POLY="${DATA_DIR}/clipped-vectors/polygons-${BASE}.gpkg"
IN_LINES="${DATA_DIR}/clipped-vectors/lines-${BASE}.gpkg"
BURN_DIR="data/burns"
POLY_BURN="${BURN_DIR}/vecburn-poly-${BASE}.tif"
LINE_BURN="${BURN_DIR}/vecburn-line-${BASE}.tif"
BURN_TMP="${BURN_DIR}/poly-burn-${BASE}-tmp.tif"
BURN="${BURN_DIR}/poly-burn-${BASE}.tif"

mkdir -p $BURN_DIR

echo "Getting extents..."
xmin=$(gdalinfo -json $TIF | jq .cornerCoordinates.lowerLeft[0])
ymin=$(gdalinfo -json $TIF | jq .cornerCoordinates.lowerLeft[1])
xmax=$(gdalinfo -json $TIF | jq .cornerCoordinates.upperRight[0])
ymax=$(gdalinfo -json $TIF | jq .cornerCoordinates.upperRight[1])
res=$(gdalinfo -json $TIF | jq .geoTransform[1])

echo "Rasterizing vectors..."
gdal_rasterize -burn 4 -ot Float32 -tr ${res} ${res} -te $xmin $ymin $xmax $ymax -a_nodata 0 $IN_POLY $POLY_BURN
gdal_rasterize -burn 1.5 -at -ot Float32 -tr ${res} ${res} -te $xmin $ymin $xmax $ymax -a_nodata 0 $IN_LINES $LINE_BURN

gdal_edit.py -unsetnodata $POLY_BURN
gdal_edit.py -unsetnodata $LINE_BURN

gdal_calc.py --overwrite -A $TIF -B $POLY_BURN --calc="A-B" --extent=intersect --outfile=$BURN_TMP
gdal_calc.py --overwrite -A $BURN_TMP -B $LINE_BURN --calc="A-B" --extent=intersect --outfile=$BURN

rm $POLY_BURN
rm $LINE_BURN
rm $BURN_TMP