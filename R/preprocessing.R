# Import necessary libraries
library(raster)
library(rgdal)
library(bitops)

# Preprocessing functions

crop_image <- function(foldername, bandNames, extent, filename) {
  # Path to the folder where the data is located
  folderpath <- file.path('data',foldername)
  
  # Band 8 has a different extent and can therefore not be used. In order to  keep the file (just in 
  # case) we rename it so that it will not be listed when defining the stack.
  out_fn <- file.path(folderpath,"panchromatic_Band_8.TIF")
  fn <- list.files(folderpath, pattern = glob2rx('LC8*_B8.TIF'), full.names = TRUE)
  if (length(fn) != 0) {
    if (file.exists(fn)) file.rename(fn,out_fn)
  }
  
  # Listing landsatPath and cloudmaskPath and appending both together. We do not take all the bands
  # because we do not need band 9, 10, 11 and the BQA band.
  landsatPath <- list.files(folderpath, pattern = glob2rx('LC8*.TIF'), full.names = TRUE)[3:11]
  
  # Making the stack and giving them proper names
  landsat_stack <- stack(landsatPath)
  landsat_stack <- dropLayer(landsat_stack, 8)
  names(landsat_stack) <- bandNames

  # Crop the image to the desired extent
  brick <- crop(landsat_stack,extent)
  return(brick)
}

mask_clouds <- function(brick, bandNames, fileName) {
  print(fileName)
  cMask <- calc(x=brick$BQA, fun=QA2cloud)
  stack <- addLayer(brick, cMask)
  bandNames <- c(bandNames, "cloudMask")
  names(stack) <- bandNames
  newBrick <- brick(stack, filename=fileName, overwrite=TRUE)
  return(newBrick)
}

# Function given to us by Loic Dutrieux.
QA2cloud <- function(x, bitpos=0xC000) {
  cloud <- ifelse(bitAnd(x, bitpos) == bitpos, 1, 0)
  return(cloud)
}

extract_clouds <- function(brick) {
  # Extract cloud layer
  cloudMask <- brick[[9]]
  # Drop cloud layer
  stack <- dropLayer(brick, 9)
  # Perform the operation to remove clouds
  cloudFree <- overlay(x = stack, y = cloudMask, fun = cloud2NA)
  return(cloudFree)
}

# Value replacement function
cloud2NA <- function(x, y){
  x[y == 1] <- NA
  return(x)
}

negative_to_NA <- function(brick) {
  newBrick <- calc(x = brick, fun = neg2NA)
  return(newBrick)
}

neg2NA <- function(x) {
  x[x < 0] <- NA
  return(x)
}