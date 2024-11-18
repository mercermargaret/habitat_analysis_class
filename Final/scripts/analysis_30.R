# analysis with roads at 30
# margaret mercer
# nov 18 2024

# load packages
library(ctmm)
library(tidyverse)
library(sf)
library(raster)
library(terra)


# load data
roads_scales_of_effect <- read.csv("Final/data/roads_scales_of_effect.csv")

# load rasters in
high_30 <- rast("Final/data/high_30.tif")
low_30 <- rast("Final/data/low_30.tif")
shrub_30 <- rast("Final/data/shrub_30.tif")
roads_30 <- rast("Final/data/roads_30.tif")

# fix rasters?
high_30 <- as(raster(high_30), "RasterLayer")
low_30 <- as(raster(low_30), "RasterLayer")
shrub_30 <- as(raster(shrub_30), "RasterLayer")
roads_30 <- as(raster(roads_30), "RasterLayer")

# ind_file <- commandArgs(trailingOnly = TRUE)
# print(ind_file)
# 
# load(ind_file)
# 
# t(paste0("Data loaded at ", Sys.time()))

# test driving smaller subset of data
load("Final/Model_Fit_Results/roads_30/Ben_rr.Rda")
individual_gps <- read.csv("Final/Bobcat_Individuals/roads_30/ben.csv")
individual_gps <- individual_gps[1:50,]
individual <- as.telemetry(individual_gps)
individual$identity <- individual_gps$individual.identifier
slot(individual, "info")$identity <- individual_gps$individual.identifier[1]
uere(individual) <- 7

name <- individual$identity[1]
individual_akde <- akde(individual, fits)


# for most of the individuals for most of the variables, the scale of effect is 30
# we'll use different scales of effect for each individual for roads though
R <- list(shrub = shrub_30,
          low = low_30,
          high = high_30,
          roads = roads_30)
rsf <- rsf.fit(individual, individual_akde, R = R)

file_name = paste0("Final/Results/rsfs", name, "_rsf.Rda")

save(rsf, file = file_name)


