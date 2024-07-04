
source("00_settings.R")

# DATA --------------------------------------------------------------------

emicron_mpi <- read_dta("Tables/emicron-informality-mpi.dta")

emicron_models <- read.csv("Tables/01_emicron/emicron_models.csv")

# Import department names
geo_code_labels <- read_excel("Data/GEIH-2023/DICCIONARIO_DATOS_BASES_ANONIMIZADAS_GEIH_2023.xlsx",
                              sheet = "geo_codes")


# SET UP ------------------------------------------------------------------

dpto_names <- geo_code_labels %>% 
  filter(abb == "dpto") %>% 
  mutate(name = ifelse(name == 'NORTE DE SANTANDER', 
                       yes = 'N. SANTANDER', no = name))


emicron_models <- emicron_models %>% 
  select(DIRECTORIO, SECUENCIA_P, SECUENCIA_ENCUESTA,
         cluster, bad_reason_create_business)


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
                                   TRUE~''))

# Of microbusiness owners
national_mpi_rate <- weighted.mean(emicron_mpi$mpi_poor, emicron_mpi$F_EXP)
national_avg_infor <- weighted.mean(emicron_mpi$II, emicron_mpi$F_EXP)

# DEPRIVATIONS VS POVERTY RATE --------------------------------------------

emicron_mpi %>% 
  group_by(dpto_label) %>% 
  summarise(mpi_index = weighted.mean(mpi_index, F_EXP, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, F_EXP, na.rm = T),
            n_pop = sum(F_EXP, na.rm = T)/10^3) %>% 
  
  ggplot(aes(mpi_rate, mpi_index)) +
  
  geom_point(aes(size = n_pop), col = "midnightblue") +
  geom_abline(slope = 1, intercept = 0) +
  
  ylim(0,1) +
  xlim(0,1) +
  
  labs(x = "Multidimensional povery rate",
       y = "Avg. percentage of deprivations",
       title = "Multidimensional poverty and percentage of deprivations",
       subtitle = "By department") +
  custom_theme()

# MPI rate vs Informality by DPTO -----------------------------------------

# Scatter plot
emicron_mpi %>% 
  filter(!is.na(dpto_label)) %>% 
  group_by(dpto_label) %>% 
  summarise(informality_index = weighted.mean(II, F_EXP, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, F_EXP, na.rm = T),
            n_pop = sum(F_EXP, na.rm = T)/10^3) %>% 
  
  ggplot(aes(mpi_rate*100, informality_index)) +
  
  geom_point(aes(size = n_pop), col = "midnightblue", alpha = 0.5) +
  scale_size_continuous(range = c(1, 10)) +
  
  labs(x = "Poverty rate (%)",
       y = "Avg. Informality Index",
       title = "Higher poverty is related to lower levels of formality",
       subtitle = "Multidimensional Poverty and Avg. Informality Index, by department",
       size = 'Population (k)') +
  custom_theme()+
  theme(legend.position = 'top')


# Scatter plot by department and deprivations
emicron_mpi %>% 
  group_by(dpto_label) %>% 
  summarise(informality_index = weighted.mean(II, F_EXP, na.rm = T),
            mpi_index = weighted.mean(mpi_index, F_EXP, na.rm = T),
            n_pop = sum(F_EXP, na.rm = T)/10^3) %>% 
  
  ggplot(aes(mpi_index, informality_index)) +
  
  geom_point(aes(size = n_pop), col = "midnightblue", alpha = 0.5) +
  scale_size_continuous(range = c(1, 10)) +
  
  labs(x = "Avg. weighted percentage of deprivations",
       y = "Informality Index (avg.)",
       title = "Multidimensional poverty (deprivations) and Informality",
       subtitle = "By area",
       size = 'Population') +
  custom_theme()


