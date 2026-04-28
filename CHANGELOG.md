## 1.0.0

* Initial release of `japan_maps`.
* Added `JapanMapsWidget` for rendering an interactive, zoomable, and pannable map of Japan alongside other countries.
* Added `JapanColorMapsWidget` for rendering Japan maps with customizable color overlays.
* Added support for color-coding each individual prefecture using the `Prefecture` data object.
* Included interactive callbacks (`onPrefectureTap`) to retrieve the name of the tapped prefecture.
* Optimized underlying map GeoJSON data (reduced size from 60MB to 21MB, retaining prefecture boundaries for Japan while displaying only country borders globally).
