
source("Project/Code/02_household-surveys/00_settings.R")

# DATA --------------------------------------------------------------------

emicron_mpi <- read_dta("Project/Data/02_emicron-informality-mpi.dta")

emicron_models <- read.csv("Project/Data/emicron_native_clusters.csv")

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


# 1. MPI by DPTO coloured by II -------------------------------------------


p_mpi_dpto <- emicron_mpi %>% 
  filter(!is.na(dpto_label)) %>% 
  group_by(dpto_label) %>% 
  summarise(informality_index = weighted.mean(II, F_EXP, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, F_EXP, na.rm = T),
            n_pop = sum(F_EXP, na.rm = T)/10^3) %>% 
  ungroup() %>% 
  
  ggplot(aes(x = reorder(dpto_label, informality_index),
             # x = reorder(dpto_label, -mpi_rate),
             mpi_rate*100)) +
  
  geom_col(aes(fill = informality_index)) +
  geom_text(aes(label = round(informality_index, 1)), nudge_y = 3) +
  
  labs(x = "Department",
       y = "Poverty Rate (%)",
       subtitle = "Note: numeric labels above the bars show the average formality index of each department",
       fill = 'Formality') +
  custom_theme() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        plot.caption = element_text(hjust = 0))



# 2. MPI vs II by DPTO (scatter) ------------------------------------------

 
p_scatter_mpi_ii <- emicron_mpi %>% 
  filter(!is.na(dpto_label)) %>% 
  group_by(dpto_label) %>% 
  summarise(informality_index = weighted.mean(II, F_EXP, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, F_EXP, na.rm = T),
            n_pop = sum(F_EXP, na.rm = T)/10^3) %>% 
  
  ggplot(aes(mpi_rate*100, informality_index)) +
  
  geom_point(aes(size = n_pop), col = "midnightblue", alpha = 0.5) +
  scale_size_continuous(range = c(1, 10)) +
  
  labs(x = "Poverty rate (%)",
       y = "Avg. Formality Index",
       title = "Higher poverty is related to lower levels of formality",
       subtitle = "Multidimensional Poverty and Avg. Formality Index, by department",
       size = 'Population (k)') +
  custom_theme()+
  theme(legend.position = 'top')



# 3. Panel MPI vs II ------------------------------------------------------

panel_mpi_ii <- emicron_mpi %>%
  
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
       y = "Formality Index",
       title = "Microbusiness owners are spread across the space, except for the poor and formal quadrant...",
       subtitle = "Formality and Muldimensional Poverty") +
  custom_theme() +
  theme(legend.position = "none")


# 4. MPI vs II by cluster -------------------------------------------------


p_rates_clusters <- emicron_mpi %>%
  # Summarising at cluster level and cleaning
  group_by(cluster, cluster_label) %>% 
  summarise(informality_index = weighted.mean(II, F_EXP, na.rm = T),
            mpi_rate = weighted.mean(mpi_poor, F_EXP, na.rm = T),
            n_pop = sum(F_EXP, na.rm = T)/10^3) %>%
  mutate(cluster_interest = as.factor(case_when(cluster == 5 ~ 1,
                                                # cluster == 6 ~ 0.5,
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
  scale_color_manual(values = c('gray', 'darkgreen')) +
  
  # Add labels
  labs(x = "Multidimensional Poverty Rate (inverted)",
       y = "Avg. Formality Index",
       title = "Microbusiness owners are spread across the space, except for the poor and formal quadrant...",
       subtitle = "Formality and Muldimensional Poverty") +
  custom_theme() +
  theme(legend.position = "none")



# 5. Panel MPI vs II selected clusters ------------------------------------

p_panel_clusters <- emicron_mpi %>%
  mutate(cluster_interest = as.factor(case_when(cluster == 5 ~ 1,
                                                # cluster == 6 ~ 0.5,
                                                TRUE~0))) %>%
  
  ggplot(aes(x = mpi_index, y = II)) +
  geom_jitter(aes(alpha = F_EXP, col = cluster_interest),
              height = 0.1, width = 0.01) +
  # To bring to the front because the cluster has a small number of obs
  geom_jitter(data = filter(emicron_mpi, cluster == 5),
              aes(alpha = F_EXP), col = 'darkgreen',
              height = 0.1, width = 0.01) +
  
  geom_vline(xintercept = 0.33, linewidth = 1) +
  geom_hline(yintercept = 2, linewidth = 1) +
  
  scale_x_reverse() +
  scale_alpha_continuous(range = c(0.2, 0.5)) +
  scale_color_manual(values = c('lightgrey', 'darkgreen')) +
  
  # Add labels
  labs(x = "Multidimensional Poverty Index (inverted)",
       y = "Formality Index",
       title = "Microbusiness owners are spread across the space, except for the poor and formal quadrant...",
       subtitle = "Formality and Muldimensional Poverty, selected clusters") +
  custom_theme() +
  theme(legend.position = "none")


# EXPORT ------------------------------------------------------------------

# Save plots as PNG image with pdf page size and dimension

ggsave('Project/Plots/04_mpi-dpto-bar-chart.png',
       plot = p_mpi_dpto, 
       device = 'png', width = 15, height = 11, units = 'in', dpi = 300)


ggsave('Project/Plots/04_mpi-ii-dpto-scatter.png', 
       plot = p_scatter_mpi_ii, 
       device = 'png', width = 15, height = 11, units = 'in', dpi = 300)


ggsave('Project/Plots/04_panel-mpi-ii.png', 
       plot = panel_mpi_ii, 
       device = 'png', width = 15, height = 11, units = 'in', dpi = 300)


ggsave('Project/Plots/04_mpi-ii-rates-by-cluster.png', 
       plot = p_rates_clusters, 
       device = 'png', width = 15, height = 11, units = 'in', dpi = 300)


ggsave('Project/Plots/04_panel-mpi-ii-select-clusters.png', 
       plot = p_panel_clusters, 
       device = 'png', width = 15, height = 11, units = 'in', dpi = 300)


# -------------------------------------------------------------------------