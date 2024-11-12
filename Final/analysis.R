# Final Project Habitat Analysis
# margaret mercer
# oct 10, 2024

# intro stuff ####

# load packages
library(ctmm)
library(tidyverse)
library(sf)
library(raster)
library(terra)

# load data
ind_file <- commandArgs(trailingOnly = TRUE)
print(ind_file)

load(ind_file)

t(paste0("Data loaded at ", Sys.time()))

# # test driving smaller subset of data
# load("Final/Model_Fit_Results/Ben_rr.Rda")
# individual_gps <- read.csv("Final/Bobcat_Individuals/range_resident/ben.csv")
# individual_gps <- individual_gps[1:50,]
# individual <- as.telemetry(individual_gps)
# individual$identity <- individual_gps$individual.identifier
# slot(individual, "info")$identity <- individual_gps$individual.identifier[1]
# uere(individual) <- 7
# name <- individual$identity[1]

# import land cover data
nlcd_raster <- rast("Final/NLCD_raster.tif")
nlcd_crs <- crs(nlcd_raster)
nlcd_res <- res(nlcd_raster)

roads <- st_read("Final/Major_Roads")
t(paste0("Roads loaded at ", Sys.time()))
# Reproject the roads to match the tracking data
roads <- st_transform(roads, crs(nlcd_crs))

individual_akde <- akde(individual, fits)
# #Return the basic statistics on the HR area
# summary(individual_akde)
# # create and reproject home range contour
# # Extract the 95% home range contour
# home_range_polygon <- SpatialPolygonsDataFrame.UD(individual_akde)
# # Convert SpatialPolygonsDataFrame to an sf object
# home_range_sf <- st_as_sf(home_range_polygon)
# home_range <- st_transform(home_range_sf, crs(nlcd_crs))
# plot(home_range)

# turn major roads into a raster with same properties as land cover data
# Create a raster template
distance <- rast(extent, 
                 resolution = nlcd_res, 
                 crs = nlcd_crs)
roads_vector <- vect(roads)
roads_raster <- rasterize(roads_vector, distance, field = 1, background = 0)
plot(roads_raster)
distance <- terra::distance(nlcd_raster, roads_vector)
# this spits out a raster of all 0s. Why???
plot(distance)
plot(roads_vector, add = TRUE)
sum(table(values(distance))) 
sum(table(values(nlcd_raster))) 
test <- (c(distance, nlcd_raster)) # if this worked, it means extent, resolution, and number of cells matches

# # get land cover data into same coordinate reference system as telemetry data!
# crs <- crs(individual_gps) # this doesn't work (NA)


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
test <- (c(distance_raster, shrub_raster, low_raster, high_raster))

# # run test rsf.fit()
# R <- list(shrub = shrub_raster)
# rsf <- rsf.fit(individual, individual_akde, R = R)
# # how pull out AIC


# choose different scales (code from Javan)
buffers <- c(30, 750, 1500) # way fewer scales! selected based on average bobcat home range sizes;
# this minimized confounding with 2nd order (larger than home range)
#
# create empty dataframe with length(buffers)*4 rows and two columns
shrub_AICs <- data.frame(matrix(nrow = (length(buffers)), ncol = 2))
low_AICs <- data.frame(matrix(nrow = (length(buffers)), ncol = 2))
high_AICs <- data.frame(matrix(nrow = (length(buffers)), ncol = 2))
roads_AICs <- data.frame(matrix(nrow = (length(buffers)), ncol = 2))

# create rasters, throw them all in the model, run rsf.select and it'll give me the AIC calculation
R <- vector("list")

# # can give you summaries of whole list of models, or tell it to give me the best one (will output list of all the models)

