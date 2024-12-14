# wrangling rasters
# margaret mercer
# nov 18, 2024

# load packages
library(ctmm)
library(tidyverse)
library(sf)
library(raster)
library(terra)

all_bobs <- read.csv("../bobcat_chapter/data/bobcat_locs_all.csv")

# import land cover data
nlcd_raster <- rast("Final/data/NLCD_raster.tif")
nlcd_crs <- crs(nlcd_raster)
nlcd_res <- res(nlcd_raster)

roads <- st_read("Final/Major_Roads")
t(paste0("Roads loaded at ", Sys.time()))
# Reproject the roads to match the tracking data
roads <- st_transform(roads, crs(nlcd_crs))

# see how land cover looks
plot(nlcd_raster)
# and see how much of our raster is a feature of choice
foc_matrix <- matrix(c(11,21,22,23,24,31,41,42,43,52,71,82,90,95,
                         0,1,1,1,1,0,0,0,0,1,1,0,0,0),
                       ncol = 2)
foc <- classify(nlcd_raster, foc_matrix)
plot(foc)
# get percent that is a feature of choice
all_cells <- sum(table(values(foc)))
foc_cells <- sum(values(foc) == 1)
foc_cells/all_cells # 97% x_x


# turn foc# turn major roads into a raster with same properties as land cover data
# Create a raster template
extent <- ext(roads)
distance <- rast(extent, 
                 resolution = nlcd_res, 
                 crs = nlcd_crs)
roads_vector <- vect(roads)
roads_raster <- rasterize(roads_vector, distance, field = 1, background = 0)
plot(roads_raster)
distance <- terra::distance(nlcd_raster, roads_vector)
plot(distance)
plot(roads_vector, add = TRUE)
sum(table(values(distance))) 
sum(table(values(nlcd_raster))) 
test <- (c(distance, nlcd_raster)) # if this worked, it means extent, resolution, and number of cells matches

# create rasters of our features of choice
shrub_matrix <- matrix(c(11,21,22,23,24,31,41,42,43,52,71,82,90,95,
                         0,0,0,0,0,0,0,0,0,1,1,0,0,0),
                       ncol = 2)
shrub <- classify(nlcd_raster, shrub_matrix)
plot(shrub)

low_matrix <- matrix(c(11,21,22,23,24,31,41,42,43,52,71,82,90,95,
                       0,1,1,0,0,0,0,0,0,0,0,0,0,0),
                     ncol = 2)
low <- classify(nlcd_raster, low_matrix)
plot(low)

high_matrix <- matrix(c(11,21,22,23,24,31,41,42,43,52,71,82,90,95,
                        0,0,0,1,1,0,0,0,0,0,0,0,0,0),
                      ncol = 2)
high <- classify(nlcd_raster, high_matrix)
plot(high)



# make rasters into correct format
shrub_raster <- as(raster(shrub), "RasterLayer")
low_raster <- as(raster(low), "RasterLayer")
high_raster <- as(raster(high), "RasterLayer")
distance_raster <- as(raster(distance), "RasterLayer")

locs <- all_bobs[4:5]
locs$Longitude <- all_bobs$location.long
locs$Latitude <- all_bobs$location.lat
locs <- locs[3:4]

# make this into a spatial object and reproject into same crs as the raster then this'll work:

# what percentage of the bobcat locations are in shrub?
shrub_locs <- terra::extract(shrub_raster, locs, raw = FALSE)
shrub_locs
# we want our reference category to be a relatively large proportion of the points (at least 25%); 
# want it to be relatively neutral so that everything else is compared to it

# ok so we're trying to see if there are about as many points as we expect for how much of the home range is in that category
# trim it down to the study area only!

# create buffers
# choose different scales (code from Javan)
buffers <- c(30, 750, 1500)
for(i in 1:length(buffers)){
  buff_i <- buffers[i]
  cat("Starting buffer",buff_i,"\n")

  shrub_i <- focal(shrub_raster, w = focalMat(shrub_raster,
                                              d = buff_i,
                                              type=c('circle')),
                   fun = "mean")
  terra::writeRaster(shrub_i, paste0("Final/data/", "shrub_", buff_i, ".tif"), overwrite=TRUE)
  
  
  # low
  low_i <- focal(low_raster, w = focalMat(low_raster,
                                          d = buff_i,
                                          type=c('circle')),
                 fun = "mean")
  terra::writeRaster(low_i, paste0("Final/data/", "low_", buff_i, ".tif"), overwrite=TRUE)
  
  
  # high
  high_i <- focal(high_raster, w = focalMat(high_raster,
                                            d = buff_i,
                                            type=c('circle')),
                  fun = "mean")
  terra::writeRaster(high_i, paste0("Final/data/", "high_", buff_i, ".tif"), overwrite=TRUE)
  
  # roads
  roads_i <- focal(distance_raster, w = focalMat(distance_raster,
                                                 d = buff_i,
                                                 type=c('circle')),
                   fun = "mean")
  terra::writeRaster(roads_i, paste0("Final/data/", "roads_", buff_i, ".tif"), overwrite=TRUE)
  
}


