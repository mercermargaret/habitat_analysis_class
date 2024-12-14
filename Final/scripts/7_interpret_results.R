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

# average coefficient estimates
mean_rsf <- mean(rsf_list) 
summary_rsf <- summary(mean(rsf_list)) # this takes like 10 or 15 minutes maybe
# THIS gives you your beta estimates (positive = selection, negative = avoidance). Also your CIs (if cross 0, no significance)

# what percentage of pixels in study area are in each of these categories
# I want to know what that other stuff is that they'd rather be in than other areas
# look in NLCD raster for what the OTHER things are (bobcats like those better than the three things I chose)
# if MOST of my pixels are these covariates, take out shrubs and run again x_x

# --> so I did this....97% of our raster is covered by one of our covariates
# so I'm gonna remove shrubs and run it again x_x

# ok done

# report the proportion of bobcats for which each of these covariates was significant

# ok so for EACH do this:
# Initialize an empty list to store the significance results
significance_results <- list()

# Loop through each individual in rsf_list
for (individual_name in names(rsf_list)) {
  
  # Extract summary for the current individual
  summary <- summary(rsf_list[[individual_name]])
  
  # Extract CI values for each covariate
  roads_ci <- summary$CI[1, c(1, 3)]
  high_ci <- summary$CI[2, c(1, 3)]
  low_ci <- summary$CI[3, c(1, 3)]
  
  # Check if the CI values for roads, high, and low do not overlap zero
  roads_significance <- ifelse(roads_ci[1] > 0 & roads_ci[2] > 0 | roads_ci[1] < 0 & roads_ci[2] < 0, "significant", "nonsignificant")
  high_significance <- ifelse(high_ci[1] > 0 & high_ci[2] > 0 | high_ci[1] < 0 & high_ci[2] < 0, "significant", "nonsignificant")
  low_significance <- ifelse(low_ci[1] > 0 & low_ci[2] > 0 | low_ci[1] < 0 & low_ci[2] < 0, "significant", "nonsignificant")
  
  # Combine the results for this individual into a single row
  individual_results <- data.frame(
    Individual = individual_name,
    Roads = roads_significance,
    High = high_significance,
    Low = low_significance
  )
  
  # Append the individual results to the significance_results list
  significance_results[[individual_name]] <- individual_results
}

# Combine all individual results into one dataframe
final_df <- do.call(rbind, significance_results)

# View the final dataframe
print(final_df)

# Calculate the proportion of significant results for each covariate
roads_prop <- mean(final_df$Roads == "significant")
high_prop <- mean(final_df$High == "significant")
low_prop <- mean(final_df$Low == "significant")

# Combine results into a dataframe
proportions_df <- data.frame(
  Covariate = c("Roads", "High", "Low"),
  Proportion_Significant = c(roads_prop, high_prop, low_prop)
)

# View the proportions
print(proportions_df)

write.csv(proportions_df, "Final/Results/proportions.csv")


