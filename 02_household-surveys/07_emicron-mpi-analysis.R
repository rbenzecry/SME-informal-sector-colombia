
rm(list = ls())
source("00_settings.R")

# DATA --------------------------------------------------------------------

emicron_raw <- read.csv("Tables/01_emicron/emicron_index.csv")

# SET UP ------------------------------------------------------------------

emicron <- emicron_raw %>% 
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
source("02_household-surveys/00_house-and-services-mpi-2022.R")

# Labour dimension
source("02_household-surveys/00_labour-mpi-2022.R")

# Education and health dimensions
source("02_household-surveys/00_education-health-mpi-2022.R")




# JOIN DATA SETS ----------------------------------------------------------



# INFORMALITY VS ECON. DEPENDENCY -----------------------------------------

emicron %>%

  # Invert econ dependency ratio to have the same direction as the informality
  # index (the hogher the better)
  ggplot(aes(x = -eco_dep_ratio,
             y = II)) +
  # geom_jitter(aes(alpha = adj_weight),
  #             # alpha = 1/20,
  #             height = 0.1,
  #             width = 0.4,
  #             col = "midnightblue") +
  geom_point(alpha = 1/50,
             stroke = 1000) +

  # Add lines that signal thresholds in each variable
  # Econ. dependency ratios above or equal to 3 are considered deprived/poor/vulnerable
  geom_vline(xintercept = -3, linewidth = 1) +

  # Informality index of 4 means formal
  geom_hline(yintercept = 3, linewidth = 1) +

  # Add labels
  labs(x = "Economic dependecy ratio (inverted)",
       y = "Informality Index",
       title = "Informality vs Economic dependency",
       subtitle = "Economic dependency ratio = number of people per occupied member in the household") +
  custom_theme()



# INFORMALITY VS INFORMAL WORK --------------------------------------------


emicron %>%

  ggplot(aes(-mpi_inf_work, II)) +
  geom_jitter(aes(alpha = adj_weight),
              height = 0.1,
              width = 0.4)  +
  custom_theme()

# -------------------------------------------------------------------------