# Scatter plot by area 
emicron_mpi %>% 
  group_by(AREA) %>% 
  summarise(informality_index = weighted.mean(II, F_EXP, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, F_EXP, na.rm = T),
            n_pop = sum(F_EXP, na.rm = T)/10^3) %>% 
  
  ggplot(aes(mpi_rate*100, informality_index)) +
  
  geom_point(col = "midnightblue", alpha = 0.5, size = 5) +
  
  labs(x = "Poverty rate",
       y = "Avg. Informality Index",
       title = "Multidimensional poverty (deprivations) and Informality",
       subtitle = "By area",
       size = 'Population') +
  custom_theme()

# Column chart
emicron_mpi %>% 
  filter(!is.na(dpto_label)) %>% 
  group_by(dpto_label) %>% 
  summarise(informality_index = weighted.mean(II, F_EXP, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, F_EXP, na.rm = T),
            n_pop = sum(F_EXP, na.rm = T)/10^3) %>% 
  ungroup() %>% 
  
  ggplot(aes(# x = reorder(dpto_label, informality_index),
             x = reorder(dpto_label, -mpi_rate),
             mpi_rate*100)) +
  
  geom_col(aes(fill = informality_index)) +
  geom_text(aes(label = round(informality_index, 1)), nudge_y = 3) +
  
  labs(x = "Department",
       y = "Poverty Rate (%)",
       subtitle = "Note: numeric labels above the bars show the average informality index of each department",
       fill = 'Informality') +
  custom_theme() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        plot.caption = element_text(hjust = 0))


# Column chart
emicron_mpi %>% 
  group_by(dpto_label, urban) %>% 
  summarise(informality_index = weighted.mean(II, F_EXP, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, F_EXP, na.rm = T),
            n_pop = sum(F_EXP, na.rm = T)/10^3) %>% 
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
       subtitle = "By department and rurality",
       fill = 'Informality Index') +
  custom_theme() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


# MPI index vs Informality ------------------------------------------------

emicron_mpi %>%
  
  ggplot(aes(x = mpi_index,
             y = II)) +
  geom_jitter(aes(alpha = F_EXP),
              height = 0.1, width = 0.01,
              col = "midnightblue") +
  
  geom_vline(xintercept = 0.33, linewidth = 1) +
  geom_hline(yintercept = 2, linewidth = 1) +
  
  scale_x_reverse() +
  scale_alpha_continuous(range = c(0.1, 0.5)) +
  
  # Add labels
  labs(x = "Multidimensional Poverty Index (inverted)",
       y = "Informality Index",
       title = "Microbusiness owners are spread across the space, except for the poor and formal quadrant...",
       subtitle = "Informality and Muldimensional Poverty") +
  custom_theme() +
  theme(legend.position = "none")


# Without weighting
emicron_mpi %>%
  
  ggplot(aes(x = mpi_index,
             y = II)) +
  geom_jitter(alpha = 1/50,
              height = 0.1, width = 0.01,
              col = "midnightblue") +
  
  geom_vline(xintercept = 0.33, linewidth = 1) +
  geom_hline(yintercept = 2, linewidth = 1) +
  
  scale_x_reverse() +
  
  # Add labels
  labs(x = "Multidimensional Poverty Index (inverted)",
       y = "Informality Index",
       title = "Informality vs Muldimensional Poverty Index",
       subtitle = "MPI captures the percentage of deprivations in the household\nNot weighted") +
  custom_theme()


# MPI vs II BY CLUSTER ----------------------------------------------------

