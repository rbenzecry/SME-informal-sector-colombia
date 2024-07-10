
library(tidyverse)
library(readxl)
library(haven)
library(janitor)
library(data.table)
library(sjlabelled)
library(sjPlot)

rm(list = ls())

# NOTE: This script must be run at the beginnig simply after extracting
# the data from the zip file 'GEIH_2022_Marco_2018.zip'. 
# It renames the directories to the month namesm no need to do it manually.

# FUNCTIONS ---------------------------------------------------------------

# Function to extract month name from directory name
extract_month <- function(dir_name, months) {
  name_month <- str_extract(dir_name, paste(months, collapse = "|"))
  return(name_month)
}

# DATA --------------------------------------------------------------------

months <- c("Enero", "Febrero", "Marzo", "Abril",
            "Mayo", "Junio", "Julio", "Agosto", 
            "Septiembre", "Octubre", "Noviembre", "Diciembre")

survey_year <- "2022"
initial_dir <- paste("Data/GEIH-", survey_year, sep = "")


# List the directories in the parent directory
directories <- list.dirs(path = initial_dir, full.names = TRUE, recursive = FALSE)


folders_names <- list.files(initial_dir)


# Apply the function to each directory name
new_names <- sapply(directories, 
                    function(x) extract_month(dir_name = x,
                                              months = months))

# Rename the directories
file.rename(from = directories, 
            to = paste0(dirname(directories), "/", new_names))

# -------------------------------------------------------------------------
