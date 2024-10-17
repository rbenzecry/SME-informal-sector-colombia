
source("Project/Code/02_household-surveys/00_settings.R")

# DATA --------------------------------------------------------------------

emicron_mpi <- read_dta("Project/Data/02_emicron-informality-mpi.dta")

emicron_models <- read.csv("Project/Data/emicron_models.csv")

# Import department names
dictionary <- read_excel("Project/Data/DICCIONARIO_DATOS_BASES_ANONIMIZADAS_GEIH_2023.xlsx",
                         sheet = "Diccionario de datos")


# SET UP ------------------------------------------------------------------


# Clean dictionary to keep geo codes
geo_code_labels <- dictionary %>% 
  clean_names() %>% 
  # Fill NA values with the last non-NA value (found above)
  fill(id_de_la_variable, descipcion_de_la_variable, .direction = "down") %>% 
  
  filter(id_de_la_variable %in% c("DPTO", "AREA")) %>%
  
  # Clean variable names
  select(geo_level = id_de_la_variable,
         code = dominios_categorias_valores,
         name = regla_de_validacion_en_lenguaje_natural) %>% 
  distinct(.keep_all = T)

# Keep only depto names
dpto_names <- geo_code_labels %>% 
  filter(geo_level == "DPTO") %>% 
  mutate(name = ifelse(name == 'NORTE DE SANTANDER', 
                       yes = 'N. SANTANDER', no = name))


# EMICRON
emicron_models <- emicron_models %>% 
  select(DIRECTORIO, SECUENCIA_P, SECUENCIA_ENCUESTA,
         cluster, 
         bad_reason_create_business,
         # number of workers (including owner) on average
         n_workers = P3091,
         # People who help (tiene personas que le ayudan? Sí = 1)
         n_helpers = P3031)


emicron_mpi <- emicron_mpi %>%
  # Keep only those who have data on GEIH (which is everyone except for January observations)
  filter(!is.na(mpi_index)) %>% 
  left_join(select(dpto_names, code, name),
            by = c("DPTO" = "code")) %>% 
  rename(dpto_label = name) %>% 
  
  left_join(emicron_models) %>% 
  
  # Add cluster labels
  mutate(cluster_label = case_when(cluster == 4 ~ "Migrants",
                                   cluster == 5 ~ 'Benefits',
                                   TRUE~''),
         
         # Define informal businesses according to DANE's threshold
         informal = as.numeric(II <= 2),
         
         # Quadrants
         quadrant = case_when(mpi_poor == 0 & informal == 0 ~ 'I',
                              mpi_poor == 1 & informal == 0 ~ 'II',
                              mpi_poor == 1 & informal == 1 ~ 'III',
                              mpi_poor == 0 & informal == 1 ~ 'IV'),
         
         # Do not pay full social benefits = 1
         informal_D2 = ifelse(II_D2 != 1,
                              yes = 1, no = 0),
         # Workers from the Benefits cluster that do not receive full social benefits
         worker_no_benefits = ifelse(cluster == 5,
                                     yes = n_workers*informal_D2, no = 0))



# MPI RATES ---------------------------------------------------------------

# Of microbusiness owners
national_mpi_rate <- weighted.mean(emicron_mpi$mpi_poor, emicron_mpi$F_EXP)

# Migrants MPI rate 
emicron_mpi %>% 
  group_by(foreigner) %>% 
  summarise(weighted.mean(mpi_poor, F_EXP))


# PERCENTAGE PER QUADRANT -------------------------------------------------

# Percentage by quadrant
emicron_mpi %>% 
  group_by(quadrant) %>% 
  summarise(sum(F_EXP)/sum(emicron_mpi$F_EXP))

# Another route:
# Formal and poor
weighted.mean(emicron_mpi$mpi_poor == 1 & emicron_mpi$informal == 0,
              emicron_mpi$F_EXP)*100 #+

# Informal and poor
weighted.mean(emicron_mpi$mpi_poor == 1 & emicron_mpi$informal == 1,
              emicron_mpi$F_EXP)*100 #+
# Formal and non-poor
weighted.mean(emicron_mpi$mpi_poor == 0 & emicron_mpi$informal == 0,
              emicron_mpi$F_EXP)*100 #+

# Informal and non-poor 
weighted.mean(emicron_mpi$mpi_poor == 0 & emicron_mpi$informal == 1,
              emicron_mpi$F_EXP)*100



# CLUSTER SUMMARY ---------------------------------------------------------


# Cluster summaries
cluster_mpi_ii <- emicron_mpi %>%
  # Summarising at cluster level and cleaning
  group_by(cluster, cluster_label) %>% 
  summarise(informality_index = weighted.mean(II, F_EXP, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, F_EXP, na.rm = T),
            n_pop = sum(F_EXP, na.rm = T)/10^3) %>%
  mutate(cluster_interest = as.factor(case_when(cluster == 4 ~ 1,
                                                cluster == 5 ~ 0.5,
                                                TRUE~0))) %>% 
  ungroup()



# MIGRANTS AND BENEFITS ---------------------------------------------------


# Percentage of migrants in the Migrants cluster
emicron_mpi %>% 
  group_by(cluster) %>% 
  summarise(weighted.mean(foreigner, F_EXP))


# Number of worker without FULL social benefits in the Benefits cluster
emicron_mpi %>% 
  group_by(cluster) %>% 
  summarise(weighted.mean(worker_no_benefits, F_EXP),
            sum(worker_no_benefits*F_EXP))


# BENEFITS CLUSTER --------------------------------------------------------

# Expanded number of people in Benefits cluster 
n_c5 <- emicron_mpi %>% 
  filter(cluster == 5) %>% 
  summarise(sum(F_EXP)) %>% 
  pull()

# Percentage per quadrant
emicron_mpi %>% 
  filter(cluster_label == "Benefits") %>% 
  group_by(quadrant) %>% 
  summarise(sum(F_EXP)/n_c5) 


# -------------------------------------------------------------------------
