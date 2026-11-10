%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  Paths and setup

clear;

% Add paths
addpath(genpath('/xxx/Helper'))  % Add path to costumn helper script
Baby_baby_paths; % Costumn script that sets up all project-specific paths and folders

addpath('/xxx/Helper/DrosteEffect-BrewerMap-5b84f95'); % Add path to helper package needed for visualization

%% --- Paths to data ---

path_ERP0 = 'xxx';
path_ERP1 = 'xxx';
path_ERP2 = 'xxx';
path_ERP3 = 'xxx';

%%  ERP ANALYSIS
%  =======================

%% --- Load filenames and exclude participants (stimulation condition) ---

% Wake
ERPbeep_FC0 = dir(fullfile(path_ERP0, '*FC*beep*.mat'));
ERPbeep_FC0n = {ERPbeep_FC0(:).name};
ERPbeep_FC0n([2,3,4,10,12,15,16,17,18,21,25,30])= []; % Exclude participants (indices)

% REM
ERPbeep_FC1 = dir(fullfile(path_ERP1, '*FC*beep*.mat'));
ERPbeep_FC1n = {ERPbeep_FC1(:).name};
ERPbeep_FC1n([4,5])= []; % Exclude participants (indices)

% Transitional
ERPbeep_FC2 = dir(fullfile(path_ERP2, '*FC*beep*.mat'));
ERPbeep_FC2n = {ERPbeep_FC2(:).name};

%NREM
ERPbeep_FC3 = dir(fullfile(path_ERP3, '*FC*beep*.mat'));
ERPbeep_FC3n = {ERPbeep_FC3(:).name};
ERPbeep_FC3n([1,2,3,5])= []; % Exclude participants (indices)

%% --- Load files (stimulation condition) ---

for i = 1:length(ERPbeep_FC0n)
    load([path_ERP0 ERPbeep_FC0n{i}]); % Load each participant's file for the stimulation condition
    ERPstim_FC0{i} = Beep_ERP_fc; % Store in cell array
end

for i = 1:length(ERPbeep_FC1n)
    load([path_ERP1 ERPbeep_FC1n{i}]);
    ERPstim_FC1{i} = Beep_ERP_fc;
end

for i = 1:length(ERPbeep_FC2n)
    load([path_ERP2 ERPbeep_FC2n{i}]);
    ERPstim_FC2{i} = Beep_ERP_fc;
end

for i = 1:length(ERPbeep_FC3n)
    load([path_ERP3 ERPbeep_FC3n{i}]);
    ERPstim_FC3{i} = Beep_ERP_fc;
end

%% --- Load filenames and exclude participants (no-stimulation condition) ---

% Wake
ERPbase_FC0 = dir(fullfile(path_ERP0, '*FC*base*.mat'));
ERPbase_FC0n = {ERPbase_FC0(:).name};
ERPbase_FC0n([2,3,4,10,12,15,16,17,18,21,25,30])= [];  % Exclude participants (indices)

% REM
ERPbase_FC1 = dir(fullfile(path_ERP1, '*FC*base*.mat'));
ERPbase_FC1n = {ERPbase_FC1(:).name};
ERPbase_FC1n([4,5])= [];  % Exclude participants (indices)

% Transitional
ERPbase_FC2 = dir(fullfile(path_ERP2, '*FC*base*.mat'));
ERPbase_FC2n = {ERPbase_FC2(:).name};

% NREM
ERPbase_FC3 = dir(fullfile(path_ERP3, '*FC*base*.mat'));
ERPbase_FC3n = {ERPbase_FC3(:).name};
ERPbase_FC3n([1,2,3,5])= [];  % Exclude participants (indices)

%% --- Load files (no-stimulation condition) ---

cfg=[];

for i = 1:length(ERPbase_FC0n)
    load([path_ERP0 ERPbase_FC0n{i}]); % Load each participant's file for the no-stimulation condition
    ERPbl_FC0{i} = Base_ERP_fc; % Store in cell array
