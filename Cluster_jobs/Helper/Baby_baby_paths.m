%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  Repository for paths of the baby project data

% Fieldtrip
addpath('xxx'); % Change accordingly
cfg=[]; cfg.package.plus_slurm = true;
obob_init_ft(cfg);

% EEGLab
addpath(genpath('xxx')); % Change accordingly
%eeglab; close gcf;

% PREP pipeline
addpath('xxx') % Change accordingly

% Load channels to remove
addpath('xxx') % Change accordingly
Baby_EEG_exclude_chans_EVA

% Paths to raw .mff data
path_data_mff = 'xxx'; % Change accordingly
path_data_mff_6M = 'xxx'; % Change accordingly
path_data_mff_12M = 'xxx'; % Change accordingly

% Paths to raw .set files
path_data_set_6M = 'xxx'; % Change accordingly
path_data_set_12M = 'xxx'; % Change accordingly
path_data_set_2W = 'xxx'; % Change accordingly

% Path sleep staging marker files
path_sleepstaging = 'xxx'; % Change accordingly

% Path to partly preprocessed files
path_processed = 'xxx'; % Change accordingly
path_processed_6M = 'xxx'; % Change accordingly
path_processed_12M = 'xxx'; % Change accordingly

% Path to fully preprocessed files
ica_folder_2W = 'xxx'; % Change accordingly
ica_folder_6M = 'xxx'; % Change accordingly
ica_folder_12M = 'xxx'; % Change accordingly

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%