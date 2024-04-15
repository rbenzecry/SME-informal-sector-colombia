
# DATA --------------------------------------------------------------------

# Occupied module
occupied_raw <- read_dta("Tables/02_household-surveys/occupied_geih-2022-clean.dta",
                         col_select = c(all_of(id_cols), 
                                        "ORDEN",
                                        "P6920"))

# Labour force/workforce module
labour_force_raw <- read_dta("Tables/02_household-surveys/workforce_geih-2022-clean.dta",
                             col_select = c(all_of(id_cols), 
                                            "ORDEN",
                                            "P6240"))



# SANITY CHECKS -----------------------------------------------------------


# Contrasted results with:
# https://www.dane.gov.co/files/investigaciones/boletines/ech/ech/pres_ext_empleo_dic_22.pdf

# Occupied in december 2022
occupied_raw %>% 
  group_by(MES) %>% 
  summarise(occupied = sum(FEX_C18)) %>% 
  head(12)

# Occupied in 2022
occupied_raw %>% 
  summarise(occupied = sum(adj_weight))

# Labour force per month (NOTE: MES columns is wrong, it has 1 in almost every month)
labour_force_raw %>% 
  group_by(MES) %>% 
  summarise(PEA = sum(FEX_C18)) 


# SET UP ------------------------------------------------------------------

# OCCUPIED
occupied <- occupied_raw %>%
  mutate(id_house = paste(DIRECTORIO, SECUENCIA_P, sep = ""),
         id_per = paste(DIRECTORIO, SECUENCIA_P, ORDEN, sep = "")) %>% 
  
  # FILTER FOR ONLY THOSE HOUSEHOLDS IN EMICRON
  filter(id_house %in% emicron$id_house) %>% 
  
  rename(pension_fund = P6920) %>% 
  
  mutate(occupied = 1) 



# LABOUR FORCE
labour_force <- labour_force_raw %>% 
  mutate(id_house = paste(DIRECTORIO, SECUENCIA_P, sep = ""),
         id_per = paste(DIRECTORIO, SECUENCIA_P, ORDEN, sep = "")) %>% 
  # FILTER FOR ONLY THOSE HOUSEHOLDS IN EMICRON
  filter(id_house %in% emicron$id_house) %>% 
  
  rename(main_activity = P6240) %>% 


# LABOUR DIMENSION VARIABLES ----------------------------------------------

  # Add occupied variables to labour force data frame
  left_join(occupied) %>% 
  
  # Occupied and NOT affiliated to a pension fund
  mutate(occu_no_pension = ifelse(occupied == 1 & pension_fund == 2,
                                  yes = 1, no = 0)) %>% 
  
  # Summarise at the household level
  group_by(DPTO, AREA, DIRECTORIO, SECUENCIA_P, id_house) %>% 
  
  summarise(occu_weight = sum(occupied*adj_weight, na.rm = T),
            occu_np_weight = sum(occu_no_pension*adj_weight, na.rm = T),
            
            occupied = sum(occupied, na.rm = T),
            occupied_np = sum(occu_no_pension, na.rm = T),
            
            labour_force = n(),
            labour_force_w = sum(adj_weight),
            
            house_weight = mean(adj_weight)) %>% 
  ungroup() %>% 
  
  
  
  # ADD HOUSEHOLD LEVEL DATA SET
  left_join(household) %>% 
  
  # Calculate indicators
  mutate(eco_dep_ratio = ifelse(occupied != 0,
                                yes = n_per/occupied,
                                # Arbitrary high value when no one is occupied
                                no = 99),
         
         inf_work_ratio = occupied_np/labour_force,
         
         # Define if the household is deprived
         mpi_eco_dep = as.numeric(eco_dep_ratio >= 3),
         mpi_inf_work = as.numeric(inf_work_ratio > 0))


# CLEAN -------------------------------------------------------------------

# Reduce occupied to only a vector of the IDs of those occupied to free space
id_occupied <- occupied$id_per
rm(occupied, household)

# -------------------------------------------------------------------------