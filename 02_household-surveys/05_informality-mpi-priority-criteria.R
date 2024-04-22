
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

# EXPLORE -----------------------------------------------------------------

migrant_obs <- emicron_mpi %>% 
  filter(foreigner == 1) %>%
  group_by(dpto_label) %>%
  
  # group_by(urban) %>% 
  summarise(n = n()) %>% 
  arrange(desc(n)) %>% 
  head(20)


# PRIORITY CRITERION ------------------------------------------------------


emicron_priority <- emicron_mpi %>% 
  select(DPTO, dpto_label, mpi_index, mpi_poor, II, adj_weight) %>% 
  
  # Threshold to be considered as informal
  mutate(informal = as.numeric(II < 2)) %>% 
  
  # Drop observations without GEIH info
  filter(DPTO != "") %>% 
  group_by(dpto_label) %>%
  
  # Calculate rates and headcounts at geo level
  summarise(inf_rate = weighted.mean(informal, adj_weight, na.rm = TRUE),
            poor_rate = weighted.mean(mpi_poor, adj_weight, na.rm = TRUE),
            inf_hc = sum(informal * adj_weight, na.rm = TRUE),
            poor_hc = sum(mpi_poor * adj_weight, na.rm = TRUE)) %>% 
  ungroup() %>% 
  
  # Calculate avg rates and headcounts
  mutate(avg_inf_rate = mean(inf_rate, na.rm = TRUE),
         avg_poor_rate = mean(poor_rate, na.rm = TRUE),
         avg_inf_hc = mean(inf_hc, na.rm = TRUE),
         avg_poor_hc = mean(poor_hc, na.rm = TRUE)) %>% 
  
  # Priority criteria
  mutate(
    
    priority = case_when(
      
      # Above both headcounts
      inf_hc > avg_inf_hc & poor_hc > avg_poor_hc & 
        inf_rate > avg_inf_rate & poor_rate > avg_poor_rate ~ 1,
      inf_hc > avg_inf_hc & poor_hc > avg_poor_hc & 
        inf_rate > avg_inf_rate & !(poor_rate > avg_poor_rate) ~ 2,
      inf_hc > avg_inf_hc & poor_hc > avg_poor_hc & 
        !(inf_rate > avg_inf_rate) & poor_rate > avg_poor_rate ~ 3,
      inf_hc > avg_inf_hc & poor_hc > avg_poor_hc & 
        !(inf_rate > avg_inf_rate) & !(poor_rate > avg_poor_rate) ~ 4,
      
      # Above informality headcount, below poverty headcount
      inf_hc > avg_inf_hc & !(poor_hc > avg_poor_hc) & 
        inf_rate > avg_inf_rate & poor_rate > avg_poor_rate ~ 5,
      inf_hc > avg_inf_hc & !(poor_hc > avg_poor_hc) & 
        inf_rate > avg_inf_rate & !(poor_rate > avg_poor_rate) ~ 6,
      inf_hc > avg_inf_hc & !(poor_hc > avg_poor_hc) & 
        !(inf_rate > avg_inf_rate) & poor_rate > avg_poor_rate ~ 7,
      inf_hc > avg_inf_hc & !(poor_hc > avg_poor_hc) & 
        !(inf_rate > avg_inf_rate) & !(poor_rate > avg_poor_rate) ~ 8,
      
      # Above poverty headcount, below informality headcount
      !(inf_hc > avg_inf_hc) & poor_hc > avg_poor_hc & 
        inf_rate > avg_inf_rate & poor_rate > avg_poor_rate ~ 9,
      !(inf_hc > avg_inf_hc) & poor_hc > avg_poor_hc & 
        inf_rate > avg_inf_rate & !(poor_rate > avg_poor_rate) ~ 10,
      !(inf_hc > avg_inf_hc) & poor_hc > avg_poor_hc & 
        !(inf_rate > avg_inf_rate) & poor_rate > avg_poor_rate ~ 11,
      !(inf_hc > avg_inf_hc) & poor_hc > avg_poor_hc & 
        !(inf_rate > avg_inf_rate) & !(poor_rate > avg_poor_rate) ~ 12,
      
      # Below both headcounts
      !(inf_hc > avg_inf_hc) & !(poor_hc > avg_poor_hc) & 
        inf_rate > avg_inf_rate & poor_rate > avg_poor_rate ~ 13,
      !(inf_hc > avg_inf_hc) & !(poor_hc > avg_poor_hc) & 
        inf_rate > avg_inf_rate & !(poor_rate > avg_poor_rate) ~ 14,
      !(inf_hc > avg_inf_hc) & !(poor_hc > avg_poor_hc) & 
        !(inf_rate > avg_inf_rate) & poor_rate > avg_poor_rate ~ 15,
      !(inf_hc > avg_inf_hc) & !(poor_hc > avg_poor_hc) & 
        !(inf_rate > avg_inf_rate) & !(poor_rate > avg_poor_rate) ~ 16,
      
      TRUE ~ 99)) %>% 
  arrange(priority)



# MIGRANT OBSERVATIONS ----------------------------------------------------

migrant_obs %>% 
  ggplot(aes(x = reorder(dpto_label, -n), 
             y = n)) +
  
  geom_col(fill = 'midnightblue') +
  
  labs(title = "Migrant observations per department",
       x = "Department", y = "N") +
  custom_theme() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


# PRIORITY CRITERION ------------------------------------------------------


emicron_priority %>% 
  ggplot(aes(x = priority)) +
  geom_histogram(binwidth = 1, fill = 'midnightblue') +
  labs(title = "Prioritisation Criterion per Department",
       x = 'Priority', y = 'Count') +
  custom_theme()


# INFORMALITY VS MPI ------------------------------------------------------

emicron_mpi %>% 
  ggplot(aes(mpi_index, II)) +
  geom_point() + 
  geom_smooth() +
  theme_classic()

# -------------------------------------------------------------------------
