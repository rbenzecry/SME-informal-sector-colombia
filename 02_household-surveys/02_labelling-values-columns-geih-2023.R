
source("02_household-surveys/01_clean-migration-geih-2023.R")

# DATA --------------------------------------------------------------------

dictionary <- read_excel("Data/GEIH-2023/DICCIONARIO_DATOS_BASES_ANONIMIZADAS_GEIH_2023.xlsx",
                         sheet = "migration_module")


# SET UP ------------------------------------------------------------------

dictionary <- dictionary %>% 
  clean_names() %>% 
  mutate(across(.cols = everything(),
                .fns = function(x) trimws(x, which = "both")))

# RENAME COLUMNS ----------------------------------------------------------

var_names <- as_tibble(colnames(migration_2023)) %>% 
  left_join(dictionary,
            by = c("value" = "original")) %>% 
  mutate(final_name = ifelse(is.na(var_name),
                             yes = value, no = var_name))


migration_2023 <- migration_2023 %>% 
  set_names(var_names$final_name)



# CHANGE VALUES -----------------------------------------------------------

# EXPORT ------------------------------------------------------------------

# write_dta("Tables/02_household-surveys/01_migration-2023-clean.dta")

# -------------------------------------------------------------------------


