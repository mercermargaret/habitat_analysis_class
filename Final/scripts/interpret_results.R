# interpret rsf results
# margaret mercer
# november 19, 2024

library(ctmm)

rsf_files <- list.files(path = "Final/Results/rsfs/")
length <- length(rsf_files)
rsf_list <- list()

for (i in 1:length(rsf_files)) {
  load(paste0("Final/Results/rsfs/", rsf_files[i])) # Load the Rda file
  name <- sub(".Rda$", "", rsf_files[i]) # remove ".Rda" from name
  assign(name, rsf) # Dynamically assign the object loaded from the file to a new variable
  rsf_list[[name]] <- rsf # add to list of all rsfs
}

summary(rsf_list)

summary(rsf_list$Avery_rsf) # how interpret/summarize? x_x Jesse, HELP
# why is it 1/x ?

# report: characterize variation among scale of effect (that's interesting!)
# summarize coefficient estimates across individuals
# keep everything else constant, get the relative selection strength (how likely to select high versus low, etc)


rsf_list <- rsf_list[!names(rsf_list) %in% "Elsie_rsf"]

# average coefficient estimates
mean(rsf_list) 
summary(mean(rsf_list)) 
# THIS gives you your beta estimates (positive = selection, negative = avoidance). Also your CIs (if cross 0, no significance)

# what percentage of pixels in study area are in each of these categories
# I want to know what that other stuff is that they'd rather be in than other areas
# look in NLCD raster for what the OTHER things are (bobcats like those better than the three things I chose)
# if MOST of my pixels are these covariates, take out shrubs and run again x_x

# --> so I did this....97% of our raster is covered by one of our covariates
# so I'm gonna remove shrubs and run it again x_x