# MPI RATE
emicron_mpi %>%
  # Summarising at cluster level and cleaning
  group_by(cluster, cluster_label) %>% 
  summarise(informality_index = weighted.mean(II, F_EXP, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, F_EXP, na.rm = T),
            n_pop = sum(F_EXP, na.rm = T)/10^3) %>%
  mutate(cluster_interest = as.factor(case_when(cluster == 4 ~ 1,
                                                cluster == 5 ~ 0.5,
                                                TRUE~0))) %>% 
  ungroup() %>% 
  
  # Main aspects of the plot
  ggplot(aes(mpi_rate*100, informality_index)) +
  
  geom_point(aes(size = n_pop, col = cluster_interest)) +
  geom_text(aes(label = cluster), nudge_y = 0.2) +
  
  # Aesthetic details
  scale_size_continuous(range = c(10, 20)) +
  
  geom_vline(aes(xintercept = national_mpi_rate*100)) +
  geom_hline(aes(yintercept = national_avg_infor)) +
  
  scale_x_reverse() +
  scale_color_manual(values = c('gray', 'midnightblue', 'darkgreen')) +
  
  # Add labels
  labs(x = "Multidimensional Poverty Rate (inverted)",
       y = "Avg. Informality Index",
       title = "Microbusiness owners are spread across the space, except for the poor and formal quadrant...",
       subtitle = "Informality and Muldimensional Poverty") +
  custom_theme() +
  theme(legend.position = "none")




# PANEL OF SELECTED CLUSTERS ----------------------------------------------

emicron_mpi %>%
  mutate(cluster_interest = as.factor(case_when(cluster == 4 ~ 1,
                                                cluster == 5 ~ 0.5,
                                                TRUE~0))) %>%
  
  ggplot(aes(x = mpi_index, y = II)) +
  geom_jitter(aes(alpha = F_EXP, col = cluster_interest),
              height = 0.1, width = 0.01) +
  # To bring to the front because the cluster has a small number of obs
  geom_jitter(data = filter(emicron_mpi, cluster == 4),
              aes(alpha = F_EXP), col = 'midnightblue',
              height = 0.1, width = 0.01) +
  
  geom_vline(xintercept = 0.33, linewidth = 1) +
  geom_hline(yintercept = 2, linewidth = 1) +
  
  scale_x_reverse() +
  scale_alpha_continuous(range = c(0.2, 0.5)) +
  scale_color_manual(values = c('lightgrey', 'darkgreen','midnightblue')) +
  
  # Add labels
  labs(x = "Multidimensional Poverty Index (inverted)",
       y = "Informality Index",
       title = "Microbusiness owners are spread across the space, except for the poor and formal quadrant...",
       subtitle = "Informality and Muldimensional Poverty, selected clusters") +
  custom_theme() +
  theme(legend.position = "none")



# MPI index vs Informality by Urbanity  -----------------------------------

emicron_mpi %>%
  filter(!is.na(urban)) %>% 
  
  ggplot(aes(x = -mpi_index,
             y = II)) +
  geom_jitter(aes(alpha = F_EXP),
              height = 0.1,
              col = "midnightblue") +
  
  geom_vline(xintercept = -0.33, linewidth = 1) +
  geom_hline(yintercept = 3, linewidth = 1) +
  
  facet_grid(urban~.) +
  
  # Add labels
  labs(x = "Multidimensional Poverty Index (inverted)",
       y = "Informality Index",
       title = "Informality vs Muldimensional Poverty Index by Urbanity",
       subtitle = "MPI captures the percentage of deprivations in the household\nBy urbanity") +
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
       subtitle = "MPI captures the percentage of deprivations in the household\nBy urbanity - Not weighted") +
  custom_theme()


# MPI index vs Informality by DPTO ----------------------------------------

emicron_mpi %>%
  filter(!is.na(dpto_label)) %>% 
  
  ggplot(aes(x = -mpi_index,
             y = II)) +
  geom_jitter(aes(alpha = F_EXP),
              height = 0.1,
              col = "midnightblue") +
  
  geom_vline(xintercept = -0.33, linewidth = 1) +
  geom_hline(yintercept = 3, linewidth = 1) +
  
  facet_wrap(reorder(dpto_label, mpi_poor, 
                     FUN = mean)~.) +
  
  # Add labels
  labs(x = "Multidimensional Poverty Index (inverted)",
       y = "Informality Index",
       title = "Informality vs Muldimensional Poverty Index by Department",
       subtitle = "MPI captures the percentage of deprivations in the household") +
  custom_theme() +
  theme(legend.position = "none")


