
source("00_settings.R")
# DATA --------------------------------------------------------------------

emicron_mpi <- read_dta("Tables/emicron-informality-mpi.dta")

# Import department names
geo_code_labels <- read_excel("Data/GEIH-2023/DICCIONARIO_DATOS_BASES_ANONIMIZADAS_GEIH_2023.xlsx",
                              sheet = "geo_codes")


# SET UP ------------------------------------------------------------------

dpto_names <- geo_code_labels %>% 
  filter(abb == "dpto")

emicron_mpi <- emicron_mpi %>% 
  left_join(select(dpto_names, code, name),
            by = c("DPTO" = "code")) %>% 
  rename(dpto_label = name)

# MPI rate vs Informality by DPTO -----------------------------------------

# Scatter plot
emicron_mpi %>% 
  group_by(dpto_label) %>% 
  summarise(informality_index = weighted.mean(II, adj_weight, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, adj_weight, na.rm = T),
            n_pop = sum(adj_weight, na.rm = T)/10^3) %>% 
  
  ggplot(aes(mpi_rate, informality_index)) +
  
  geom_point(aes(size = n_pop), col = "midnightblue", alpha = 0.5) +
  
  labs(x = "Multidimensional povery rate",
       y = "Informality Index (avg)",
       title = "Multidimensional poverty and Informality",
       subtitle = "By department") +
  custom_theme()


# Column chart
emicron_mpi %>% 
  group_by(dpto_label) %>% 
  summarise(informality_index = weighted.mean(II, adj_weight, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, adj_weight, na.rm = T),
            n_pop = sum(adj_weight, na.rm = T)/10^3) %>% 
  ungroup() %>%
  
  ggplot(aes(x = reorder(dpto_label, informality_index), 
             mpi_rate)) +
  
  geom_col(aes(fill = informality_index)) +
  geom_text(aes(label = round(informality_index, 1)), nudge_y = 0.05) +
  
  labs(x = "Department",
       y = "Multidimensional povery rate",
       title = "Multidimensional poverty and Informality",
       subtitle = "By department") +
  custom_theme() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


# Column chart
emicron_mpi %>% 
  group_by(dpto_label, urban) %>% 
  summarise(informality_index = weighted.mean(II, adj_weight, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, adj_weight, na.rm = T),
            n_pop = sum(adj_weight, na.rm = T)/10^3) %>% 
  ungroup() %>%
  
  # Clean NAs
  filter(!is.na(urban)) %>% 
  
  ggplot(aes(x = reorder(dpto_label, informality_index), 
             mpi_rate)) +
  
  geom_col(aes(fill = informality_index)) +
  geom_text(aes(label = round(informality_index, 1)), nudge_y = 0.05) +
  
  facet_grid(urban~.) +
  
  labs(x = "Department",
       y = "Multidimensional povery rate",
       title = "Multidimensional poverty and Informality",
       subtitle = "By department and rurality") +
  custom_theme() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


# MPI index vs Informality ------------------------------------------------

emicron_mpi %>%
  
  ggplot(aes(x = -mpi_index,
             y = II)) +
  geom_jitter(aes(alpha = adj_weight),
              height = 0.1,
              col = "midnightblue") +
  
  geom_vline(xintercept = -0.33, linewidth = 1) +
  geom_hline(yintercept = 3, linewidth = 1) +
  
  # Add labels
  labs(x = "Multidimensional Poverty Index (inverted)",
       y = "Informality Index",
       title = "Informality vs Muldimensional Poverty Index",
       subtitle = "MPI captures a percentage of deprivations in the household") +
  custom_theme()


# Without weighting
emicron_mpi %>%
  
  ggplot(aes(x = -mpi_index,
             y = II)) +
  geom_jitter(alpha = 1/50,
              height = 0.1,
              col = "midnightblue") +
  
  geom_vline(xintercept = -0.33, linewidth = 1) +
  geom_hline(yintercept = 3, linewidth = 1) +
  
  # Add labels
  labs(x = "Multidimensional Poverty Index (inverted)",
       y = "Informality Index",
       title = "Informality vs Muldimensional Poverty Index",
       subtitle = "MPI captures a percentage of deprivations in the household\nNot weighted") +
  custom_theme()


