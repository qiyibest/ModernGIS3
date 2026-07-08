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
- Density was computed in [ModernGIS2](https://github.com/qiyibest/ModernGIS-2) using PostGIS and GeoPandas.

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
git clone https://github.com/qiyibest/ModernGIS3.git
cd ModernGIS3
./create_pmtiles.sh    # rebuilds the .pmtiles from data/processed/hydrant_density.parquet
python3 -m http.server 8000   # then open localhost:8000
\`\`\`

## What I learned

This workflow bypasses traditional WebGIS development, which requires standing up a
server to host the GIS database and serve the site. It significantly streamlines the
system configuration.

## Stack

- MapLibre GL JS 5.21.0
- PMTiles 4.4.0
- tippecanoe (felt fork)
- GitHub Pages