# Not weighted
emicron_mpi %>%
  filter(!is.na(dpto_label)) %>% 
  
  ggplot(aes(x = -mpi_index,
             y = II)) +
  geom_jitter(alpha = 1/25,
              height = 0.1,
              col = "midnightblue") +
  
  geom_vline(xintercept = -0.33, linewidth = 1) +
  geom_hline(yintercept = 3, linewidth = 1) +
  
  facet_wrap(reorder(dpto_label, mpi_poor, 
                     FUN = mean)~.) +
  
  # Add labels
  labs(x = "Multidimensional Poverty Index (inverted)",
       y = "Informality Index",
       title = "Informality vs Muldimensional Poverty Index by Department",
       subtitle = "MPI captures the percentage of deprivations in the household") +
  custom_theme() +
  theme(legend.position = "none")


# INFORMALITY VS ECON. DEPENDENCY -----------------------------------------

emicron_mpi %>%
  
  # Invert econ dependency ratio to have the same direction as the informality
  # index (the hogher the better)
  ggplot(aes(x = -eco_dep_ratio,
             y = II)) +
  geom_jitter(aes(alpha = F_EXP),
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
  geom_jitter(aes(alpha = F_EXP),
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



# OVERCROWDING ------------------------------------------------------------

emicron_mpi %>%
  
  ggplot(aes(-overcrowding_ratio, II)) +
  geom_jitter(aes(alpha = F_EXP),
              height = 0.1,
              width = 0.05,
              col = "midnightblue")  +
  
  geom_vline(xintercept = -3, linewidth = 1) +
  geom_hline(yintercept = 3, linewidth = 1) +
  
  labs(x = "Overcrowding ratio (inverted)",
       y = "Informality Index",
       title = "Informality vs Overcrowding",
       subtitle = "Overcrowding ratio: number of people per bedroom") +
  
  custom_theme()


# YEARS OF EDUCATION ------------------------------------------------------

emicron_mpi %>%
  
  ggplot(aes(edu_years_adult, II)) +
  geom_jitter(aes(alpha = F_EXP),
              height = 0.1,
              width = 0.05,
              col = "midnightblue")  +
  
  geom_vline(xintercept = 9, linewidth = 1) +
  geom_hline(yintercept = 3, linewidth = 1) +
  
  labs(x = "Average years of education",
       y = "Informality Index",
       title = "Informality vs Years of Education",
       subtitle = "") +
  
  custom_theme()

# MPI HOUSING -------------------------------------------------------------

emicron_mpi %>%
  
  ggplot(aes(-mpi_housing, II)) +
  geom_jitter(aes(alpha = F_EXP),
              height = 0.1,
              width = 0.05,
              col = "midnightblue")  +
  
  geom_vline(xintercept = -0.33, linewidth = 1) +
  geom_hline(yintercept = 3, linewidth = 1) +
  
  labs(x = "Housing dimension of MPI",
       y = "Informality Index",
       title = "Informality vs Housing conditions and public services",
       subtitle = "Percentage of deprivations in the housing dimension") +
  
  custom_theme()

# PENDING -----------------------------------------------------------------

# By venezuelan, recent migrant, overcrowding ratio, edu_years, mpi_housing

emicron_mpi %>% 
  group_by(dpto_label) %>% 
  summarise(informality_index = weighted.mean(II, F_EXP, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, F_EXP, na.rm = T),
            mpi_avg = weighted.mean(mpi_index, F_EXP, na.rm = T),
            n_pop = sum(F_EXP, na.rm = T)/10^3) %>% 
  arrange(desc(mpi_rate)) %>% 
  head(20)




emicron_mpi %>% 
  ggplot(aes(F_EXP, F_EXP)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  custom_theme()




# -------------------------------------------------------------------------