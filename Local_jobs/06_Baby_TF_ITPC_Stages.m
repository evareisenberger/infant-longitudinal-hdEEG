%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  Paths and setup

clear;

% Add paths
addpath(genpath('/xxx/Helper')) % Add path to costumn helper script
Baby_baby_paths; % Costumn script that sets up all project-specific paths and folders

addpath('/xxx/Helper/DrosteEffect-BrewerMap-5b84f95'); % Add path to helper package needed for visualization

%% --- Paths to data ---

path_TF0 = 'xxx';
path_TF1 = 'xxx';
path_TF2 = 'xxx';
path_TF3 = 'xxx';

path_ITPC0 = 'xxx';
path_ITPC1 = 'xxx';
path_ITPC2 = 'xxx';
path_ITPC3 = 'xxx';

%%  TF ANALYSIS
%  =======================

%% --- Load filenames and exclude participants (stimulation condition) ---

% Wake
TFbeep_FC0 = dir(fullfile(path_TF0, '*FC*beep*.mat'));
TFbeep_FC0n = {TFbeep_FC0(:).name};
TFbeep_FC0n([2,3,4,10,12,15,16,17,18,21,25,30])= []; % Exclude participants (indices)

% REM
TFbeep_FC1 = dir(fullfile(path_TF1, '*FC*beep*.mat'));
TFbeep_FC1n = {TFbeep_FC1(:).name};
TFbeep_FC1n([4,5,9])= []; % Exclude participants (indices)

% Transitional
TFbeep_FC2 = dir(fullfile(path_TF2, '*FC*beep*.mat'));
TFbeep_FC2n = {TFbeep_FC2(:).name};

% NREM
TFbeep_FC3 = dir(fullfile(path_TF3, '*FC*beep*.mat'));
TFbeep_FC3n = {TFbeep_FC3(:).name};
TFbeep_FC3n([1,2,3,5])= []; % Exclude participants (indices)

%% --- Load files (stimulation condition) ---

for i = 1:length(TFbeep_FC0n)
    load([path_TF0 TFbeep_FC0n{i}]);  % Load each participant's file for the stimulation condition
    TFstim_FC0{i} = Beep_TF_fc; % Store in cell-array
end

for i = 1:length(TFbeep_FC1n)
    load([path_TF1 TFbeep_FC1n{i}]);
    TFstim_FC1{i} = Beep_TF_fc;
end

for i = 1:length(TFbeep_FC2n)
    load([path_TF2 TFbeep_FC2n{i}]);
    TFstim_FC2{i} = Beep_TF_fc;
end

for i = 1:length(TFbeep_FC3n)
    load([path_TF3 TFbeep_FC3n{i}]);
    TFstim_FC3{i} = Beep_TF_fc;
end

%% --- Load filenames and exclude participants (no-stimulation condition) ---

% Wake
TFbase_FC0 = dir(fullfile(path_TF0, '*FC*base*.mat'));
TFbase_FC0n = {TFbase_FC0(:).name};
TFbase_FC0n([2,3,4,10,12,15,16,17,18,21,25,30])= []; % Exclude participants (indices)

% REM
TFbase_FC1 = dir(fullfile(path_TF1, '*FC*base*.mat'));
TFbase_FC1n = {TFbase_FC1(:).name};
TFbase_FC1n([4,5,9])= []; % Exclude participants (indices)
 
% Transitional
TFbase_FC2 = dir(fullfile(path_TF2, '*FC*base*.mat'));
TFbase_FC2n = {TFbase_FC2(:).name};

% NREM
TFbase_FC3 = dir(fullfile(path_TF3, '*FC*base*.mat'));
TFbase_FC3n = {TFbase_FC3(:).name};
TFbase_FC3n([1,2,3,5])= []; % Exclude participants (indices)

%% --- Load files (no-stimulation condition) ---

cfg=[];

for i = 1:length(TFbase_FC0n)
    load([path_TF0 TFbase_FC0n{i}]);  % Load each participant's file for the no-stimulation condition
    TFbl_FC0{i} = Base_TF_fc; % Store in cell-array
end

