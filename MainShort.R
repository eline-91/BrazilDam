# This is a version of the main script for just one small extent of the Bento Rodrigues area.

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
source('R/mapping.R')

# Extents of the needed areas
ext_br_zoom <- extent(648078,731153,-2258406,-2221620)
e <- extent(655651.9, 676565.4, -2243369, -2232537)
band_names <- c("band1", "band2", "band3", "band4", "band5", "band6" ,"band7", "BQA")

brickVector = c()
### Bento Rodrigues Zoom Before ###
br_b_zoom <- crop_image('LC82170742015284LGN00_br_before', band_names, ext_br_zoom)
brickVector <- append(brickVector,br_b_zoom)
### Bento Rodrigues Zoom After ###
br_a_zoom <- crop_image('LC82170742015316LGN00_br_after', band_names, ext_br_zoom)
brickVector <- append(brickVector,br_a_zoom)

names(brickVector) = c("br_zoom_before", "br_zoom_after")
filenameList <- list("br_zoom_before.grd","br_zoom_after.grd")

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
fnList_cFree <- list("br_b_zoom_cloudFree.grd","br_a_zoom_cloudFree.grd")
brickVector = c()

# Load the bricks from memory and put inside the brickVector
for (i in 1:length(fnList_cFree)) {
  filename <- file.path(bricksDir,fnList_cFree[[i]])
  print(filename)
  bri <- brick(filename)
  brickVector <- append(brickVector, bri)
}

# Set the names of the brickVector
names(brickVector) = c("br_b_zoom", "br_a_zoom")

# In order to make a nicer visualization we decided to make the bento rodrigues zoomed extent
# even smaller. Therefore we replace the last two brick in the brickVector, with even smaller
# images.
for (i in 1:2) {
  bri <- crop(brickVector[[i]], e)
  brickVector[[i]] <- bri
}

# Calculate the change in the regions: river, sea, and br zoom.
# 'fe' means that the ferrous mineral ratio will be calculated.
br_zoom_change <- change(brickVector[[1]], brickVector[[2]], 5, 6, func = 'fe')

# Plot the change image
plot(br_zoom_change, main = "The change in Ferrous Mineral Ratio")

# Save plot
filename <- "ferrous_change_br.png"
filepath <- file.path(outputDir,filename)
save_change_maps(br_zoom_change,"The change in Ferrous Mineral Ratio", filepath)

# Visualising the Bento Rodrigues area and saving the leaflet map
outputFile <- file.path(getwd(),outputDir,"Bento_Rodrigues_Disaster.html")
marker1 <- list(-43.46294,-20.21015,"Location of the dam breach")
marker2 <- list(-43.417714,-20.236886,"Village of Bento Rodrigues")
markers <- list(marker1,marker2)
plot_leaflet(br_zoom_change,markers,outputFile)

# Plot the before and after false-colour images
plotRGB(brickVector[[1]],6,5,4)  # Before
plotRGB(brickVector[[2]],6,5,4)  # After
