# Necessary imports
library(raster)
library(tools)

#-------------------------------------------------------------------------------------------------------
# Create data, output and bricks folder first if they do not exist yet. The data folder can be filled up with
# the necessary landsat images by use of the python scripts in the PythonCode folder.
# More information in the ReadMe document in the github repository.

mainDir <- '/home/eline/Documents/University/GeoScripting/BrazilDam'
dataDir <- 'data'
bricksDir <- 'data/bricks'
outputDir <- 'output'
dirList <- list(dataDir, bricksDir, outputDir)

for (dir in dirList) {
  dir.create(file.path(mainDir, dir), showWarnings = FALSE)
}
#-----------------------------------------------------------------------------------------------------------


# Source necessary R scripts
source('R/preprocessing.R')
source('R/calc_index.R')
source('R/save_leaflet.R')

# Extents of the needed areas
ext_sea <- extent(338265,444828,-2219221,-2123875)
ext_river <- extent(204819, 392250, -2177909, -2078672)
ext_br <- extent(635305, 780405, -2259121,-2138545)
ext_br_zoom <- extent(648078,731153,-2258406,-2221620)
band_names <- c("band1", "band2", "band3", "band4", "band5", "band6" ,"band7", "BQA")

# Make stacks of all landsat images in order to process them
### Sea Before ###
sea_b <- crop_image('LC82150742015254LGN00_sea_before', band_names, ext_sea)
### Sea After ###
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

# Put all bricks into a vector, and give it names, so that they can be processed efficiently.
# Also initiate a list of filenames so that bricks can be easily saved to disk.
brickVector <- c(sea_b,sea_a,river_b,river_a,br_b,br_a,br_b_zoom,br_a_zoom)
names(brickVector) = c("sea_b", "sea_a", "river_b", "river_a" , "br_b", "br_a", "br_b_zoom", "br_a_zoom")
filenameList <- list("sea_b.grd","sea_a.grd","river_b.grd","river_a.grd","br_b.grd","br_a.grd","br_b_zoom.grd","br_a_zoom.grd")

# Make a cloud mask from the BQA layer and save the brick to file. This way the bricks can be easily loaded into workspace again
# and running time can be saved.
for (i in 1:length(brickVector)) {
  filename <- file.path(bricksDir,filenameList[[i]])
  mask_clouds(brickVector[[i]], band_names, filename)
}

# Load all bricks including cloud mask and plot the cloudmask. 0 means no cloud and 1 means cloud.
for (i in 1:length(brickVector)) {
  filename <- file.path(bricksDir,filenameList[[i]])
  brickVector[[i]] <- brick(filename)
  plot(brickVector[[i]]$cloudMask)
}

# Extract the clouds for all image bands and change negative values to NA.
for (i in 1:length(brickVector)) {
  brick_cFree <- extract_clouds(brickVector[[i]])
  brick_noNeg <- negative_to_NA(brick_cFree)
  names(brick_noNeg) <- band_names
  brickVector[[i]] <- brick_noNeg
}

# Write the new brick files to disk to be sure not to loose them and save running time.
for (i in 1:length(brickVector)) {
  fn_bare = file_path_sans_ext(filenameList[[i]])
  fn <- paste(fn_bare, "_cloudFree.grd", sep="")
  filename <- file.path(bricksDir, fn)
  print(filename)
  writeRaster(brickVector[[i]],filename)
}

# Initiate new filenamelist with the names of the cloud free and negative values free bricks
# Also, reset brickVector to save memory.
fnList_cFree <- list("sea_b_cloudFree.grd","sea_a_cloudFree.grd","river_b_cloudFree.grd","river_a_cloudFree.grd",
                     "br_b_cloudFree.grd","br_a_cloudFree.grd","br_b_zoom_cloudFree.grd","br_a_zoom_cloudFree.grd")
brickVector = c()


# Load the bricks from memory and put inside the brickVector
for (i in 1:length(fnList_cFree)) {
  filename <- file.path(bricksDir,fnList_cFree[[i]])
  print(filename)
  bri <- brick(filename)
  brickVector <- append(brickVector, bri)
}

# Set the names of the brickVector
names(brickVector) = c("sea_b", "sea_a", "river_b", "river_a" , "br_b", "br_a", "br_b_zoom", "br_a_zoom")

# In order to make a nicer visualization we decided to make the bento rodrigues zoomed extent
# even smaller. Therefore we replace the last two brick in the brickVector, with even smaller
# images.
closer_extent <- extent(655651.9, 676565.4, -2243369, -2232537)
for (i in 7:8) {
  bri <- crop(brickVector[[i]], closer_extent)
  brickVector[[i]] <- bri
}

# Initiate new empty vector. This vector will be filled up with the 'change'-raster layers.
changeVector <- c()

# Calculate the change in the regions: river, sea, and br zoom.
# 'fe' means that the ferrous mineral ratio will be calculated. 'br' means that the brown index
# (created by us) will be calculated.
sea_change <- change(brickVector[[1]], brickVector[[2]], 4, 5, func ='br')
changeVector <- append(changeVector, sea_change)

river_change <- change(brickVector[[3]],brickVector[[4]], 4, 5, func ='br')
changeVector <- append(changeVector, river_change)

br_zoom_change <- change(brickVector[[7]], brickVector[[8]], 5, 6, func = 'fe')
changeVector <- append(changeVector, br_zoom_change)

namesVector <- c("sea_change","river_change","br_zoom_change")
names(changeVector) <- namesVector

# Plot the change images
for (i in 1:length(changeVector)) {
  plot(changeVector[[i]], main = namesVector[[i]])
}

# Save the change images
for (i in 1:length(changeVector)) {
  filename <- paste(namesVector[[i]],'.png',sep="")
  filepath <- file.path(outputDir,filename)
  save_change_maps(changeVector[[i]],namesVector[[i]], filepath)
}

# Visualising the Bento Rodrigues area and saving the leaflet map
outputFile <- file.path(getwd(),outputDir,"br_map.html")
marker1 <- list(-43.46294,-20.21015,"Location of the dam breach")
marker2 <- list(-43.417714,-20.236886,"Village of Bento Rodrigues")
markers <- list(marker1,marker2)
plot_leaflet(changeVector[[3]],markers,outputFile)

source('R/mapping.R')