end

for i = 1:length(ERPbase_FC1n)
    load([path_ERP1 ERPbase_FC1n{i}]);
    ERPbl_FC1{i} = Base_ERP_fc;
end

for i = 1:length(ERPbase_FC2n)
    load([path_ERP2 ERPbase_FC2n{i}]);
    ERPbl_FC2{i} = Base_ERP_fc;
end

for i = 1:length(ERPbase_FC3n)
    load([path_ERP3 ERPbase_FC3n{i}]);
    ERPbl_FC3{i} = Base_ERP_fc;
end

%% --- Single subject plots ---

figure;
for p = 1:size(ERPbl_FC3,2)
    subplot(1,1,p);
    plot(ERPbl_FC3{1}.time, squeeze(mean(ERPstim_FC3{p}.avg)) , 'r')
    hold on; plot(ERPbl_FC3{1}.time, squeeze(mean(ERPbl_FC3{p}.avg)) , 'b')
end

% % Save for R
% savepath = 'xxx';  % Define path where to save the data
% 
% ERP_2W_NREM = squeeze(mean(ERPstim_FC3{p}.avg));
% BL_2W_NREM = squeeze(mean(ERPbl_FC3{p}.avg));
% 
% save([savepath 'ERP_SleepStages_2W_NREM.mat'],'ERP_2W_NREM')
% save([savepath 'BL_SleepStages_2W_NREM.mat'],'BL_2W_NREM')

%% --- Grand averages across participants ---

cfg_g=[];
cfg_g.keepindividual = 'yes';

% Compute grand averages for all participants at each stage
% Stimulation condition
BEEP_all_FC0 = ft_timelockgrandaverage(cfg_g, ERPstim_FC0{:});
BEEP_all_FC1 = ft_timelockgrandaverage(cfg_g, ERPstim_FC1{:});
BEEP_all_FC2 = ft_timelockgrandaverage(cfg_g, ERPstim_FC2{:});
BEEP_all_FC3 = ft_timelockgrandaverage(cfg_g, ERPstim_FC3{:});
% No-stimulation condition
BASE_all_FC0 = ft_timelockgrandaverage(cfg_g, ERPbl_FC0{:});
BASE_all_FC1 = ft_timelockgrandaverage(cfg_g, ERPbl_FC1{:});
BASE_all_FC2 = ft_timelockgrandaverage(cfg_g, ERPbl_FC2{:});
BASE_all_FC3 = ft_timelockgrandaverage(cfg_g, ERPbl_FC3{:});

%% --- Saving group level .mat files to plot ERPs in R ---

savepath = 'xxx';  % Define path where to save the data

% Averaging the indiviudal ERP data (stimulation condition) across the second dimension and reshape output by removing singleton dimensions using squeeze
ERP_2W_Wake = squeeze(mean(BEEP_all_FC0.individual,2));
ERP_2W_REM = squeeze(mean(BEEP_all_FC1.individual,2));
ERP_2W_Transitional = squeeze(mean(BEEP_all_FC2.individual,2));
%ERP_2W_NREM = squeeze(mean(BEEP_all_FC3.individual,2));

% Averaging the indiviudal ERP data (no-stimulation condition) across the second dimension and reshape output by removing singleton dimensions using squeeze
BL_2W_Wake = squeeze(mean(BASE_all_FC0.individual,2));
BL_2W_REM = squeeze(mean(BASE_all_FC1.individual,2));
BL_2W_Transitional = squeeze(mean(BASE_all_FC2.individual,2));
%BL_2W_NREM = squeeze(mean(BASE_all_FC3.individual,2));

ERP_SleepStages_time = BASE_all_FC1.time; % Extract time vector

% Save .mat files
save([savepath 'ERP_SleepStages_2W_Wake.mat'],'ERP_2W_Wake')
save([savepath 'ERP_SleepStages_2W_REM.mat']   ,'ERP_2W_REM')
save([savepath 'ERP_SleepStages_2W_Transitional.mat']  ,'ERP_2W_Transitional')
%save([savepath 'ERP_SleepStages_2W_NREM.mat']  ,'ERP_2W_NREM')

