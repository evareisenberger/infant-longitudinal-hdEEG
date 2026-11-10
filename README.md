# Infant hdEEG Anaylses
All scripts in this repository were used for the analyses of infant hdEEG data conducted as part of a larger research project on prenatal learning, early development and attachment.
The overall project, which includes multiple variables and different measures, was funded by the Austrian Science Fund (FWF; P33630). 

All scripts were primarily developed by Dr. M. Ameen in collaboration with E. Reisenberger during work on the EEG Analysis of a data segment where pure Beep Tones (1000 Hz) were presented to infants two weeks (2W), six months (6M) and twelve months (12M) after birth. Our analysis included event-related potentials (ERPs) as well as oscillatory measures, namely time-frequency (TF) and inter-trial phase coherence (ITPC).

This README aims to help users understand how the repository is organized and the purpose of each script.
All scripts are commented for clarity.

## Overview
This repository contains two main folders:

- *Cluster_jobs*: Including the MATLAB scripts that were run on the SCC Pilot, a shared high-performance computing (HPC) cluster. For further information see: https://scc.plus.ac.at/
- *Local_jobs*: Containing scripts primarily used for statistical analysis and other procedures that can be run locally without the need for a server

Furthermore, you can find other files in this repository:

- An example R Script showing how ERPs were plotted for publication

## Cluster Jobs

This folder contains the scripts that were run on the SCC Pilot, a shared Slurm-managed computing cluster. 
For full details about the SCC Pilot, see the official documentation: https://scc.plus.ac.at/pages/scc-pilot-documentation.html

- *slurm_init.m* is the script used to set up the Slurm job environment. It handles job set-up and configuration and does not require modifications but should be used as is.
- *Baby_init_2.0* is the script that initializes and runs the preprocessing and analysis on the server. This is the one you need to actually run. It calls *slumr_init.m*. 
- *c_Baby_EEG_Prepro_final* is the main preprocessing pipeline. It is coded as a function, intended to be run on the server.
- *c_Baby_ERP_final* was coded as a function as well and also run on the server to compute ERP, ITPC and TF analyses. It performs data processing and generates output files used for subsequent statistical analyses, but does not itself run statistical tests.
  
Moreover, this folder contains two subfolders:

- *Helper*: Containing various helper scripts that are referenced across the other scripts and functions
  
### Helper Scripts

This folder contains all helper scripts as well as any additional helper packages that were required for our scripts to run.

- *DrosteEffect-BrewerMap-5b84f95*: Toolbox for generating color maps and visual enhancements in plots
- *kakearney-boundedline-pkg-50f7e4b*: Functions for plotting lines with shaded error bounds
- *Baby_baby_paths.m*: Sets up all necessary paths
- *Baby_EEG_exclude_chans.m*: Identifies and excludes channels, is referred to in the preprocessing script

The following helper scripts generally do not require modifcation unless custom settings need to be adjusted when reusing the scripts:

- *Baby_ERPsteps.m*: Performs all the computation steps needed to generate ERP data
- *Baby_TFsteps.m*: Perform all the computation steps needed to generate TF and ITPC data
- *epoch_properties.m*: Computes summary metrics for each EEG epoch, including mean deviation from channel means, epoch variance, and maximum amplitude difference
- *min_z.m*: Flags epochs or data segments as outliers based on z-scores of specified metrics
- *perform_epoch_rej.m*: Performs epoch rejection
- *plotTFR.m*: Generates plots of Temporal Response Functions for visualization
- *plotTFR_clusters.m*: Plots Temporal Response Functions grouped by clusters
  
## Local Jobs

This folder contains scripts that can be run locally on a comptar, without using a server or cluster.

- *00_Baby_ERP_Sanity.m*: Plots ERPs for a single subject, displaying all MTPs in a three-panel layout
- *01_Baby_ERP_2_6_12.m*: Performs statistical comparisons of ERP data for each MTP, contrasting stimulation and no-stimulation condition, and generates the final plots
- *02_Baby_TF_ITPC_2_6_12.m*: Performs statistical comparisons of ITPC and TF data for each MTP, contrasting stimulation and no-stimulation condition
- *03_Baby_ERP_Long.m*: Performs statistical analyses comparing two MTPs within matched participants for ERP data to assess longitudinal changes
- *04_Baby_TF_ITPC_Long.m*:  Performs statistical analyses comparing two MTPs within matched participants for ITPC and TF data to assess longitudinal changes, and generates the final plots
- *05_Baby_ERP_Stages.m*: Performs statistical analyses comparing stimulation and no-stimulation conditions for ERP data within each sleep stage
- *06_Baby_TF_ITPC_Stages.m*: Performs statistical analyses comparing stimulation and no-stimulation conditions for TF and ITPC data within each sleep stage, and generates the final plots

## Acknowledgement

The authors acknowledge the computational resources and services provided by Salzburg Collaborative Computing (SCC), funded by the Federal Ministry of Education, Science and Research (BMBWF) and the State of Salzburg.
