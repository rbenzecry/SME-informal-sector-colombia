# SME-informal-sector-colombia
PP422 WT Term - Group Final Project 

LSE MPA in Data Science for Public Policy Y1

Identifying and understanding SMEs in the informal sector in Colombia, in collaboration with UNDP Colombia.

Authors:
* Ricardo Benzecry
* Grant Benton
* Carolina Rodrigues
* Angelo Leone
* Betzabe Soria Rodriguez
* Shuxin Deng


### Folders, scripts and tables structure

We should all share a folder structure to avoid issues when trying to reproduce or continue a code from someone else.

The folder where you copy the repository should have the following folders:
* Data: all the raw data and inputs used/to use
* Tables: intermediate outputs, processed databases, summary tables and so forth
* Plots: all the plots exported
  
_*Note: this is a proposed structure. Obviously is open to change, I just want to make sure we have a clearly defined common structure to work._

Enumerate the codes and folders in a consistent way. All sub-folders, scripts and output databases and tables should have a two-digit code indicating the order and identifying the script that generate it. The enumeration must take into account "chronological" order, meaning if script X should be run _before_ script Y, names should be 01_X and 02_Y. 

Example: 

  Scripts: "01_initial-settings.py", "02_clean-survey-data.py", "03_migrant-profile.py".

  Output dataset: "03_summary-migrant-profile-region.xlsx"
  
  
### 01 - Microbusinesses survey
Folder: 01_emicron

In the data folder, have another folder called: 01_to_import. Plus, have the file emicron_clean.csv which can be downloaded by running the file 01_cleaning-data-undp.ipynb.

### 02 - Household surveys

Folder: 02_household-surveys

We use the data of the national household surveys of Colombia to analyse the profile of migrants and informal sectors workers.

Historic data from: 

DANE. Gran Encuesta Integrada de Hogares - GEIH
(https://www.datos.gov.co/Estad-sticas-Nacionales/Gran-Encuesta-Integrada-de-Hogares-GEIH/mcpt-3dws/about_data)


GEIH 2023:

https://microdatos.dane.gov.co/index.php/catalog/782/get-microdata

GEIH 2022:






