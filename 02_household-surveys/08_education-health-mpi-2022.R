
# DATA --------------------------------------------------------------------

# Individual level module
individual_raw <- read_dta("Tables/02_household-surveys/individual_geih-2022-clean.dta",
                           # col_select = c(all_of(id_cols),
                           #                "ORDEN",
                           #                "P6040",
                           #                "P6160",
                           #                "P3042",
                           #                "P3043",
                           #                "P6170",
                           #                "P6090"),
                           n_max = 10^4
)



# SET UP ------------------------------------------------------------------

individual <- individual_raw %>% 
  mutate(id_house = paste(DIRECTORIO, SECUENCIA_P, sep = ""),
         id_per = paste(DIRECTORIO, SECUENCIA_P, ORDEN, sep = "")) %>%
  
  # FILTER FOR ONLY THOSE HOUSEHOLDS IN EMICRON
  filter(id_house %in% emicron$id_house) %>% 

  select(all_of(id_cols),
         id_house,
         id_per,
         
         age = P6040,
         literacy = P6160,
         edu_level = P3042,
         edu_highest_degree = P3043,
         edu_attendance = P6170,
         
         health_ss = P6090) %>% 
  
  # CHECK IF CORRECTION IS NEEDED WITH EDU LEVEL VARIABLE !!!
  mutate(edu_years = case_when(edu_highest_degree == 1 ~ 0,
                               
                               is.na(edu_highest_degree) & edu_level == 1 ~ 0,
                               is.na(edu_highest_degree) & edu_level == 2 ~ 0,
                               is.na(edu_highest_degree) & edu_level == 3 ~ 6,
                               
                               edu_highest_degree == 2 ~ 11,
                               edu_highest_degree == 3 ~ 12,
                               edu_highest_degree == 4 ~ 13,
                               
                               edu_highest_degree == 5 ~ 14,
                               edu_highest_degree == 6 ~ 14,
                               
                               edu_highest_degree == 7 ~ 15,
                               edu_highest_degree == 8 ~ 17,
                               edu_highest_degree == 9 ~ 17,
                               edu_highest_degree == 10 ~ 20,
                               TRUE~NA),
         
         edu_years_adult = ifelse(age >= 15,
                                  yes = edu_years, no = NA),
         
         illiterate = as.numeric(age >= 15 & literacy == 2)) %>%
  
  # Household ratios and deprivations
  group_by(id_house) %>% 
  mutate(avg_edu_years = mean(edu_years_adult, na.rm = T),
         illiterate_ratio = mean(illiterate, na.rm = T),
         
         mpi_edu_years = as.numeric(avg_edu_years < 9),
         mpi_literacy = as.numeric(illiterate_ratio > 0)) %>% 
  ungroup() %>% 
  
  
# CHILDREN AND YOUTH ------------------------------------------------------

  mutate(child_youth = as.numeric(age >= 6 & age <= 16),
         cy_edu_attend = ifelse(child_youth == 1 & edu_attendance == 2,
                                yes = 1, no = 0),
         child_labour = as.numeric(age >= 12 & age <= 17 &
                                     id_per %in% id_occupied)) %>% 
  # Household ratios and deprivations
  group_by(id_house) %>% 
  mutate(edu_attend_ratio = sum(cy_edu_attend)/sum(child_youth),
         mpi_edu_attend = edu_attend_ratio > 0,
         
         mpi_child_labour = as.numeric(sum(child_labour, na.rm = T) > 0)) %>% 
  ungroup() %>% 
  
       
# HEALTH ------------------------------------------------------------------

  # Above 5 yrs old and without health insurance
  mutate(poor_health_ss = ifelse(age > 5 & health_ss == 2,
                                 yes = 1, no = 0)) %>% 
  
  # Household ratios and deprivations
  group_by(id_house) %>% 
  mutate(health_ss_ratio = mean(poor_health_ss, na.rm = T),
         
         mpi_health_ss = health_ss_ratio > 0) %>% 
  ungroup()
                            
# -------------------------------------------------------------------------