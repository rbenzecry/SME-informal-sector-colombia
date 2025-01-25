# Informality and Multidimensional Poverty in Colombia: 
## A Framework to Analyse Micro and Small Businesses

PP422 WT Term - Group Final Project 

LSE MPA in Data Science for Public Policy Y1

Identifying and understanding SMEs in the informal sector in Colombia, in collaboration with UNDP Colombia.

Authors:
* Ricardo Benzecry
* Grant Benton
* Carolina Rodrigues
* Angelo Leone

### Folder structure

The folder where you copy the repository must follow the structure below:
* `Project/`:
*   `Data`: Contains all raw datasets and inputs required for analysis.
*   `Code`: Stores code files, structured by process stages.
*   `Plots`: Includes exported visualizations from the analysis.

#### Data
Please move the following files to the `Data` folder inside `Project`:

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

DANE. Gran Encuesta Integrada de Hogares - GEIH: https://www.datos.gov.co/Estad-sticas-Nacionales/Gran-Encuesta-Integrada-de-Hogares-GEIH/mcpt-3dws/about_data

GEIH 2022: https://microdatos.dane.gov.co/index.php/catalog/771/get-microdata

#### Code Files

All code files are listed and described in the `Notebook Dictionary.xlsx` file. Subfolders and code are organized chronologically to ensure proper execution order:

_Note: scripts starting with `00` are not meant to run individually, they are used with the `source` function in another script. For example, the `03_emicron-mpi-master-file.R` calls the `00` scripts for the construction of the multidimensional poverty index (MPI)._

##### 01 - Microbusinesses survey
Folder: `01_emicron`

We merge Emicron modules into a single dataset, analyse the data from Emicron and create a formality index.

##### 02 - Household surveys
Folder: `02_household-surveys`

We use the data of the national household surveys of Colombia to analyse the profile of migrants, informal sectors workers,
and multidimensional poverty index.

##### 03 - Clustering
Folder: `03_clustering`

We group microbusinesses using clustering techniques and interpret the results.

##### 04 - Analysis
Folder: `04_analysis_natives`

We focus on specific analysis related to native Colombian population and migrants