save([savepath 'BL_SleepStages_2W_Wake.mat'],'BL_2W_Wake')
save([savepath 'BL_SleepStages_2W_REM.mat'],'BL_2W_REM')
save([savepath 'BL_SleepStages_2W_Transitional.mat'],'BL_2W_Transitional')
%save([savepath 'BL_SleepStages_2W_NREM.mat'],'BL_2W_NREM')

save([savepath 'ERP_SleepStages_time.mat'],'ERP_SleepStages_time')

%% %% --- For Plotting (within stage: stimulation vs no-stimulation) ---

colors_comp = [1 0 0 ; 0 0 1]; 

% Wake
% Stimulation condition
ERPm_Wake = mean(squeeze(mean(BEEP_all_FC0.individual,2)),1);
ERPs_Wake = std(squeeze(mean(BEEP_all_FC0.individual,2))) ./ sqrt(size(BEEP_all_FC0.individual, 1));
% No-stimualtion condition
BLm_Wake = mean(squeeze(mean(BASE_all_FC0.individual,2)),1);
BLs_Wake = std(squeeze(mean(BASE_all_FC0.individual,2))) ./ sqrt(size(BASE_all_FC0.individual, 1));

% REM
% Stimulation condiiton
ERPm_REM = mean(squeeze(mean(BEEP_all_FC1.individual,2)),1);
ERPs_REM = std(squeeze(mean(BEEP_all_FC1.individual,2)),0,1) ./ sqrt(size(BEEP_all_FC1.individual, 1));
% No-stimulation condition
BLm_REM = mean(squeeze(mean(BASE_all_FC1.individual,2)),1);
BLs_REM = std(squeeze(mean(BASE_all_FC1.individual,2)),0,1) ./ sqrt(size(BASE_all_FC1.individual, 1));

% Transitional
% Stimulation conditions
ERPm_Trans = mean(squeeze(mean(BEEP_all_FC2.individual,2)),1);
ERPs_Trans = std(squeeze(mean(BEEP_all_FC2.individual,2)),0,1) ./ sqrt(size(BEEP_all_FC2.individual, 1));
% No-stimuation condition
BLm_Trans = mean(squeeze(mean(BASE_all_FC2.individual,2)),1);
BLs_Trans = std(squeeze(mean(BASE_all_FC2.individual,2)),0,1) ./ sqrt(size(BASE_all_FC2.individual, 1));

% NREM
% Stimulation condition
ERPm_NREM = mean(squeeze(mean(BEEP_all_FC3.individual,2)),1);
ERPs_NREM = std(squeeze(mean(BEEP_all_FC3.individual,2)),0,1) ./ sqrt(size(BEEP_all_FC3.individual, 1));
% No stimulation condition
BLm_NREM = mean(squeeze(mean(BASE_all_FC3.individual,2)),1);
BLs_NREM = std(squeeze(mean(BASE_all_FC3.individual,2)),0,1) ./ sqrt(size(BASE_all_FC3.individual, 1));

%% --- Plot

X = BEEP_all_FC0.time(:); % Shared time vector

figure; subplot(1,4,1);boundedline(X, ERPm_Wake, ERPs_Wake, X, BLm_Wake, BLs_Wake, 'cmap', colors_comp, 'transparency', 0.2);
title('Wake');
xlabel('Time (s)');
ylabel('Amplitude (\muV)');
grid on;
xlim([-0.2 1.5]); ylim([-8 4]);

subplot(1,4,2); boundedline(X, ERPm_REM, ERPs_REM, X, BLm_REM, BLs_REM, 'cmap', colors_comp, 'transparency', 0.2);
title('REM'); 
xlim([-0.2 1.5]); ylim([-8 4]);

