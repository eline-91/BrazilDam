# Necessary imports
library(raster)
library(tools)

# Create data, output and bricks folder if they do not exist yet. The data folder can be filled up with
# the necessary landsat images by use of the python script: Brazil_dam_breach.py.
mainDir <- '/home/eline/Documents/University/GeoScripting/BrazilDam'
dataDir <- 'data'
bricksDir <- 'data/bricks'
outputDir <- 'output'
dirList <- list(dataDir, bricksDir, outputDir)

for (dir in dirList) {
  dir.create(file.path(mainDir, dir), showWarnings = FALSE)
}

# Source necessary R scripts
source('R/preprocessing.R')

# Extents of the needed areas
ext_sea <- extent(338265,444828,-2219221,-2123875)
ext_river <- extent(204819, 392250, -2177909, -2078672)
ext_br <- extent(635305, 780405, -2259121,-2138545)
ext_br_zoom <- extent(648078,731153,-2258406,-2221620)
band_names <- c("band1", "band2", "band3", "band4", "band5", "band6" ,"band7", "BQA")

### Sea Before ###
#filename = "data/bricks/sea_b.grd"
sea_b <- crop_image('LC82150742015254LGN00_sea_before', band_names, ext_sea)
#mask_clouds(sea_b, band_names, filename)
### Sea After ###
#filename = "data/bricks/sea_a.grd"
sea_a <- crop_image('LC82150742015334LGN00_sea_after', band_names, ext_sea)
### River Before ###
river_b <- crop_image('LC82160732015277LGN00_river_before', band_names, ext_river, "data/bricks/river_b.grd")
### River After
river_a <- crop_image('LC82160732015341LGN00_river_after', band_names, ext_river, "data/bricks/river_a.grd")
### Bento Rodrigues Before ###
br_b <- crop_image('LC82170742015284LGN00_br_before', band_names, ext_br, "data/bricks/br_b.grd")
### Bento Rodrigues After ###
br_a <- crop_image('LC82170742015316LGN00_br_after',band_names, ext_br, "data/bricks/br_a.grd")
### Bento Rodrigues Zoom Before ###
br_b_zoom <- crop_image('LC82170742015284LGN00_br_before', band_names, ext_br_zoom, "data/bricks/br_b_zoom.grd")
### Bento Rodrigues Zoom After ###
br_a_zoom <- crop_image('LC82170742015316LGN00_br_after', band_names, ext_br_zoom, "data/bricks/br_a_zoom.grd")

brickVector <- c(sea_b,sea_a,river_b,river_a,br_b,br_a,br_b_zoom,br_a_zoom)
names(brickVector) = c("sea_b", "sea_a", "river_b", "river_a" , "br_b", "br_a", "br_b_zoom", "br_a_zoom")
filenameList <- list("sea_b.grd","sea_a.grd","river_b.grd","river_a.grd","br_b.grd","br_a.grd","br_b_zoom.grd","br_a_zoom.grd")

for (i in 1:length(brickVector)) {
  filename <- file.path(bricksDir,filenameList[[i]])
  mask_clouds(brickVector[[i]], band_names, filename)
}

# Load all bricks including cloud mask and plot
for (i in 1:length(brickVector)) {
  filename <- file.path(bricksDir,filenameList[[i]])
  brickVector[[i]] <- brick(filename)
  plot(brickVector[[i]]$cloudMask)
}

# Extract the clouds for all image bands and change negative values to NA.
source('R/preprocessing.R')
for (i in 1:length(brickVector)) {
  brick_cFree <- extract_clouds(brickVector[[i]])
  brick_noNeg <- negative_to_NA(brick_cFree)
  names(brick_noNeg) <- band_names
  brickVector[[i]] <- brick_noNeg
}

# Write the new brick files to disk to be sure not to loose them
for (i in 1:length(brickVector)) {
  fn_bare = file_path_sans_ext(filenameList[[i]])
  fn <- paste(fn_bare, "_cloudFree.grd", sep="")
  filename <- file.path(bricksDir, fn)
  print(filename)
  writeRaster(brickVector[[i]],filename)
}
