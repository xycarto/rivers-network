import os
os.environ['USE_PYGEOS'] = '0'
import geopandas as gp
from osgeo import gdal

# python3 src/clip-dem-by-watershed.py 

def main():
    
    watersheds = gp.read_file(WATERSHEDS)
    
    for ind, row in watersheds.iterrows():
        if ind == 285:
            tmp_gpkg = f"{OUT_DIR}/tmp.gpkg"
            out_tif = f"{OUT_DIR}/test.tif"
            gdf = gp.GeoDataFrame(geometry=[row.geometry], crs=2193)
            gdf.to_file(tmp_gpkg, driver="GPKG")
            gdal.Warp(
                out_tif,
                VRT,
                cutlineDSName = tmp_gpkg,
                cropToCutline = True,
                callback=gdal.TermProgress_nocb
            )

if __name__ in "__main__":
    DEM_DIR = "data/nztm/raster/dem_clip_nztm"
    WATERSHEDS = "data/nztm/vector/sea-draining-catchment/merged-watershed.gpkg"
    OUT_DIR = "data/nztm/raster/dem-watershed-clips"
    VRT = f"{DEM_DIR}/dem.vrt"    
    
    os.makedirs(OUT_DIR, exist_ok=True)
    
    main()