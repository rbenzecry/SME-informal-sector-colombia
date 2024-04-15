

# DATA --------------------------------------------------------------------

emicron_mpi <- read_dta("Tables/emicron-informality-mpi.dta")

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
       subtitle = "Economic dependency ratio = number of people per occupied member in the household") +
  custom_theme()



# INFORMALITY VS INFORMAL WORK --------------------------------------------


emicron_mpi %>%
  
  ggplot(aes(-mpi_inf_work, II)) +
  geom_jitter(aes(alpha = adj_weight),
              height = 0.1,
              width = 0.4)  +
  custom_theme()

# -------------------------------------------------------------------------