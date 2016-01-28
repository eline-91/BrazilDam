# Import necessary libraries
library(raster)
library(rgdal)
library(bitops)

# Preprocessing functions

# This function crops the images to the desired extent. It also removes bands that are not needed.
crop_image <- function(foldername, bandNames, extent) {
  # Path to the folder where the landsat data is located
  folderpath <- file.path('data',foldername)
  
  # Band 8 has a different extent and can therefore not be used. In order to  keep the file (just in 
  # case) we rename it so that it will not be listed when defining the stack.
  out_fn <- file.path(folderpath,"panchromatic_Band_8.TIF")
  fn <- list.files(folderpath, pattern = glob2rx('LC8*_B8.TIF'), full.names = TRUE)
  if (length(fn) != 0) {
    if (file.exists(fn)) file.rename(fn,out_fn)
  }
  
  # Listing landsatPath and cloudmaskPath and appending both together. We do not take all the bands
  # because we do not need band 9, 10, and 11.
  landsatPath <- list.files(folderpath, pattern = glob2rx('LC8*.TIF'), full.names = TRUE)[3:11]
  
  # Making the stack and giving them proper names
  landsat_stack <- stack(landsatPath)
  landsat_stack <- dropLayer(landsat_stack, 8) # Remove band 9
  names(landsat_stack) <- bandNames

  # Crop the image to the desired extent
  brick <- crop(landsat_stack,extent)
  return(brick)
}

# This function calculates a cloud Mask from the BQA band and adds it to the brick. 
# It also writes the brick to disk.
mask_clouds <- function(brick, bandNames, fileName) {
  print(fileName)
  cMask <- calc(x=brick$BQA, fun=QA2cloud)
  stack <- addLayer(brick, cMask)
  bandNames <- c(bandNames, "cloudMask")
  names(stack) <- bandNames
  newBrick <- brick(stack, filename=fileName, overwrite=TRUE)
  return(newBrick)
}

# Function given to us by Loic Dutrieux. Used in the mask_clouds function.
QA2cloud <- function(x, bitpos=0xC000) {
  cloud <- ifelse(bitAnd(x, bitpos) == bitpos, 1, 0)
  return(cloud)
}

# This function extracts the clouds from all layers in a brick.
extract_clouds <- function(brick) {
  # Extract cloud layer
  cloudMask <- brick[[9]]
  # Drop cloud layer
  stack <- dropLayer(brick, 9)
  # Perform the operation to remove clouds
  cloudFree <- overlay(x = stack, y = cloudMask, fun = cloud2NA)
  return(cloudFree)
}

# Value replacement function to extract clouds. Used in the extract_clouds function.
cloud2NA <- function(x, y){
  x[y == 1] <- NA
  return(x)
}

# Function to remove negative values in the layers of the brick and changes them to NA.
negative_to_NA <- function(brick) {
  newBrick <- calc(x = brick, fun = neg2NA)
  return(newBrick)
}

# Value replacement function to change negative values to NA. Used in the negative_to_NA function.
neg2NA <- function(x) {
  x[x < 0] <- NA
  return(x)
}