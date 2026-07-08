#!/usr/bin/env bash
# create_pmtiles.sh
# ---------------------------------------------------------------------------
# Converts the neighborhood density GeoJSON from Lesson 2.3 into a PMTiles
# file for use with MapLibre GL JS.
#
# PMTiles is a single-file archive of vector tiles — no tile server needed.
# The browser fetches only the tiles it needs using HTTP range requests.
#
# Input:   ../2.3-sql-analysis/output/neighborhood_density.geojson
#          (197 MultiPolygon features with hydrant density data)
#
# Output:  neighborhood_density.pmtiles
#
# Prerequisites:
#   - tippecanoe installed (tippecanoe --version to check)
#     macOS:   brew install tippecanoe
#     Ubuntu:  see https://github.com/felt/tippecanoe#installation
#     Docker:  docker run -v $(pwd):/data ghcr.io/felt/tippecanoe:latest ...
#
# Usage:   bash create_pmtiles.sh
# ---------------------------------------------------------------------------

set -e

GEOJSON_INPUT="../../part2-languages/2.3-sql-analysis/output/neighborhood_density.geojson"
OUTPUT="neighborhood_density.pmtiles"

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

# --- Check input file -----------------------------------------------------
if [ ! -f "$GEOJSON_INPUT" ]; then
    echo "❌ Input file not found: $GEOJSON_INPUT"
    echo "   Make sure you completed Lesson 2.3 and the GeoJSON export."
    echo "   Expected: part2-languages/2.3-sql-analysis/output/neighborhood_density.geojson"
    exit 1
fi

echo "📁 Input:  $GEOJSON_INPUT"
echo "📦 Output: $OUTPUT"
echo ""

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
    "$GEOJSON_INPUT"

# --- Verify ---------------------------------------------------------------
echo ""
FILE_SIZE=$(wc -c < "$OUTPUT" | tr -d ' ')
echo "✅ Created $OUTPUT ($FILE_SIZE bytes)"
echo ""
echo "🎉 Done! Open index.html with a local server to see the map:"
echo "   python3 -m http.server 8080"
echo "   Then open http://localhost:8080"
