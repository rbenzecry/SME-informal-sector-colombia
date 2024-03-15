
library(tidyverse)
library(readxl)
library(haven)
library(janitor)
library(data.table)
library(sjlabelled)
library(sjPlot)

rm(list = ls())

# DATA --------------------------------------------------------------------

initial_dir <- "Data/GEIH-2023/"
final_dir <- "/DTA/Migración.DTA"

months <- c("Enero", "Febrero", "Marzo", "Abril",
            "Mayo", "Junio", "Julio", "Agosto", 
            "Septiembre", "Octubre", "Noviembre", "Diciembre")

vector_files <- paste(initial_dir, months, final_dir, sep = "")
list_data <- lapply(X = vector_files, FUN = read_dta)
names(list_data) <- months

# SET UP ------------------------------------------------------------------

# Determine col types for each column of each data set
col_types <- lapply(list_data, 
                    # The function to apply to each data frame is looping over
                    # every column extracting the data type
                    function(x) sapply(x, class)) %>%
  
  # Covert to a data frame
  as_tibble() %>% 
  
  # I turn the data frame into a 1 or 0 if the value is character
  mutate(across(.cols = everything(),
                .fns = function(x) as.numeric(x == "character"))) %>% 
  
  # Add a column indicating if the column needs to be converted to character
  mutate(character_col = rowSums(.),
         
         # Add column names
         column = colnames(list_data$Enero),
         
         convert = ifelse(character_col > 0 & character_col < 12,
                          yes = 1, no = 0))

# Extract the column names of the column to convert
col_convert <- col_types %>% 
  filter(convert == 1) %>% 
  .$column


# Convert columns in every data set
for (i in 1:length(list_data)){
  
  list_data[[i]] <- list_data[[i]] %>% 
    mutate(across(.cols = all_of(col_convert),
                  .fns = as.character))
  
}


# MERGE -------------------------------------------------------------------

migration_2023 <- bind_rows(list_data) %>%
  
  # Correct a specific column
  mutate(P3373S1 = na_if(P3373S1, "."),
         
         # Generate household and person unique IDs
         id_house = paste(DIRECTORIO, HOGAR, sep = ""),
         id_person = paste(DIRECTORIO, HOGAR, ORDEN, sep = ""),
         
         # Adjusting monthly weights to the year
         adj_weight = FEX_C18/12)


# EXPLORATION -------------------------------------------------------------

# Identify unique identifier of household and person
nrow(list_data$Julio)
length(unique(list_data$Julio$DIRECTORIO))

# HOGAR and SECUENCIA_P are the same
table(list_data$Julio$SECUENCIA_P == list_data$Julio$HOGAR)

list_data$Julio %>% 
  # Gen new column pasting id suspects
  # DIRECTORIO identifies Vivienda
  # SECUENCIA_P identifies the household (hogar)
  # ORDER identifies people
  # HOGAR: numero que identifica la posición del hogar dentro de la vivienda
  mutate(id_person = paste(DIRECTORIO, SECUENCIA_P, ORDEN, sep = ""),
         id_house = paste(DIRECTORIO, SECUENCIA_P, sep = "")) %>% 
  .$id_person %>%
  unique() %>% 
  length()

# Total number of households
length(unique(migration_2023$id_house))
# Total number of people
length(unique(migration_2023$id_person))

# Weighted total number of people
list_data$Enero %>% 
  # filter(ORDEN == 1) %>% 
  .$FEX_C18 %>% 
  sum()


# Adjusted weighted total number of people
migration_2023 %>% 
  summarise(sum(adj_weight))


# -------------------------------------------------------------------------


