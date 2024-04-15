

library(tidyverse)
library(readxl)
library(haven)
library(janitor)
library(data.table)
library(sjlabelled)
library(sjPlot)

# rm(list = ls())

# DATA --------------------------------------------------------------------

# Define the common columns to read from every module
id_cols <- c("id_house", "adj_weight", 
             "PERIODO", "MES",
             "DIRECTORIO", "SECUENCIA_P", 
             "HOGAR",
             "CLASE",
             "FEX_C18",
             "DPTO", "AREA")


# Household level module
household_raw <- read_dta("Tables/02_household-surveys/household_geih-2022-clean.dta",
                          col_select = c(all_of(id_cols),
                                     # Number or people per household
                                     "P6008",
                                     "P4030S5",
                                     "P5050",
                                     "P5020",
                                     "P4020",
                                     "P4010",
                                     "P5010"))


# HOUSING AND SERVICES ----------------------------------------------------


household <- household_raw %>% 
  mutate(id_house = paste(DIRECTORIO, SECUENCIA_P, sep = "")) %>% 
  
  # Rename all variables
  rename(n_per = P6008,
         water_source = P5050,
         excrete_disposal = P5020,
         floors = P4020,
         walls = P4010,
         n_bedroom = P5010) %>% 
  
  # Urban or rural
  # CLASE == 1 ES URBANO
  mutate(urban = as.numeric(CLASE == 1)) %>% 
  
  # MPI indicators. NOTE: 1 means deprived
  mutate(mpi_water = ifelse((urban == 1 & water_source != 1) |
                              (urban == 0 & water_source >= 4),
                            yes = 1, no = 0),
         
         mpi_excrete = ifelse((urban == 1 & excrete_disposal != 1) |
                                (urban == 0 & excrete_disposal >= 3),
                              yes = 1, no = 0),
         
         mpi_floor = ifelse(floors == 1,
                            yes = 1, no = 0),
         
         mpi_walls = ifelse((urban == 1 & walls > 4) |
                              (urban == 0 & walls > 5),
                            yes = 1, no = 0),
         
         overcrowding_ratio = n_per/n_bedroom,
         mpi_overcrowding = ifelse((urban == 1 & overcrowding_ratio >= 3) |
                                     (urban == 0 & overcrowding_ratio > 3),
                                   yes = 1, no = 0)) %>% 
  
  # Simple average of every indicator
  mutate(mpi_housing = (mpi_water + mpi_excrete + mpi_floor + mpi_walls + mpi_overcrowding) / 5)

# -------------------------------------------------------------------------
