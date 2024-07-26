
# DATA --------------------------------------------------------------------

final_dir <- "/DTA/Características generales, seguridad social en salud y educación.DTA"

vector_files <- paste(initial_dir, months, final_dir, sep = "")
list_data <- lapply(X = vector_files, FUN = read_dta)
names(list_data) <- months


# SET UP ------------------------------------------------------------------


# Determine common columns across all months
common_cols <- colnames(list_data$Enero)[(colnames(list_data$Enero) %in% colnames(list_data$Marzo))]


# Keep only the common columns every month
list_data <- lapply(list_data,
                    function(x) select(x, all_of(common_cols))) 


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

annual_data <- bind_rows(list_data) %>%
  
  # Generate household and person unique IDs
  mutate(id_house = paste(DIRECTORIO, SECUENCIA_P, sep = ""),
         id_person = paste(DIRECTORIO, SECUENCIA_P, ORDEN, sep = ""),
         
         # Adjusting monthly weights to the year
         adj_weight = FEX_C18/12)


# -------------------------------------------------------------------------