# MPI index vs Informality by Urbanity  -----------------------------------

emicron_mpi %>%
  filter(!is.na(urban)) %>% 
  
  ggplot(aes(x = -mpi_index,
             y = II)) +
  geom_jitter(aes(alpha = adj_weight),
              height = 0.1,
              col = "midnightblue") +
  
  geom_vline(xintercept = -0.33, linewidth = 1) +
  geom_hline(yintercept = 3, linewidth = 1) +
  
  facet_grid(urban~.) +
  
  # Add labels
  labs(x = "Multidimensional Poverty Index (inverted)",
       y = "Informality Index",
       title = "Informality vs Muldimensional Poverty Index by Urbanity",
       subtitle = "MPI captures a percentage of deprivations in the household\nBy urbanity") +
  custom_theme()


# Not weighted
emicron_mpi %>%
  filter(!is.na(urban)) %>% 
  
  ggplot(aes(x = -mpi_index,
             y = II)) +
  geom_jitter(alpha = 1/50,
              height = 0.1,
              col = "midnightblue") +
  
  geom_vline(xintercept = -0.33, linewidth = 1) +
  geom_hline(yintercept = 3, linewidth = 1) +
  
  facet_grid(urban~.) +
  
  # Add labels
  labs(x = "Multidimensional Poverty Index (inverted)",
       y = "Informality Index",
       title = "Informality vs Muldimensional Poverty Index by Urbanity",
       subtitle = "MPI captures a percentage of deprivations in the household\nBy urbanity - Not weighted") +
  custom_theme()

# INFORMALITY VS ECON. DEPENDENCY -----------------------------------------

emicron_mpi %>%
  
  # Invert econ dependency ratio to have the same direction as the informality
  # index (the hogher the better)
  ggplot(aes(x = -eco_dep_ratio,
             y = II)) +
  geom_jitter(aes(alpha = adj_weight),
              # alpha = 1/20,
              height = 0.1,
              width = 0.4,
              col = "midnightblue") +
  
  # Add lines that signal thresholds in each variable
  # Econ. dependency ratios above or equal to 3 are considered deprived/poor/vulnerable
  geom_vline(xintercept = -3, linewidth = 1) +
  
  # Informality index of 4 means formal
  geom_hline(yintercept = 3, linewidth = 1) +
  
  # Add labels
  labs(x = "Economic dependecy ratio (inverted)",
       y = "Informality Index",
       title = "Informality vs Economic dependency",
       subtitle = "Econ. dependency ratio = number of people per occupied member in the household") +
  custom_theme()



# Without weightings
emicron_mpi %>%
  
  ggplot(aes(x = -eco_dep_ratio,
             y = II)) +
  geom_jitter(alpha = 1/50,
              height = 0.1,
              width = 0.4,
              col = "midnightblue") +
  
  geom_vline(xintercept = -3, linewidth = 1) +
  geom_hline(yintercept = 3, linewidth = 1) +
  
  labs(x = "Economic dependecy ratio (inverted)",
       y = "Informality Index",
       title = "Informality vs Economic dependency",
       subtitle = "Econ. dependency ratio = number of people per occupied member in the household\nNot weighted") +
  custom_theme()


# INFORMALITY VS INFORMAL WORK --------------------------------------------


emicron_mpi %>%
  
  ggplot(aes(-inf_work_ratio, II)) +
  geom_jitter(aes(alpha = adj_weight),
              height = 0.1,
              width = 0.05,
              col = "midnightblue")  +
  
  geom_vline(xintercept = -0.06, linewidth = 1) +
  geom_hline(yintercept = 3, linewidth = 1) +
  
  labs(x = "Informal work ratio (inverted)",
       y = "Informality Index",
       title = "Informality vs Informal work in the household",
       subtitle = "Informal work ratio: occupied member not affiliated to pension") +
  
  custom_theme()

# PENDING -----------------------------------------------------------------

# By venezuelan, recent migrant, overcrowding ratio, edu_years, mpi_housing



# -------------------------------------------------------------------------