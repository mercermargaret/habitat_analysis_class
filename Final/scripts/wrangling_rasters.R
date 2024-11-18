# wrangling rasters
# margaret mercer
# nov 18, 2024

# load packages
library(ctmm)
library(tidyverse)
library(sf)
library(raster)
library(terra)


# import land cover data
nlcd_raster <- rast("Final/data/NLCD_raster.tif")
nlcd_crs <- crs(nlcd_raster)
nlcd_res <- res(nlcd_raster)

roads <- st_read("Final/Major_Roads")
t(paste0("Roads loaded at ", Sys.time()))
# Reproject the roads to match the tracking data
roads <- st_transform(roads, crs(nlcd_crs))


# turn major roads into a raster with same properties as land cover data
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

# make rasters
shrub_raster <- as(raster(shrub), "RasterLayer")
low_raster <- as(raster(low), "RasterLayer")
high_raster <- as(raster(high), "RasterLayer")
distance_raster <- as(raster(distance), "RasterLayer")

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


