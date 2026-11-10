
%% This function runs on the server and is preprocessing hdEEG data

function c_Baby_Preprocessing_EEG(EEGfile, timepoint)  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  Paths and setup

addpath('xxx') % Add path to costumn helper script
Baby_baby_paths % Costumn script that sets up all project-specific paths and folders

%% --- Load .set files ---

if strcmp(timepoint, '_12M_')
    EEG = pop_loadset(strcat(path_data_set_12M, EEGfile));
elseif strcmp(timepoint, '_6M_')
    EEG = pop_loadset(strcat(path_data_set_6M, EEGfile));
else
    EEG = pop_loadset(strcat(path_data_set_2W, EEGfile));
end

% Extract subject ID
subj_id = EEGfile(1:5);

%% --- Preprocessing steps ---

% Remove physio channels
EEG = pop_select(EEG, 'nochannel', chans_exc_physio);

% Apply bandpass filter from 0.1 to 45 Hz
EEG = pop_eegfiltnew(EEG, 0.1, 45);

%PREPpipeline
% Using PREPpipeline to restore reference and remove bad channels as well perform robust average reference and remember 

    % Parameters for avergae refref
    params.referenceChannels    = 1:EEG.nbchan-1; % Scalp channels to use for initial average reference
    params.evaluationChannels   = 1:EEG.nbchan-1; % Scalp channels that will contribute to the robust reference
    params.rereferencedChannels = 1:EEG.nbchan; % Scalp+external channels that will be referenced to the robust reference
    
    % Bad channel detection parameters
    params.badTimeThreshold            = 0.1;
    params.highFrequencyNoiseThreshold = 8;
    params.robustDeviationThreshold    = 13;
    params.ransacOff                   = true; % Turned off as usually too aggressive
    [EEG, referenceOut]                = performReference(EEG, params);
    
 %% --- Save preprocessed data before ICA in subfolder with suffix 

 if strcmp(timepoint, '_12M_')
 path_processed = 'xxx'; % Change accordingly
 elseif strcmp(timepoint, '_6M_')
 path_processed = 'xxx'; % Change accordingly
 else
 path_processed = 'xxx'; % Change accordingly
 end

 save_filename = strcat(subj_id, timepoint, 'beforeICA');
 save_filepath = fullfile(path_processed, save_filename);

 % Save as .set file
 % pop_saveset(EEG, 'filename', save_filepath);

%% --- ICA ---

EEG=pop_runica(EEG,'icatype','runica', 'extended', 1, 'interrupt', 'off'); 

%% --- Save preprocessed data after ICA decomposition and before rejection in subfolder with suffix

if strcmp(timepoint, '_12M_')
 path_after = 'xxx'; % Change accordingly
 elseif strcmp(timepoint, '_6M_')
 path_after = 'xxx'; % Change accordingly
 else
 path_after = 'xxx'; % Change accordingly
end

save_filename = strcat(subj_id, timepoint, 'beforeRejComp');
save_filepath = fullfile(path_after, save_filename);

% Save as .set file
% pop_saveset(EEG, 'filename', save_filepath);

%% --- ICA rejection

% Label the components using ICLabel
EEG = iclabel(EEG);
    
% Set thresholds for artifact rejection based on ICLabel classifications
thresholds = [0 0;  % Brain
                  0.8 1;  % Muscle
                  0.8 1;  % Eye
                  0.8 1;  % Heart
                  0.8 1;  % Line Noise
                  0.8 1;  % Channel Noise
                  0 0]; % Other
    
% Automatically flag components using ICLabel's default thresholds
EEG = pop_icflag(EEG, thresholds);  
rej_components = find(EEG.reject.gcompreject);

% Remove selected components
    EEG = pop_subcomp(EEG, rej_components, 0);
    EEG = eeg_checkset(EEG);
    
% Save rejected component for each participant
 if strcmp(timepoint, '_12M_')
 path_rejComp = 'xxx'; % Change accordingly
 elseif strcmp(timepoint, '_6M_')
 path_rejComp = 'xxx'; % Change accordingly
 else
 path_rejComp = 'xxx'; % Change accordingly
 end

if ~exist(path_rejComp, 'dir')
    mkdir(path_rejComp);
end

rej_comp_filename = fullfile(path_rejComp, [subj_id timepoint 'rejectedComps.mat']);
save(rej_comp_filename, 'rej_components');

 %% --- Save fully preprocessed data in subfolder with Suffix

 if strcmp(timepoint, '_12M_')
 path_final = 'xxx'; % Change accordingly
 elseif strcmp(timepoint, '_6M_')
 path_final = 'xxx'; % Change accordingly
 else
 path_final = 'xxx'; % Change accordingly
 end 

 save_filename = strcat(subj_id, timepoint, 'ICAdone');
 save_filepath = fullfile(path_final, save_filename);

 % Save as .set file
 pop_saveset(EEG, 'filename', save_filepath);

end

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%