subplot(1,4,3); boundedline(X, ERPm_Trans, ERPs_Trans, X, BLm_Trans, BLs_Trans, 'cmap', colors_comp, 'transparency', 0.2);
title('Trans'); 
xlim([-0.2 1.5]);ylim([-8 4]);

subplot(1,4,4); boundedline(X, ERPm_NREM, ERPs_NREM, X, BLm_NREM, BLs_NREM, 'cmap', colors_comp, 'transparency', 0.2);
title('NREM');
xlim([-0.2 1.5]);ylim([-8 4]);

%% --- ERP Stats ---

cfg = [];
cfg.statistic       = 'ft_statfun_depsamplesT'; % between groups independent samples statistics
cfg.method          = 'montecarlo'; % Monte Carlo method for calculating the significance probability (p-value)
cfg.correctm        = 'cluster';
cfg.clusteralpha    = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.avgoverchan     = 'yes';
cfg.tail            = 0;
cfg.clustertail     = 0;
cfg.alpha           = 0.025;
cfg.numrandomization = 5000;
cfg.uvar            = 1;  % Define within-subject variance
cfg.ivar            = 2;  % Define between-group variance

% --- WAKE
nSubj1 = size(BEEP_all_FC0.individual,1);
design = zeros(2,2*nSubj1);

for m = 1:nSubj1
 design(1,m) = m;
end
for m = 1:nSubj1
design(1,nSubj1+m) = m;
end
design(2,1:nSubj1) = 1;
design(2,nSubj1+1:2*nSubj1) = 2;
cfg.design = design;

% Run the stats
stat_W = ft_timelockstatistics(cfg,BEEP_all_FC0, BASE_all_FC0);

% Plot t-values
%figure;plotTFR_clusters(stat_W,stat_W.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], 'Wake T-values', 'ClusterStats', stat_W, 'ClusterType', 'both' )

% --- REM
nSubj1 = size(BEEP_all_FC1.individual,1);
design = zeros(2,2*nSubj1);

for m = 1:nSubj1
 design(1,m) = m;
end
for m = 1:nSubj1
design(1,nSubj1+m) = m;
end
design(2,1:nSubj1) = 1;
design(2,nSubj1+1:2*nSubj1) = 2;
cfg.design = design;

% Run the stats
stat_R = ft_timelockstatistics(cfg,BEEP_all_FC1, BASE_all_FC1);

% Plot t-values
%figure;plotTFR_clusters(stat_R,stat_R.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], 'NREM T-values', 'ClusterStats', stat_R, 'ClusterType', 'both' )

% --- NREM
nSubj1 = size(BEEP_all_FC3.individual,1);
design = zeros(2,2*nSubj1);

for m = 1:nSubj1
 design(1,m) = m;
end
for m = 1:nSubj1
design(1,nSubj1+m) = m;
end
design(2,1:nSubj1) = 1;
design(2,nSubj1+1:2*nSubj1) = 2;
cfg.design = design;

% Run the stats
stat_N = ft_timelockstatistics(cfg,BEEP_all_FC3, BASE_all_FC3);

% Plot t-values
%figure;plotTFR_clusters(stat_N,stat_N.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], 'NREM T-values', 'ClusterStats', stat_N, 'ClusterType', 'both' )

% --- Transitional
nSubj1 = size(BEEP_all_FC2.individual,1);
design = zeros(2,2*nSubj1);

for m = 1:nSubj1
 design(1,m) = m;
end
for m = 1:nSubj1
design(1,nSubj1+m) = m;
end
design(2,1:nSubj1) = 1;
design(2,nSubj1+1:2*nSubj1) = 2;
cfg.design = design;

% Run the stats
stat_T = ft_timelockstatistics(cfg,BEEP_all_FC2, BASE_all_FC2);

% Plot t-values
%figure;plotTFR_clusters(stat_T,stat_T.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], 'Transitional T-values', 'ClusterStats', stat_N, 'ClusterType', 'both' )

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%