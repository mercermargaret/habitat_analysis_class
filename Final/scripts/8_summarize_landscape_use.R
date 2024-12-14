# summarize proportion of each bobcat's used locations that are in each area
# margaret mercer 
# december 3, 2024

library(tidyverse)
library(terra)
library(sf)

options(scipen = 999)

ind_files <- list.files(path = "Final/Bobcat_Individuals/", pattern = "*.csv")
length <- length(ind_files)

result_df <- data.frame()

# rsf_list <- list()

for (i in 1:length(ind_files)) {
  ind_df <- read_csv(paste0("Final/Bobcat_Individuals/", ind_files[i]))
  ind <- st_as_sf(ind_df, coords = c("location.long", "location.lat"), crs = 4326) # make individual into spatial object
  
  NLCD <- rast("Final/data/NLCD_raster.tif")
  
  name <- ind_df$individual.identifier[1]
  print(paste ("starting:", name))
  
  ind_sp <- st_transform(ind, crs(NLCD)) # transform individual to match crs of NLCD raster
  
  # plot(NLCD)
  # plot(ind_sp$geometry, add = TRUE) # check that they actually fall where I'd expect
  
  nlcd_values <- extract(NLCD, ind_sp)
  
  ind$nlcd_class <- nlcd_values$`NLCD Land Cover Class`
  
  land_type_counts <- ind %>%
    group_by(nlcd_class) %>%
    summarise(count = n(), .groups = "drop")
  
  classes <- land_type_counts$nlcd_class # get rid of unnecesasary columns
  counts <- land_type_counts$count
  total <- length(ind_df$timestamp)
  
  proportions <- counts/total
  
  summary <- data.frame(classes = classes, proportions = proportions)
  
  # Add the individual's name as a row name (row names in the resulting data frame)
  summary$name <- name
  
  # Bind the result to the main data frame (use rbind to add rows)
  result_df <- bind_rows(result_df, summary)
  
}

pivot_df <- result_df %>%
  pivot_wider(names_from = classes, values_from = proportions, values_fill = list(proportions = NA))

pivot_df <- as_data_frame(pivot_df)

# Extract values from the raster
raster_values <- values(NLCD)
num_cells <- ncell(NLCD)

# Count the number of cells for each land cover type
land_cover_counts <- table(raster_values)
land_cover_proportions <- land_cover_counts/num_cells
land_cover_proportions <- as_data_frame(land_cover_proportions)
land_cover_proportions <- land_cover_proportions %>%
  pivot_wider(names_from = raster_values, values_from = n)
land_cover_proportions$name <- "Available"

# Add missing columns to pivot_df
missing_cols <- setdiff(names(land_cover_proportions), names(pivot_df))

# Add missing columns to pivot_df and fill with NA
for (col in missing_cols) {
  pivot_df[[col]] <- NA
}

# Reorder pivot_df columns to match land_cover_proportions
pivot_df <- pivot_df[, names(land_cover_proportions)]

# Now, you can safely row-bind the two data frames
merged_df <- rbind(land_cover_proportions, pivot_df)

merged_df <- merged_df %>%
  select(name, everything())

new_colnames <- c("Name", "Open Water", "Open Developed", "Low Developed", "Medium Developed", 
                  "High Developed", "Barren", "Deciduous", "Evergreen", "Mixed Forest", 
                  "Shrub", "Grassland", "Crops", "Woody Wetland", "Herbaceous Wetland")

# Assuming merged_df already exists, set the column names
colnames(merged_df) <- new_colnames

merged_df[is.na(merged_df)] <- 0

merged_df <- merged_df %>%
  mutate(High_Disturbance_Urban = rowSums(select(., c("Medium Developed", "High Developed")), na.rm = TRUE))
merged_df <- merged_df %>%
  select(-`Medium Developed`, -`High Developed`)

merged_df <- merged_df %>%
  mutate(Low_Disturbance_Urban = rowSums(select(., c("Open Developed", "Low Developed")), na.rm = TRUE))
merged_df <- merged_df %>%
  select(-`Open Developed`, -`Low Developed`)

merged_df <- merged_df %>%
  mutate(Other = rowSums(select(., c("Open Water", "Barren", "Grassland", "Crops", "Deciduous", "Evergreen", "Mixed Forest", "Woody Wetland", "Herbaceous Wetland")), na.rm = TRUE))
merged_df <- merged_df %>%
  select(-"Open Water", -"Barren", -"Grassland", -"Crops", -`Deciduous`, -`Evergreen`, -"Mixed Forest", -`Woody Wetland`, -`Herbaceous Wetland`)

merged_df <- merged_df %>%
  mutate_if(is.numeric, ~signif(., 1))

write_csv(merged_df, "Final/Results/proportions.csv")