for i = 1:length(TFbase_FC1n)
    load([path_TF1 TFbase_FC1n{i}]);
    TFbl_FC1{i} = Base_TF_fc;
end

for i = 1:length(TFbase_FC2n)
    load([path_TF2 TFbase_FC2n{i}]);
    TFbl_FC2{i} = Base_TF_fc;
end

for i = 1:length(TFbase_FC3n)
    load([path_TF3 TFbase_FC3n{i}]);
    TFbl_FC3{i} = Base_TF_fc;
end

%% --- Grand averages across participants ---

cfg_g=[];
cfg_g.keepindividual = 'yes';

% Stimulation condition
TFbeep_all_FC0 = ft_freqgrandaverage(cfg_g,TFstim_FC0{:});
TFbeep_all_FC1 = ft_freqgrandaverage(cfg_g,TFstim_FC1{:});
TFbeep_all_FC2  = ft_freqgrandaverage(cfg_g,TFstim_FC2{:});
TFbeep_all_FC3  = ft_freqgrandaverage(cfg_g,TFstim_FC3{:});

% No-stimulation condition
TFbase_all_FC0 = ft_freqgrandaverage(cfg_g,TFbl_FC0{:});
TFbase_all_FC1 = ft_freqgrandaverage(cfg_g,TFbl_FC1{:});
TFbase_all_FC2  = ft_freqgrandaverage(cfg_g,TFbl_FC2{:});
TFbase_all_FC3  = ft_freqgrandaverage(cfg_g,TFbl_FC3{:});

%% --- Single subject plots ---

figure;
for p = 1:size(TFstim_FC3,2)
    subplot(1,1,p); plotTFR(TFstim_FC3{p},   mean(TFstim_FC3{p}.powspctrm  ) , -0.2, 1.5, 1, 30, -0.1, 0.3, [], 'TF Single Subject NREM');
end

%% ----- TF Plotting (difference in power) ------

% Calculate the mean power spectrum
% Stimulation condition
TFbeep_all_FC0m = mean(squeeze(mean(TFbeep_all_FC0.powspctrm, 2)));
TFbeep_all_FC1m = mean(squeeze(mean(TFbeep_all_FC1.powspctrm, 2)));
TFbeep_all_FC2m = mean(squeeze(mean(TFbeep_all_FC2.powspctrm, 2)));
TFbeep_all_FC3m = mean(squeeze(mean(TFbeep_all_FC3.powspctrm, 2)));

% No-stimulation condition
TFbase_all_FC0m = mean(squeeze(mean(TFbase_all_FC0.powspctrm, 2)));
TFbase_all_FC1m = mean(squeeze(mean(TFbase_all_FC1.powspctrm, 2)));
TFbase_all_FC2m = mean(squeeze(mean(TFbase_all_FC2.powspctrm, 2)));
TFbase_all_FC3m = mean(squeeze(mean(TFbase_all_FC3.powspctrm, 2)));

% --- Wake
figure;
plotTFR(TFbeep_all_FC0,TFbeep_all_FC0m - TFbase_all_FC0m, -0.2, 1.5, 0.5, 30, -0.1, 0.3, [], 'TF Wake');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% --- REM
figure;
plotTFR(TFbeep_all_FC1,TFbeep_all_FC1m - TFbase_all_FC1m, -0.2, 1.5, 0.5, 30, -0.1, 0.3, [], 'TF REM');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% --- Transitional
figure;
plotTFR(TFbeep_all_FC2,TFbeep_all_FC2m - TFbase_all_FC2m, -0.2, 1.5, 0.5, 30, -0.1, 0.3, [], 'TFTrans');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% --- NREM
figure;
plotTFR(TFbeep_all_FC3,TFbeep_all_FC3m - TFbase_all_FC3m, -0.2, 1.5, 0.5, 30, -0.1, 0.3, [], 'TF NREM');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

%% --- TF Stats ---

