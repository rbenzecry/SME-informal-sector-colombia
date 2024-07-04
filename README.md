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


### Folders, scripts and Outputs structure

We should all share a folder structure to avoid issues when trying to reproduce or continue a code from someone else.

The folder where you copy the repository must follow the OneDrive structure and have the following folders:
* Data: all the raw data and inputs used/to use
  - Emicron-2022
  - GEIH-2022
* Outputs: intermediate outputs, processed databases, summary tables and so forth
  - 01_emicron
  - 02_household-surveys
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

We use the data of the national household surveys of Colombia to analyse the profile of migrants, informal sectors workers,
and multidimensional poverty index.

Historic data from: 

DANE. Gran Encuesta Integrada de Hogares - GEIH
(https://www.datos.gov.co/Estad-sticas-Nacionales/Gran-Encuesta-Integrada-de-Hogares-GEIH/mcpt-3dws/about_data)

GEIH 2023:

https://microdatos.dane.gov.co/index.php/catalog/782/get-microdata

GEIH 2022:

https://microdatos.dane.gov.co/index.php/catalog/771/get-microdata

**Scripts**

_*Note: scripts starting with `00` are not meant to run individually, they are used with the `source` function in another script. In this case, the `03_emicron-mpi-master-file.R` calls the `00` scripts for the construction of the multidimensional poverty index (MPI)._

* `01_rename-folders-geih.R`: renames the folders of GEIH when downloaded directly from DANE's website. It removes everything from the folder's name except the month.

* `02_join-modules-geih.R`: joins the monthly data sets to have a single annual data set per module. It keeps only the columns that are common in all months and transforms the column type to the less restrictive one across all months (character) when is needed. It creates the variable `adj_weight` to adjust the factor of expansion to the (now) annual data by simply dividing the original variable (`FEX_C18`) by 12, as instructed by DANE worker and UNDP. All annual modules are exported to `dta` files.

* `03_emicron-mpi-master-file.R`: 
  
  It sources the following scripts:
  
  `00_house-and-services-mpi-2022.R` -> for the dwelling/housing conditions and services dimension

  `00_labour-mpi-2022.R` -> for the labour dimension

  `00_education-health-mpi-2022.R` -> for the education and health dimensions
 
  `00_migration-emicron-2022.R` -> to add basic migrant variables
  
  _TO BE CONTINUED._

