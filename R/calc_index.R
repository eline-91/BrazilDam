library(raster)

# Function that calculates an index of the provided before-after images (bricks) and calculates the change between them.
# Indexes that can be calculated:
#     1. 'fe' = Ferrous Mineral Ratio (SWIR/NIR): hightlights iron-bearing minerals
#     2. 'br' = Brown Index ((NIR-RED)/NIR): highlights browns
# Function returns a raster layer
change <- function(brick_b, brick_a, a, b, func){
	if (func == 'fe'){
		calc_index_before <- overlay(brick_b[[a]],brick_b[[b]], fun=function(x,y){y/x})
		calc_index_after <- overlay(brick_a[[a]], brick_a[[b]], fun=function(x,y){y/x})
		change <- overlay (calc_index_before, calc_index_after, fun=function(x,y){y-x})	
		raster_change <- calc(change, fun=function(x){x[x<0.025] <-NA; return(x)})
		} else if (func == 'br') {
		calc_index_before <- overlay(brick_b[[a]],brick_b[[b]], fun=function(x,y){(y-x)/y})
		calc_index_after <- overlay(brick_b[[a]], brick_a[[b]], fun=function(x,y){(y-x)/y})
		change <- overlay (calc_index_before, calc_index_after, fun=function(x,y){y-x})	
		raster_change <- calc(change, fun=function(x){x[x<0.55] <-NA; return(x)})
		} else {
		  ErrorMessage <- "The provided index is not known."
		  print(ErrorMessage)
		}
	return(raster_change)
}


