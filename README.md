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

**_THE INFORMATION BELOW IS NOT UPDATED_** 

### Folder structure

The folder where you copy the repository must follow the OneDrive structure and have the following folders:
* Data: all the raw data and inputs used/to use
  - Emicron-2022
  - GEIH-2022
* Code: all the code files divided into sections
* Plots: all the plots exported
  
Enumerate the codes and folders in a consistent way. All sub-folders, scripts and output databases and tables should have a two-digit code indicating the order and identifying the script that generate it. The enumeration must take into account "chronological" order, meaning if script X should be run _before_ script Y, names should be 01_X and 02_Y. 

### Instructions for replication

Explain how to get the results:
1. import necessary data into right folder
2. run scripts in order
  2.1 no need to run the 00_ scripts
  2.2 for info on what each script does and input/output, visit [...]
3. intermediate data files and plots will be stored into respective folders 

#### Data
Please move the following files to the 'Data' folder inside 'Project':
From Emicron:
- "Módulo de identificación.csv",
- "Módulo de capital social.csv",
- "Módulo de características del micronegocio.csv",
- "Módulo de costos, gastos y activos.csv",
- "Módulo de emprendimiento.csv",
- "Módulo de inclusión financiera.csv",
- "Módulo de sitio o ubicación.csv",
- "Módulo de TIC.csv",
- "Módulo de ventas o ingresos.csv",
- "Módulo personal ocupado (propietario(a)).csv"
From GEIH:
- DICCIONARIO_DATOS_BASES_ANONIMIZADAS_GEIH_2023.xlsx
- Unzipped version of the folder GEIH_2022_Marco_2018.zip

#### 01 - Microbusinesses survey
Folder: 01_emicron

Explain what this section is about and include notebook descriptions.

Include link to source of Emicron data.

#### 02 - Household surveys

Folder: 02_household-surveys

We use the data of the national household surveys of Colombia to analyse the profile of migrants, informal sectors workers,
and multidimensional poverty index.

Historic data from: 

DANE. Gran Encuesta Integrada de Hogares - GEIH
(https://www.datos.gov.co/Estad-sticas-Nacionales/Gran-Encuesta-Integrada-de-Hogares-GEIH/mcpt-3dws/about_data)

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

#### 03 - Clustering

Explain goal of this section and content of the notebooks here.