cfg = [];
cfg.statistic       = 'ft_statfun_depsamplesT';
cfg.method          = 'montecarlo'; % Monte Carlo method for calculating the significance probability (p-value)
cfg.correctm        = 'cluster';
cfg.clusteralpha    = 0.05;
cfg.frequency = [0.5 30];
cfg.latency = [-0.2 1.5];
cfg.clusterstatistic = 'maxsum';
cfg.avgoverchan     = 'yes';
cfg.tail            = 0;
cfg.clustertail     = 0;
cfg.alpha           = 0.025;
cfg.numrandomization = 5000;
cfg.uvar            = 1; 
cfg.ivar            = 2;

% --- WAKE
nSubj1 = size(TFbeep_all_FC0.powspctrm,1);
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
stat_W_TF = ft_freqstatistics(cfg,TFbeep_all_FC0, TFbase_all_FC0);

% Plot t-values
%figure;plotTFR_clusters(stat_W_TF,stat_W_TF.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], 'Wake T-values TF', 'ClusterStats', stat_W_TF, 'ClusterType', 'both' )

% --- REM
nSubj1 = size(TFbeep_all_FC1.powspctrm,1);
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
stat_R_TF = ft_freqstatistics(cfg,TFbeep_all_FC1, TFbase_all_FC1);

% Plot t-values
%figure;plotTFR_clusters(stat_R_TF,stat_R_TF.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], 'REM T-values TF', 'ClusterStats', stat_R_TF, 'ClusterType', 'both' )

% --- NREM
nSubj1 = size(TFbeep_all_FC3.powspctrm,1);
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
stat_N_TF = ft_freqstatistics(cfg,TFbeep_all_FC3, TFbase_all_FC3);

% Plot t-values
%figure;plotTFR_clusters(stat_N_TF,stat_N_TF.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], 'NREM T-values TF', 'ClusterStats', stat_N_TF, 'ClusterType', 'both' )

% --- Transitional
nSubj1 = size(TFbeep_all_FC2.powspctrm,1);
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
stat_T_TF = ft_freqstatistics(cfg,TFbeep_all_FC2, TFbase_all_FC2);

% Plot t-values
%figure;plotTFR_clusters(stat_T_TF,stat_T_TF.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], 'Transitional T-values TF', 'ClusterStats', stat_T_TF, 'ClusterType', 'both' )

%%  ITPC ANALYSIS
%  =======================

%% --- Load filenames and exclude participants (stimulation condition) ---

% Wake
ITPCbeep_FC0 = dir(fullfile(path_ITPC0, '*FC*ITPCbeep*.mat'));
ITPCbeep_FC0n = {ITPCbeep_FC0(:).name};
ITPCbeep_FC0n([2,3,4,10,12,15,16,17,18,21,25,30])= []; % Exclude participants (indices)

% REM
ITPCbeep_FC1 = dir(fullfile(path_ITPC1, '*FC*ITPCbeep*.mat'));
ITPCbeep_FC1n = {ITPCbeep_FC1(:).name};
ITPCbeep_FC1n([4,5,9])= []; % Exclude participants (indices)

% Transitional
ITPCbeep_FC2 = dir(fullfile(path_ITPC2, '*FC*ITPCbeep*.mat'));
ITPCbeep_FC2n = {ITPCbeep_FC2(:).name};

% NREM
ITPCbeep_FC3 = dir(fullfile(path_ITPC3, '*FC*ITPCbeep*.mat'));
ITPCbeep_FC3n = {ITPCbeep_FC3(:).name};
ITPCbeep_FC3n([1,2,3,5])= []; % Exclude participants (indices)

%% --- Load files (stimulation condition) ---

for i = 1:length(ITPCbeep_FC0n)
    load([path_ITPC0 ITPCbeep_FC0n{i}]); % Load each participant's file for the stimulation condition
    ITPCstim_FC0{i} = Beep_i_fc; % Store in cell array
end

for i = 1:length(ITPCbeep_FC1n)
    load([path_ITPC1 ITPCbeep_FC1n{i}]);
    ITPCstim_FC1{i} = Beep_i_fc;
end

for i = 1:length(ITPCbeep_FC2n)
    load([path_ITPC2 ITPCbeep_FC2n{i}]);
    ITPCstim_FC2{i} = Beep_i_fc;
end

for i = 1:length(ITPCbeep_FC3n)
    load([path_ITPC3 ITPCbeep_FC3n{i}]);
    ITPCstim_FC3{i} = Beep_i_fc;
