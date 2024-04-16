

# DATA --------------------------------------------------------------------

venezuela_code <- 862

migration <- read_dta("Tables/02_household-surveys/migration_geih-2022-clean.dta") %>% 
 
# SET UP ------------------------------------------------------------------

  mutate(id_house = paste(DIRECTORIO, SECUENCIA_P, sep = ""),
         id_per = paste(DIRECTORIO, SECUENCIA_P, ORDEN, sep = "")) %>%
  
  # FILTER FOR ONLY THOSE HOUSEHOLDS IN EMICRON
  filter(id_house %in% emicron$id_house) %>% 
  
  select(all_of(id_cols),
         id_house,
         id_per,
         
         birth_country = P3373S3,
         
         col_nationality = P3374,
         nationality = P3374S1,
         
         country_5yrs_ago = P3382) %>% 
  
  # Birth country only contains countries different from Colombia
  mutate(born_colombia = as.numeric(is.na(birth_country)),
         foreigner = as.numeric(col_nationality == 3),
         
         venezuelan = case_when(nationality == venezuela_code ~ 1,
                                TRUE~0),
         
         recent_migrant = as.numeric(country_5yrs_ago == 4)) %>% 
  select(-c("PERIODO", "MES", "HOGAR", "CLASE"))

# -------------------------------------------------------------------------


  