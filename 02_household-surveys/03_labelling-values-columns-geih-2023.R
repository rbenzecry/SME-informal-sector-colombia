
source("02_household-surveys/01_join-migration-geih-2023.R")
source("02_household-surveys/02_join-individual-geih-2023.R")

# DATA --------------------------------------------------------------------

dictionary_m <- read_excel("Data/GEIH-2023/DICCIONARIO_DATOS_BASES_ANONIMIZADAS_GEIH_2023.xlsx",
                           sheet = "migration_module")

dictionary_p <- read_excel("Data/GEIH-2023/DICCIONARIO_DATOS_BASES_ANONIMIZADAS_GEIH_2023.xlsx",
                           sheet = "person_module")

# SET UP ------------------------------------------------------------------

dictionary_m <- dictionary_m %>% 
  clean_names() %>% 
  mutate(across(.cols = everything(),
                .fns = function(x) trimws(x, which = "both")))

# Person module
dictionary_p <- dictionary_p %>% 
  clean_names() %>% 
  mutate(across(.cols = everything(),
                .fns = function(x) trimws(x, which = "both")))

# RENAME MIGRATION --------------------------------------------------------

var_names <- as_tibble(colnames(migration_2023)) %>% 
  left_join(dictionary_m,
            by = c("value" = "original")) %>% 
  mutate(final_name = ifelse(is.na(var_name),
                             yes = value, no = var_name))


migration_2023 <- migration_2023 %>% 
  set_names(var_names$final_name)


# RENAME PERSON -----------------------------------------------------------

var_names_p <- as_tibble(colnames(annual_data)) %>% 
  left_join(dictionary_p,
            by = c("value" = "original")) %>% 
  mutate(final_name = ifelse(is.na(var_name),
                             yes = value, no = var_name))


annual_data <- annual_data %>% 
  set_names(var_names_p$final_name)


# CHANGE VALUES -----------------------------------------------------------

# EXPORT ------------------------------------------------------------------

write_dta(migration_2023, "Tables/02_household-surveys/03_migration-2023-clean.dta")
write_dta(annual_data, "Tables/02_household-surveys/03_individual-2023-clean.dta")

# -------------------------------------------------------------------------