end

%% --- Load filenames and exclude participants (no-stimulation condition) ---

% Wake
ITPCbase_FC0 = dir(fullfile(path_ITPC0, '*FC*base*.mat'));
ITPCbase_FC0n = {ITPCbase_FC0(:).name};
ITPCbase_FC0n([2,3,4,10,12,15,16,17,18,21,25,30])= []; % Exclude participants (indices)

% REM
ITPCbase_FC1 = dir(fullfile(path_ITPC1, '*FC*base*.mat'));
ITPCbase_FC1n = {ITPCbase_FC1(:).name};
ITPCbase_FC1n([4,5,9])= []; % Exclude participants (indices)

% Transitional
ITPCbase_FC2 = dir(fullfile(path_ITPC2, '*FC*base*.mat'));
ITPCbase_FC2n = {ITPCbase_FC2(:).name};

% NREM
ITPCbase_FC3 = dir(fullfile(path_ITPC3, '*FC*base*.mat'));
ITPCbase_FC3n = {ITPCbase_FC3(:).name};
ITPCbase_FC3n([1,2,3,5])= []; % Exclude participants (indices)

%% --- Load files (no-stimulation condition) ---

cfg=[];

for i = 1:length(ITPCbase_FC0n)
    load([path_ITPC0 ITPCbase_FC0n{i}]); % Load each participant's file for the sno-timulation condition
    ITPCbl_FC0{i} = Base_i_fc; % Store in cell array
end

for i = 1:length(ITPCbase_FC1n)
    load([path_ITPC1 ITPCbase_FC1n{i}]);
    ITPCbl_FC1{i} = Base_i_fc;
end

for i = 1:length(ITPCbase_FC2n)
    load([path_ITPC2 ITPCbase_FC2n{i}]);
    ITPCbl_FC2{i} = Base_i_fc;
end

for i = 1:length(ITPCbase_FC3n)
    load([path_ITPC3 ITPCbase_FC3n{i}]);
    ITPCbl_FC3{i} = Base_i_fc;
end

%% --- Grand averages across participants ---

cfg_g = [];
cfg_g.keepindividual = 'yes';
cfg_g.parameter = 'itpc';

% Stimulation condition
ITPCbeep_all_FC0 = ft_freqgrandaverage(cfg_g,ITPCstim_FC0{:});
ITPCbeep_all_FC1 = ft_freqgrandaverage(cfg_g,ITPCstim_FC1{:});
ITPCbeep_all_FC2  = ft_freqgrandaverage(cfg_g,ITPCstim_FC2{:});
ITPCbeep_all_FC3  = ft_freqgrandaverage(cfg_g,ITPCstim_FC3{:});

% No-stimulation condition
ITPCbase_all_FC0 = ft_freqgrandaverage(cfg_g,ITPCbl_FC0{:});
ITPCbase_all_FC1 = ft_freqgrandaverage(cfg_g,ITPCbl_FC1{:});
ITPCbase_all_FC2  = ft_freqgrandaverage(cfg_g,ITPCbl_FC2{:});
ITPCbase_all_FC3  = ft_freqgrandaverage(cfg_g,ITPCbl_FC3{:});

%% --- Single subject plots ---

figure;
for p = 1:size(ITPCstim_FC3,2)
    subplot(1,1,p); plotTFR(ITPCstim_FC3{p},   mean(ITPCbl_FC3{p}.itpc) , -0.2, 1.5, 1, 30, -0.05, 0.05, [], 'ITPC Single Subject NREM');
end

%% ----- TF Plotting (difference in ITPC) ------

% Calculate the mean power spectrum

% Stimulation condition
ITPCbeep_all_FC0m = mean(squeeze(mean(ITPCbeep_all_FC0.itpc, 2)));
ITPCbeep_all_FC1m = mean(squeeze(mean(ITPCbeep_all_FC1.itpc, 2)));
ITPCbeep_all_FC2m = mean(squeeze(mean(ITPCbeep_all_FC2.itpc, 2)));
ITPCbeep_all_FC3m = mean(squeeze(mean(ITPCbeep_all_FC3.itpc, 2)));

