library(leaflet)
library(raster)

# This code saves plot to disk. It takes a raster, a title (string) and a filepath
save_change_maps <- function(raster, title, filename) {
  png(filename=filename)
  plot(raster, main = title)
  dev.off()
}

# This function saves an html file of the leaflet plot. It takes a raster, a list of markers and an output filename.
plot_leaflet <- function(raster, markers, outputFile) {
  m <- leaflet()
  m <- addTiles(m)
  for (marker in markers) {
    m <- addMarkers(m, lng=marker[[1]], lat=marker[[2]], popup=marker[[3]])
  }
  m <- addRasterImage(m, raster)
  saveas(m, outputFile)
}