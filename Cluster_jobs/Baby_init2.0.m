%% The script initializes the slurm environment and runs scripts on the server

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  Paths and setup

clear;

% Add paths
addpath('xxx') % Add path to costumn helper script
Baby_baby_paths % Costumn script that sets up all project-specific paths and folders
addpath('xxx') % Add path to folder where all these scripts are saved

%% --- Preprocessing ---

% Define the path to the .set files 
path_data_set_2W = 'xxx'; % Change accordingly
allfiles = dir(fullfile(path_data_set_2W, '*.set')); % Get all set  files in data directory % Change accordingly
SETs = {allfiles(:).name};
timepoint = '_2W_'; % Change accordingly % Keep the format '_6M_' '_12M_' _2W_' 

slurm_init; 
plus_slurm_struct = obob_slurm_addjob_cell(plus_slurm_struct,'c_Baby_Prepro_EEG_final', SETs, timepoint);
plus_slurm.submit(plus_slurm_struct)


%% --- ERP-TF-ITPC ---

% Define the path to the preprocessed EEG files
path_ICA_files = 'xxx'; % Change accordingly

prepro_files= dir(fullfile(path_ICA_files, '*.set')); % Get all set  files in data directory
pfiles = {prepro_files(:).name};

% choose time point
timepoint = '6M';  % or '12M' or '6M' or '2W' or '2WA' % Change accordingly
 
slurm_init; 
plus_slurm_struct = obob_slurm_addjob_cell(plus_slurm_struct,'c_Baby_ERP_final', pfiles, timepoint);
plus_slurm.submit(plus_slurm_struct)

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%