# get scale of effect on rsfs
# margaret mercer
# november 18, 2024

library(ctmm)
library(tidyverse)

# get names
names_list <- c("Avery",
               "Wyatt",
               "Ben",
               "Beverly",
               "BobbiJo",
               "Braeden",
               "Bunny",
               "Carrie",
               "Cassidy",
               "Catherine",
               "Charlie",
               "Cynthia",
               "Daphne",
               "Dave",
               "Elsie",
               "EmmaClaire",
               "Hal",
               "Jack",
               "Jonathan",
               "Lisa",
               "Luna",
               "Margaret",
               "Michele",
               "Minnie",
               "Morgan",
               "Nala",
               "Rocky",
               "Sadie",
               "Shannan",
               "Steve",
               "Sweetwater",
               "Sylvia",
               "Val")

# find scales of effect for low
low_files <- list.files(path = "Final/Results/", pattern = "low", ignore.case = TRUE)
length <- length(low_files)
low_scales_of_effect <- data.frame(
  name = names_list,
  scale_of_effect = character(33)
)


for (i in 1:length(low_files)) {
  file_path <- paste0("Final/Results/", low_files[i])
  low <- read_csv(file_path)
  low_scales_of_effect[i,2] <- low[which.min(low$X2), "X1"]
}

# find scales of effect for high
high_files <- list.files(path = "Final/Results/", pattern = "high", ignore.case = TRUE)
length <- length(high_files)
high_scales_of_effect <- data.frame(
  name = names_list,  # Empty character column
  scale_of_effect = character(33)    # Empty numeric column
)

for (i in 1:length(high_files)) {
  file_path <- paste0("Final/Results/", high_files[i])
  high <- read_csv(file_path)
  high_scales_of_effect[i,2] <- high[which.min(high$X2), "X1"]
}

# find scales of effect for shrub
shrub_files <- list.files(path = "Final/Results/", pattern = "shrub", ignore.case = TRUE)
length <- length(shrub_files)
shrub_scales_of_effect <- data.frame(
  name = names_list,  # Empty character column
  scale_of_effect = character(33)    # Empty numeric column
)

for (i in 1:length(shrub_files)) {
  file_path <- paste0("Final/Results/", shrub_files[i])
  shrub <- read_csv(file_path)
  shrub_scales_of_effect[i,2] <- shrub[which.min(shrub$X2), "X1"]
}


# find scales of effect for roads
roads_files <- list.files(path = "Final/Results/", pattern = "roads", ignore.case = TRUE)
length <- length(roads_files)
roads_scales_of_effect <- data.frame(
  name = names_list,  # Empty character column
  scale_of_effect = character(33)    # Empty numeric column
)

for (i in 1:length(roads_files)) {
  file_path <- paste0("Final/Results/", roads_files[i])
  roads <- read_csv(file_path)
  roads_scales_of_effect[i,2] <- roads[which.min(roads$X2), "X1"]
}


# compare numbers of each scale of effect
table(low_scales_of_effect$scale_of_effect) # mostly 30m (3 exceptions)
table(high_scales_of_effect$scale_of_effect) # mostly 30m (four exceptions)
table(shrub_scales_of_effect$scale_of_effect) # mostly 30m (five exceptions)
table(roads_scales_of_effect$scale_of_effect) # 14 1500, 10 750, and 9 30m UGH


write.csv(low_scales_of_effect, "Final/low_scales_of_effect.csv", row.names = FALSE)
write.csv(high_scales_of_effect, "Final/high_scales_of_effect.csv", row.names = FALSE)
write.csv(shrub_scales_of_effect, "Final/shrub_scales_of_effect.csv", row.names = FALSE)
write.csv(roads_scales_of_effect, "Final/roads_scales_of_effect.csv", row.names = FALSE)
