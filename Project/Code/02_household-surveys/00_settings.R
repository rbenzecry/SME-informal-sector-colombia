
library(tidyverse)
library(readxl)
library(haven)
library(stringi)
library(janitor)
library(data.table)
library(openxlsx)
library(ggrounded)
library(gridExtra)
library(data.table)
library(sjlabelled)
library(sjPlot)

rm(list = ls())

# FUNCTIONS ---------------------------------------------------------------

custom_theme <- function() {
  
  theme_classic() +
    theme(
      panel.background = element_rect(fill = "white", color = "white"),
      # Remove vertical grid lines
      panel.grid.major.x = element_blank(),  
      panel.grid.major.y = element_line(color = "gray", linetype = "dashed"),
      
      axis.line.y = element_line(color = "white"),
      axis.line.x = element_line(color = "darkgray"),
      
      # Set color of axis ticks
      axis.ticks = element_line(color = "darkgray"),  
      # Adjust the margins
      plot.margin = margin(20, 20, 20, 20),  
      
      # Font sizes
      # Title
      plot.title = element_text(size = 18),
      
      # Axis label
      axis.title.x = element_text(size = 16),
      axis.title.y = element_text(size = 16),
      
      # Axis tick labels
      axis.text.x = element_text(size = 14),
      axis.text.y = element_text(size = 14),
      
      # Legend title and labels
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 13)
      
      
    )
}

