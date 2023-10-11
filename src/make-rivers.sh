#!/bin/bash

# bash src/grass-route-distance.sh

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



# # Fill sinks
# fillDEM="filldem"
# directionDEM="directiondem"
# areasDEM="areasDEM"

# r.fill.dir input=dem output=$fillDEM direction=$directionDEM areas=$areasDEM --overwrite


# list=$(echo 1000000 500000 250000 100000 50000 25000 10000 5000 2500)
# for i in $list
# do
#     # Run watershed operation on fill sink raster
#     threshold=$i
#     accumulation=accumulation_${i}
#     drainage=drainage_${i}
#     stream=stream_${i}
#     basin=basin_${i}
#     r.watershed elevation=$fillDEM threshold=$threshold accumulation=$accumulation drainage=$drainage stream=$stream basin=$basin --overwrite

#     # Convert Basin (watershed) to vector format
#     basinVect=basinVect_${i}
#     r.to.vect input=$basin output=$basinVect type=area column=bnum --overwrite

#     # Export catchment to vector format
#     basinVectOut=${OUT_DIR}/catchment_${i}.gpkg
#     v.out.ogr input=$basinVect output=$basinVectOut type=area format=GPKG --overwrite

#     echo $basinVectOut >> ${LIST}
# done


