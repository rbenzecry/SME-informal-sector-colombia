
source("00_settings.R")
source("02_household-surveys/06_labour-dimension-mpi-2022.R")


# DATA --------------------------------------------------------------------

emicron_raw <- read.csv("Tables/01_emicron/emicron_index.csv")

# SET UP ------------------------------------------------------------------

emicron <- emicron_raw %>% 
  select(DIRECTORIO, SECUENCIA_P, 
         
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
  
  # MERGE
  left_join(labour_force, by = c("DIRECTORIO", "SECUENCIA_P"))


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
