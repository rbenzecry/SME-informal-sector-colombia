
# DATA --------------------------------------------------------------------

# Individual level module
individual <- read_dta("Tables/02_household-surveys/individual_geih-2022-clean.dta") %>% 
                           # n_max = 10^4)



# SET UP ------------------------------------------------------------------

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

# EDUCATION ---------------------------------------------------------------

  # CHECK IF CORRECTION IS NEEDED WITH EDU LEVEL VARIABLE !!!
  mutate(edu_years = case_when(edu_highest_degree == 1 ~ 0,
                               
                               is.na(edu_highest_degree) & edu_level == 1 ~ 0,
                               is.na(edu_highest_degree) & edu_level == 2 ~ 0,
                               is.na(edu_highest_degree) & edu_level == 99 ~ 0,
                               
                               is.na(edu_highest_degree) & edu_level == 3 ~ 6,
                               is.na(edu_highest_degree) & edu_level == 4 ~ 6,
                               
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
  
  # Create the summary index for the education dimension
  mutate(mpi_education = (mpi_edu_years + mpi_literacy) / 2) %>% 
  
  
# CHILDREN AND YOUTH ------------------------------------------------------

  mutate(child_youth = as.numeric(age >= 6 & age <= 16),
         cy_edu_attend = ifelse(child_youth == 1 & edu_attendance == 2,
                                yes = 1, no = 0),
         child_labour = as.numeric(age >= 12 & age <= 17 &
                                     id_per %in% id_occupied)) %>% 
  # Household ratios and deprivations
  group_by(id_house) %>% 
  
  mutate(edu_attend_ratio = ifelse(child_youth > 0,
                                   yes = sum(cy_edu_attend)/sum(child_youth),
                                   no = 0),
         child_occupied = ifelse(child_labour > 0,
                                 yes = sum(child_labour, na.rm = T),
                                 no = 0),
         
         mpi_edu_attend = as.numeric(edu_attend_ratio > 0),
         mpi_child_labour = as.numeric(child_occupied > 0)) %>% 
  
  ungroup() %>% 
  
  # Create the summary index for the children and youth dimension
  mutate(mpi_cy = (mpi_edu_attend + mpi_child_labour) / 2) %>% 
  
  
       
# HEALTH ------------------------------------------------------------------

  # Above 5 yrs old and without health insurance
  mutate(poor_health_ss = ifelse(age > 5 & health_ss == 2,
                                 yes = 1, no = 0)) %>% 
  
  # Household ratios and deprivations
  group_by(id_house) %>% 
  mutate(health_ss_ratio = mean(poor_health_ss, na.rm = T),
         
         mpi_health_ss = as.numeric(health_ss_ratio > 0)) %>% 
  ungroup() %>% 
  
  
  # Drop problematic columns
  select(-c("PERIODO", "MES", "HOGAR", "CLASE"))
                            
# -------------------------------------------------------------------------