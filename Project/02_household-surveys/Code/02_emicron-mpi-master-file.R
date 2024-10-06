
# rm(list = ls())
source("Project/00_settings.R")

# DATA --------------------------------------------------------------------

emicron <- read.csv("Outputs/01_emicron/emicron_index.csv") %>% 

# SET UP ------------------------------------------------------------------

  select(DIRECTORIO, SECUENCIA_P, SECUENCIA_ENCUESTA,
         
         starts_with("II"),
         
         VENTAS_ANIO_ANTERIOR,
         COSTOS_ANIO_ANTERIOR,
         CONSUMO_INTERMEDIO,
         GASTOS_MES,
         
         PRESTACIONES,
         REMUNERACION_TOTAL,
         SUELDOS,
         
         VALOR_AGREGADO,
         INGRESO_MIXTO,
         
         FEX_MICRO_DPTO,
         F_EXP) %>% 
  mutate(id_house = paste(as.character(DIRECTORIO), 
                          as.character(SECUENCIA_P), 
                          sep = ""),
         id_per = paste(id_house, as.character(SECUENCIA_ENCUESTA), sep = ""))


# Define the common columns to read from every module
id_cols <- c("id_house", "adj_weight", 
             "PERIODO", "MES",
             "DIRECTORIO", "SECUENCIA_P", 
             "HOGAR",
             "CLASE",
             "FEX_C18",
             "DPTO", "AREA")

# MPI INDICATORS ----------------------------------------------------------

# Housing and services dimension
source("Project/02_household-surveys/Code/00_house-and-services-mpi-2022.R")

# Labour dimension
source("Project/02_household-surveys/Code/00_labour-mpi-2022.R")

# Education and health dimensions
source("Project/02_household-surveys/Code/00_education-health-mpi-2022.R")

# Add basic migrant variables
source("Project/02_household-surveys/Code/00_migration-emicron-2022.R")

# JOIN DATA SETS ----------------------------------------------------------

emicron <- emicron %>% 
  left_join(labour_force) %>% 
  left_join(individual) %>% 
  left_join(migration) %>% 
  
  # Create MPI index
  mutate(mpi_index = (mpi_water + mpi_excrete + mpi_floor + mpi_walls + mpi_overcrowding)*0.04 + 
           (mpi_eco_dep + mpi_inf_work)*0.1 + 
           (mpi_edu_years + mpi_literacy)*0.1 + 
           (mpi_edu_attend + mpi_school_lag + mpi_care_barriers + mpi_child_labour)*(0.05) +
           (mpi_health_ss)*0.2,
         
         # Same weight for all indicators, i.e. percentage of deprivations
         mpi_deprivations = (mpi_water + mpi_excrete + mpi_floor + mpi_walls + mpi_overcrowding +
                               mpi_eco_dep + mpi_inf_work + 
                               mpi_edu_years + mpi_literacy + 
                               mpi_edu_attend + mpi_school_lag + mpi_child_labour +
                               mpi_health_ss) / 12,
                           
         # Binary variable of poverty: 1 means POOR 
         mpi_poor = as.numeric(mpi_index >= 0.333)) %>% 
  
  # Order and clean
  select("DPTO", "urban", "AREA", 
         
         "id_house", "id_per", 
         
         "adj_weight",
         
         # Informality index
         "II_D1", "II_D2", "II_D3", "II_D4", "II",
         
         # MPI INDICATORS
         "mpi_index",
         "mpi_poor",
         
         # Dwelling/house and services
         "mpi_water", 
         "mpi_excrete", 
         "mpi_floor", 
         "mpi_walls", 
         "mpi_overcrowding", 
         "mpi_housing", 
         # Labour
         "mpi_eco_dep", 
         "mpi_inf_work",
         "mpi_labour",
         # Education
         "mpi_edu_years", 
         "mpi_literacy",
         "mpi_education",
         # Children and youth
         "mpi_edu_attend", 
         "mpi_school_lag",
         "mpi_care_barriers",
         "mpi_child_labour",
         "mpi_cy",
         # Health
         "mpi_health_ss",
         
         # Percentage of deprivations
         "mpi_deprivations",
         
         # Emicron variables
         "VENTAS_ANIO_ANTERIOR", "COSTOS_ANIO_ANTERIOR", 
         "CONSUMO_INTERMEDIO", "GASTOS_MES", 
         "VALOR_AGREGADO","INGRESO_MIXTO", 
         "PRESTACIONES", "REMUNERACION_TOTAL", "SUELDOS", 
         
         # Migration variables
         "birth_country",
         "col_nationality",
         "nationality",
         "country_5yrs_ago",
         "born_colombia",
         "foreigner",       
         "venezuelan",
         "recent_migrant",
         
         # General individual variables
         "avg_edu_years", 
         "illiterate_ratio", 
         
         "edu_attend_ratio", 
         
         "health_ss_ratio", 
         
         "age", 
         
         "literacy", 
         "edu_level", 
         "edu_highest_degree", 
         "edu_attendance", 
         "edu_years", 
         "edu_years_adult", 
         "illiterate", 
         
         "health_ss", 
         
         "child_youth", 
         "cy_edu_attend",
         "school_lag",
         "care_barriers",
         "child_labour",
         
         "poor_health_ss", 
         
         # General dwelling and household dimension variables 
         "overcrowding_ratio", 
         
         "n_per", 
         "water_source", 
         "excrete_disposal", 
         "floors", 
         "walls", 
         "n_bedroom",
         
         # Labour dimension variables
         "eco_dep_ratio", 
         "inf_work_ratio", 
         
         "occupied", 
         "occupied_np", 
         "occu_weight", 
         "occu_np_weight", 
         "labour_force", 
         "labour_force_w", 
         "house_weight",  
         
         "DIRECTORIO", "SECUENCIA_P", "SECUENCIA_ENCUESTA", 
         "PERIODO", "MES",
         "FEX_C18", "FEX_MICRO_DPTO", "F_EXP"
         )
  
# Check NAs
table(is.na(emicron$mpi_index))
table(is.na(emicron$foreigner))

# EXPORT ------------------------------------------------------------------

write_dta(emicron, "Outputs/02_emicron-informality-mpi.dta")

# -------------------------------------------------------------------------
