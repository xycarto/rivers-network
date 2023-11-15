#!/bin/bash

# bash src/make-rivers.sh

DEM=$1
TIF_DIR="data/nztm/raster/dem-watershed-clips"
OUT_DIR="data/nztm/vector/rivers"

mkdir -p ${OUT_DIR}

list=$( find $TIF_DIR -name "*.tif" )

g.extension extension=r.hydrodem
g.extension extension=r.stream.order

for tif in ${list[@]}
do
    echo $tif
   
    r.in.gdal --overwrite input=${tif} output=dem
    g.region --overwrite raster=dem -p
    r.hydrodem -f input=dem memory=32000 output=hydrodem size=6 --overwrite
    # r.out.gdal input=hydrodem output="${OUT_DIR}/hydro-dem.tif" format=GTiff
    r.watershed elevation=hydrodem threshold=2500 accumulation=accumulation drainage=drainage stream=stream memory=32000 --overwrite
    r.stream.order stream_rast=stream direction=drainage elevation=hydrodem accumulation=accumulation stream_vect=stream_vect strahler=strahler memory=32000 --overwrite
    v.out.ogr input=stream_vect output="${OUT_DIR}/strahler.gpkg" type=line format=GPKG --overwrite
done

