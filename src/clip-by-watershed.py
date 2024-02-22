import os
import geopandas as gp
from osgeo import gdal

# python3 src/clip-dem-by-watershed.py 

def main():
    
    watersheds = gp.read_file(WATERSHEDS)
    lines = gp.read_file(LINES)
    polys = gp.read_file(POLYS)
    
    for ind, row in watersheds.iterrows():
        out_name = f"watershed-{str(ind)}"
        if ind == 285:
            tmp_gpkg = f"{DATA_DIR}/tmp.gpkg"
            out_tif = f"{OUT_RASTER}/{out_name}.tif"
            gdf = gp.GeoDataFrame(geometry=[row.geometry], crs=2193)
            gdf.to_file(tmp_gpkg, driver="GPKG")
            gdal.Warp(
                out_tif,
                VRT,
                cutlineDSName = tmp_gpkg,
                cropToCutline = True,
                xRes = 8,
                yRes = 8,
                callback=gdal.TermProgress_nocb
            )

            lines.clip(gdf).to_file(f"{OUT_VECTOR}/lines-{out_name}.gpkg")
            polys.clip(gdf).to_file(f"{OUT_VECTOR}/polygons-{out_name}.gpkg")            

            os.remove(tmp_gpkg)
            

if __name__ in "__main__":

    DATA_DIR = "data"
    PROCESSED = f"{DATA_DIR}/processed-vectors"
    DEM_DIR = f"{DATA_DIR}/dem-clip-nztm"
    WATERSHEDS = f"{DATA_DIR}/merged-watershed.gpkg"
    LINES = f"{PROCESSED}/merged-lines.gpkg"
    POLYS = f"{PROCESSED}/merged-polygons.gpkg"
    OUT_RASTER = f"{DATA_DIR}/clipped-dems"
    OUT_VECTOR = f"{DATA_DIR}/clipped-vectors"
    VRT = f"{DEM_DIR}/dem.vrt"    
    
    for d in [DATA_DIR, OUT_RASTER, OUT_VECTOR]:
        os.makedirs(d, exist_ok=True)
    
    main()