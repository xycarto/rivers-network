import os
import geopandas as gp
from osgeo import gdal

def main():
    
    lines = ["nz-canal-centrelines-topo-150k", "nz-river-name-lines-pilot"]
    polys = ["nz-lake-polygons-topo-150k", "nz-pond-polygons-topo-150k", "nz-river-polygons-topo-150k"]

    linedf = []
    id = 1
    for dir in lines:
        vector = gp.read_file(f"{VEC_DIR}/{dir}/{dir}.gpkg")
        for i, line in vector.iterrows():
            linedf.append(
                    {
                        'id': str(id),
                        'geometry': line.geometry
                    }
                )
            id += 1
        gdf_poly = gp.GeoDataFrame(linedf, crs=2193).to_file(f"{PROCESSED}/merged-lines.gpkg") 

    polydf = []
    id = 1
    for dir in polys:
        vector = gp.read_file(f"{VEC_DIR}/{dir}/{dir}.gpkg")
        for i, poly in vector.iterrows():
            polydf.append(
                    {
                        'id': str(id),
                        'geometry': poly.geometry
                    }
                )
            id += 1
        gdf_poly = gp.GeoDataFrame(polydf, crs=2193).to_file(f"{PROCESSED}/merged-polygons.gpkg") 

if __name__ == "__main__":

    DATA_DIR = "data"
    VEC_DIR = f"{DATA_DIR}/lds-new-zealand-5layers-GPKG"
    PROCESSED = f"{DATA_DIR}/processed-vectors"

    for d in [DATA_DIR, PROCESSED]:
        os.makedirs(d, exist_ok=True)

    main()