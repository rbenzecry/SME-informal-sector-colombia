
source('00_settings.R')

# DATA --------------------------------------------------------------------

emicron_mpi <- read_dta("Tables/emicron-informality-mpi.dta")

emicron_clean <- read.csv("Tables/01_emicron/emicron_clean.csv")

emicron_index <- read.csv("Tables/01_emicron/emicron_index.csv")

emicron_raw <- read_dta("Data/Emicron-2022/Módulo de características del micronegocio.dta")


# CHECKS ------------------------------------------------------------------

length(unique(emicron_mpi$id_per))


# Is this the same number as the unique IDs in emicron raw?
emicron_raw <- emicron_raw %>% 
  mutate(id_per = paste(DIRECTORIO, SECUENCIA_P, SECUENCIA_ENCUESTA, sep = ""))

length(unique(emicron_mpi$id_per)) == length(unique(emicron_raw$id_per)) 


# Number of duplicates to drop
nrow(emicron_mpi) - length(unique(emicron_mpi$id_per))


# ZOOM IN DUPLICATES ------------------------------------------------------

emicron_mpi2 <- emicron_mpi %>%
  group_by(id_per) %>% 
  mutate(n_dup = n()) %>% 
  ungroup() %>% 
  mutate(dup = as.numeric(n_dup > 1))

duplicates <- emicron_mpi2 %>% 
  filter(n_dup > 1)


# How many of them have data on GEIH? (look at the FALSE)
table(is.na(duplicates$adj_weight))

# How many duplicates of each id?
summary(duplicates$n_dup)

table(emicron_mpi2$dup)

# Poverty rate iIDsf it has duplicated rows
emicron_mpi2 %>% 
  group_by(dup) %>% 
  summarise(mpi_rate = weighted.mean(mpi_poor, F_EXP, na.rm = T)) %>% 
  ungroup() %>% 
  
  ggplot(aes(dup, mpi_rate)) +
  geom_col() +
  custom_theme()

# CHECK WEIGHTS -----------------------------------------------------------

emicron_w <- emicron_mpi %>% 
  select(id_per, adj_weight, FEX_C18, F_EXP) %>% 
  inner_join(select(emicron_raw,
                    id_per, F_EXP), by = "id_per") %>% 
  mutate(diff_w_raw = round(FEX_C18/12 - F_EXP.y, 4),
         diff_w = round(F_EXP.x - F_EXP.y, 4))


summary(emicron_w$diff_w_raw)
summary(emicron_w$diff_w)

table(emicron_w$diff_w_raw)
table(emicron_w$diff_w)

# F_EXP variable
emicron_w %>% 
  ggplot(aes(F_EXP.x, F_EXP.y)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  labs(title = "F_EXP variable",
       x = 'F_EXP emicron_mpi',
       y = 'F_EXP emicron_raw')


# Raw GEIH weights divided by 12
emicron_w %>% 
  ggplot(aes(FEX_C18/12, F_EXP.y)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  labs(title = "Raw GEIH weights divided by 12",
       x = 'FEX_C18/12 (raw weights emicron_mpi) ',
       y = 'F_EXP emicron_raw')

# Adjusted GEIH weights
emicron_w %>% 
  ggplot(aes(adj_weight, F_EXP.y)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  labs(title = "Adjusted GEIH weights (which is original divided by 12)",
       x = 'Adjusted weights emicron_mpi',
       y = 'F_EXP emicron_raw')

# Confirming that the adjusted is just the original GEIH weights divided by 12
table(round(emicron_w$adj_weight - emicron_mpi$FEX_C18/12, 2))

emicron_w %>% 
  ggplot(aes(adj_weight, FEX_C18/12)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  labs(title = "Adjusted GEIH weights vs original divided by 12)",
       x = 'Adjusted weights',
       y = 'FEX_C18/12')


# -------------------------------------------------------------------------
