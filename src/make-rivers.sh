#!/bin/bash

TIF=$1
BASE=$( basename $TIF .tif)
DATA_DIR="data"
IN_VECTOR="${DATA_DIR}/clipped-vectors/lines-${BASE}.gpkg"
BURN_DIR="data/burns"
BURN="${BURN_DIR}/poly-burn-${BASE}.tif"
OUT_RIVERS="${DATA_DIR}/strahler"

mkdir -p ${OUT_RIVERS}

echo "Build extensions..."
g.extension operation=add extension=r.hydrodem url=grass-addons/r.hydrodem
g.extension operation=add extension=r.stream.order url=grass-addons/r.stream.order 

r.in.gdal --overwrite input=${BURN} output=dem
v.in.ogr --overwrite input=${IN_VECTOR} output=vec
g.region --overwrite raster=dem -p

# echo "Carving in river lines..."
# r.carve --overwrite raster=dem vector=vec output=carved_dem width=2 depth=1

echo "Making hydrodem..."
r.hydrodem -c input=dem memory=32000 output=hydrodem --overwrite

r.out.gdal format=GTiff input=hydrodem output="data/hydrodem-${BASE}.tif"

echo "Making watersheds..."
r.watershed elevation=hydrodem threshold=1000 accumulation=accumulation drainage=drainage stream=stream memory=32000 --overwrite

echo "Creating stream order..."
r.stream.order stream_rast=stream direction=drainage elevation=hydrodem accumulation=accumulation stream_vect=stream_vect strahler=strahler memory=32000 --overwrite

echo "Outputting Strahler vectors..."
v.out.ogr input=stream_vect output="${OUT_RIVERS}/strahler-${BASE}.gpkg" type=line format=GPKG --overwrite
