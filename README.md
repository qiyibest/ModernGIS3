# NYC Hydrant Density Map

🗺️ **[Live map](https://qiyibest.github.io/ModernGIS3/)**

A web map showing NYC fire hydrant density by neighborhood. Built on the
modern open-source stack (MapLibre + PMTiles + GitHub Pages) for $0/month.

[Embed a screenshot of the map here]

## The question

Where is hydrant coverage densest in NYC, and which neighborhoods are
underserved relative to their area?

## The data

- NYC Neighborhoods: 262 polygons (Source: NYC Open Data)
- NYC Fire Hydrants: 109,725 points (Source: NYC Open Data)
- Density was computed in ModernGIS2 ([repo link]) using PostGIS and GeoPandas.

## The technology choices

- **MapLibre GL JS** for rendering. Open-source, no vendor lock-in,
  same API as Mapbox GL JS.
- **PMTiles** for the data layer. One file, no tile server, hosted
  alongside index.html on GitHub Pages.
- **tippecanoe** for tile generation. Polygon recipe with shared-border
  detection for clean rendering at all zooms.
- **GitHub Pages** for hosting. Free, fast, no infrastructure to maintain.

Total monthly cost: $0. Total servers running: 0.

## How to reproduce

\`\`\`bash
git clone https://github.com/qiyibest/nyc-hydrant-map.git
cd nyc-hydrant-map
./convert.sh    # rebuilds the .pmtiles from data/raw/*.parquet
python3 -m http.server 8000   # then open localhost:8000
\`\`\`

## What I learned

This workflow bypass the tranditional webgis developments in standing up server for hosing the GIS database and websites. 
It significantly streamlines the system configuration.   

## Stack

- MapLibre GL JS 4.5.2
- PMTiles 3.2.0
- tippecanoe (felt fork)
- GitHub Pages
