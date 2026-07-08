#!/usr/bin/env bash
# create_pmtiles.sh
# ---------------------------------------------------------------------------
# Converts the neighborhood density GeoParquet produced by ModernGIS2's
# analysis notebook into a PMTiles file for use with MapLibre GL JS.
#
# PMTiles is a single-file archive of vector tiles — no tile server needed.
# The browser fetches only the tiles it needs using HTTP range requests.
#
# Input:   data/processed/hydrant_density.parquet
#          (GeoParquet: residential NTAs with hydrant_count, area_km2,
#          hydrants_per_km2 — produced by ModernGIS2/analysis.ipynb)
#
# Output:  neighborhood_density.pmtiles
#
# Prerequisites:
#   - tippecanoe installed (tippecanoe --version to check)
#     macOS:   brew install tippecanoe
#     Ubuntu:  see https://github.com/felt/tippecanoe#installation
#     Docker:  docker run -v $(pwd):/data ghcr.io/felt/tippecanoe:latest ...
#   - ogr2ogr installed (part of GDAL, converts GeoParquet -> GeoJSON)
#     macOS:   brew install gdal
#     Ubuntu:  sudo apt install gdal-bin
#
# Usage:   bash create_pmtiles.sh
# ---------------------------------------------------------------------------

set -e

PARQUET_INPUT="data/processed/hydrant_density.parquet"
OUTPUT="neighborhood_density.pmtiles"
TMP_GEOJSON="$(mktemp).geojson"

cleanup() { rm -f "$TMP_GEOJSON"; }
trap cleanup EXIT

# --- Check prerequisites --------------------------------------------------
if ! command -v tippecanoe &> /dev/null; then
    echo "❌ tippecanoe is not installed."
    echo ""
    echo "Install it:"
    echo "  macOS:  brew install tippecanoe"
    echo "  Ubuntu: git clone https://github.com/felt/tippecanoe.git && cd tippecanoe && make -j && sudo make install"
    echo "  Docker: docker run -v \$(pwd):/data ghcr.io/felt/tippecanoe:latest tippecanoe ..."
    exit 1
fi

if ! command -v ogr2ogr &> /dev/null; then
    echo "❌ ogr2ogr is not installed (part of GDAL)."
    echo ""
    echo "Install it:"
    echo "  macOS:  brew install gdal"
    echo "  Ubuntu: sudo apt install gdal-bin"
    exit 1
fi

# --- Check input file -----------------------------------------------------
if [ ! -f "$PARQUET_INPUT" ]; then
    echo "❌ Input file not found: $PARQUET_INPUT"
    echo "   Run ModernGIS2/analysis.ipynb (or analysis.sql) first, then copy"
    echo "   its output here: cp ../ModernGIS2/data/processed/hydrant_density.parquet data/processed/"
    exit 1
fi

echo "📁 Input:  $PARQUET_INPUT"
echo "📦 Output: $OUTPUT"
echo ""

# --- Convert GeoParquet to GeoJSON for tippecanoe --------------------------
echo "🔄 Converting GeoParquet to GeoJSON..."
ogr2ogr -f GeoJSON "$TMP_GEOJSON" "$PARQUET_INPUT"

# --- Convert to PMTiles ---------------------------------------------------
echo "🔄 Running tippecanoe..."
# -z12         → max zoom level 12 (neighborhood-level detail, no need for higher)
# -Z8          → min zoom level 8 (don't show at world/country scale)
# --no-feature-limit  → include all features per tile (only 197 polygons, safe)
# --no-tile-size-limit → don't drop features to shrink tiles
# -l           → layer name inside the tileset (referenced in MapLibre style)
# --coalesce-densest-as-needed → simplify geometry at low zooms to keep tiles small
# -o           → output file
# --force      → overwrite if output already exists

tippecanoe \
    -z12 \
    -Z8 \
    --no-feature-limit \
    --no-tile-size-limit \
    -l neighborhood_density \
    --coalesce-densest-as-needed \
    -o "$OUTPUT" \
    --force \
    "$TMP_GEOJSON"

# --- Verify ---------------------------------------------------------------
echo ""
FILE_SIZE=$(wc -c < "$OUTPUT" | tr -d ' ')
echo "✅ Created $OUTPUT ($FILE_SIZE bytes)"
echo ""
echo "🎉 Done! Open index.html with a local server to see the map:"
echo "   python3 -m http.server 8080"
echo "   Then open http://localhost:8080"