for(i in 1:length(buffers)){
  buff_i <- buffers[i]
  cat("Starting buffer",buff_i,"\n")
  
  shrub_i <- focal(shrub_raster, w = focalMat(shrub_raster,
                                              d = buff_i,
                                              type=c('circle')),
                   fun = "mean")
  
  R <- list(shrub = shrub_i)
  rsf_shrub <- rsf.fit(individual, individual_akde, R = R)
  shrub_AICs[i, 1] <- paste("shrub_", buff_i)
  shrub_AICs[i, 2] <- rsf_shrub$AIC
  
  
  # low
  low_i <- focal(low_raster, w = focalMat(low_raster,
                                          d = buff_i,
                                          type=c('circle')),
                 fun = "mean")
  R <- list(low = low_i)
  rsf_low <- rsf.fit(individual, individual_akde, R = R)
  low_AICs[i, 1] <- paste("low_", buff_i)
  low_AICs[i, 2] <- rsf_low$AIC
  
  
  # high
  high_i <- focal(high_raster, w = focalMat(high_raster,
                                            d = buff_i,
                                            type=c('circle')),
                  fun = "mean")
  R <- list(high = high_i)
  rsf_high <- rsf.fit(individual, individual_akde, R = R)
  rsf_high$AIC
  high_AICs[i, 1] <- paste("high_", buff_i)
  high_AICs[i, 2] <- rsf_high$AIC
  
  # roads
  roads_i <- focal(distance_raster, w = focalMat(distance_raster,
                                                 d = buff_i,
                                                 type=c('circle')),
                   fun = "mean")
  R <- list(roads = roads_i)
  rsf_roads <- rsf.fit(individual, individual_akde, R = R)
  rsf_roads$AIC
  roads_AICs[i, 1] <- paste("roads_", buff_i)
  roads_AICs[i, 2] <- rsf_roads$AIC
  
}

write.csv(shrub_AICs, paste0("Final/Results/", "shrub_AICs.csv"))
write.csv(low_AICs, paste0("Final/Results/", "low_AICs.csv"))
write.csv(high_AICs, paste0("Final/Results/", "high_AICs.csv"))
write.csv(roads_AICs, paste0("Final/Results/", "roads_AICs.csv"))

# R <- vector("list")

# length <- (length(buffers) * 4)

# # custom function to return 0 if all values are 0
# custom_mean <- function(x) {
#   if (all(x == 0, na.rm = TRUE)) {
#     return(0)  # Return 0 if all values are zero
#   } else {
#     return(mean(x, na.rm = TRUE))  # Otherwise, return the mean
#   }
# }
# 
# for(i in 1:length(buffers)){
#   buff_i <- buffers[i]
#   cat("Starting buffer",buff_i,"\n")
#   
#   shrub_i <- focal(shrub_raster, w = focalMat(shrub_raster,
#                                               d = buff_i,
#                                               type=c('circle')),
#                    fun = custom_mean)
#   ID <- paste0("shrub_", buff_i)
#   R[[ID]] <- shrub_i
#   
#   
#   # low
#   low_i <- focal(low_raster, w = focalMat(low_raster,
#                                           d = buff_i,
#                                           type=c('circle')),
#                  fun = "mean")
#   ID <- paste0("low_", buff_i)
#   R[[ID]] <- low_i
#   
#   
#   # high
#   high_i <- focal(high_raster, w = focalMat(high_raster,
#                                             d = buff_i,
#                                             type=c('circle')),
#                   fun = "mean")
#   ID <- paste0("high_", buff_i)
#   R[[ID]] <- high_i
#   
#   # roads
#   roads_i <- focal(distance_raster, w = focalMat(distance_raster,
#                                                  d = buff_i,
#                                                  type=c('circle')),
#                  fun = "mean")
#   ID <- paste0("roads_", buff_i)
#   R[[ID]] <- roads_i
#   
# } # this gives me a bunch of NaN values x_x --> not a problem? because it might be the NA values around the edge


# selection <- rsf.select(individual, individual_akde, R = R, integrator = "rimann", verbose = TRUE) # this took about an hour, but it worked. I screenshotted the results

# returns AIC model
# verbose = TRUE returns all candidate models






# THEN ####
# print results of pseudo optimization
# write.csv(shrub_AICs, paste0("Final/Results/",name,"_shrub_AICs"))

# run pearsons correlation test on all used points (stack the rasters into one first!) if they're too correlated, fit models separately instead of same model
# plot distribution of step lengths!
# think about maybe including interactions?



# create rasters at scale of effect

# run rsf.fit again with scales of effect!


# what are beta and used mean? how interpret output?

# save(rsf, file = "Final/rsf.test.Rda")
# add each individual to list object so we can pull out the mean