% No-stimulation condition
ITPCbase_all_FC0m = mean(squeeze(mean(ITPCbase_all_FC0.itpc, 2)));
ITPCbase_all_FC1m = mean(squeeze(mean(ITPCbase_all_FC1.itpc, 2)));
ITPCbase_all_FC2m = mean(squeeze(mean(ITPCbase_all_FC2.itpc, 2)));
ITPCbase_all_FC3m = mean(squeeze(mean(ITPCbase_all_FC3.itpc, 2)));

% Wake
figure;
plotTFR(ITPCbeep_all_FC0,ITPCbeep_all_FC0m - ITPCbase_all_FC0m, -0.2, 1.5, 0.5, 30, -0.05, 0.05, [], 'ITPC Wake');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]); % squared

% REM
figure;
plotTFR(ITPCbeep_all_FC1,ITPCbeep_all_FC1m - ITPCbase_all_FC1m, -0.2, 1.5, 0.5, 30, -0.05, 0.05, [], 'ITPC REM');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]); % squared

% Transitional
figure;
plotTFR(ITPCbeep_all_FC2,ITPCbeep_all_FC2m - ITPCbase_all_FC2m, -0.2, 1.5, 0.5, 30, -0.05, 0.05, [], 'ITPC Transitional');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]); % squared

% NREM
figure;
plotTFR(ITPCbeep_all_FC3,ITPCbeep_all_FC3m - ITPCbase_all_FC3m, -0.2, 1.5, 0.5, 30, -0.05, 0.05, [], 'ITPC NREM');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]); % squared

%% --- ITPC Stats ---

cfg = [];
cfg.statistic       = 'ft_statfun_depsamplesT';
cfg.method          = 'montecarlo'; % Monte Carlo method for calculating the significance probability (p-value)
cfg.correctm        = 'cluster';
cfg.parameter        = 'itpc'
cfg.clusteralpha    = 0.05;
cfg.frequency = [0.5 30];
cfg.latency = [-0.2 1.5];
cfg.clusterstatistic = 'maxsum';
cfg.avgoverchan     = 'yes';
cfg.tail            = 0;
cfg.clustertail     = 0;
cfg.alpha           = 0.025;
cfg.numrandomization = 5000;
cfg.uvar            = 1;  % Define within-subject variance
cfg.ivar            = 2;  % Define between-group variance

% --- Wake
nSubj1 = size(ITPCbeep_all_FC0.itpc,1);
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
stat_W_ITPC = ft_freqstatistics(cfg,ITPCbeep_all_FC0, ITPCbase_all_FC0);

% Plot t-values
% figure;plotTFR_clusters(stat_W_ITPC,stat_W_ITPC.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], 'Wake T-values ITPC', 'ClusterStats', stat_W_ITPC, 'ClusterType', 'both' )

% --- REM
nSubj1 = size(ITPCbeep_all_FC1.itpc,1);
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
% stat_R_ITPC = ft_freqstatistics(cfg,ITPCbeep_all_FC1, ITPCbase_all_FC1);

% Plot t-values
%figure;plotTFR_clusters(stat_R_ITPC,stat_R_ITPC.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], 'REM T-values ITPC', 'ClusterStats', stat_R_ITPC, 'ClusterType', 'both' )

% --- NREM
nSubj1 = size(ITPCbeep_all_FC3.itpc,1);
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
stat_N_ITPC = ft_freqstatistics(cfg,ITPCbeep_all_FC3, ITPCbase_all_FC3);

% Plot t-values
%figure;plotTFR_clusters(stat_N_ITPC,stat_N_ITPC.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], 'NREM T-values ITPC', 'ClusterStats', stat_N_ITPC, 'ClusterType', 'both' )

% --- Transitional
nSubj1 = size(ITPCbeep_all_FC2.itpc,1);
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
stat_T_ITPC = ft_freqstatistics(cfg,ITPCbeep_all_FC2, ITPCbase_all_FC2);

% Plot t-values
%figure;plotTFR_clusters(stat_T_ITPC,stat_T_ITPC.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], 'Transitional T-values ITPC', 'ClusterStats', stat_T_ITPC, 'ClusterType', 'both' )

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%