%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  Paths and setup

clear;

% Add paths
addpath(genpath('xxx/Helper')) % Add path to costumn helper folder
Baby_baby_paths; % Costumn script that sets up all project-specific paths and folders

addpath('/xxx/Helper/DrosteEffect-BrewerMap-5b84f95'); % Add path to helper package needed for visualization

%% --- Paths to data ---

path_TF1 = 'xxx';
path_ITPC1 = 'xxx';

path_TF2 = 'xxx';
path_ITPC2 = 'xxx';

path_TF3 = 'xxx';
path_ITPC3 = 'xxx';


%%  TF ANALYSIS
%  =======================

%% --- Load filenames and exclude participants ---

% 2W
% Load filenames for stimulation condition
TFbeep_FC1 = dir(fullfile(path_TF1, '*FC*beep*.mat'));
TFbeep_FC1n = {TFbeep_FC1(:).name};
TFbeep_FC1n([1,4,5,6,13,17,18,21,22,23,24,28,29,30,31,34,36,39,40,41,42,49,57,59,61])= []; %Exclude participants (indices)

% Load filenames for no-stimulation condition
TFbase_FC1 = dir(fullfile(path_TF1, '*FC*base*.mat'));
TFbase_FC1n = {TFbase_FC1(:).name};
TFbase_FC1n([1,4,5,6,13,17,18,21,22,23,24,28,29,30,31,34,36,39,40,41,42,49,57,59,61])= []; %Exclude participants (indices)

% 6M
TFbeep_FC2 = dir(fullfile(path_TF2, '*FC*beep*.mat'));
TFbeep_FC2n = {TFbeep_FC2(:).name};
TFbeep_FC2n([1,25,29,43,52,59,60,62,67]) =[]; % Exclude participants (indices)

TFbase_FC2 = dir(fullfile(path_TF2, '*FC*base*.mat'));
TFbase_FC2n = {TFbase_FC2(:).name};
TFbase_FC2n([1,25,29,43,52,59,60,62,67]) =[]; % Exclude participants (indices)

%12M
TFbeep_FC3 = dir(fullfile(path_TF3, '*FC*beep*.mat'));
TFbeep_FC3n = {TFbeep_FC3(:).name};
TFbeep_FC3n([3, 22, 29, 38, 39, 40, 45, 51, 54, 58, 59, 61]) =[]; % Exclude participants (indices)

TFbase_FC3 = dir(fullfile(path_TF3, '*FC*base*.mat'));
TFbase_FC3n = {TFbase_FC3(:).name};
TFbase_FC3n([3, 22, 29, 38, 39, 40, 45, 51, 54, 58, 59, 61]) =[]; % Exclude participants (indices)


%% --- Load files ---

%2W
for i = 1:length(TFbeep_FC1n)
    load([path_TF1 TFbeep_FC1n{i}]); % Load each participant's file for the stimulation condition
    TFstim_FC1{i} = Beep_TF_fc; % Store in cell array
end

for i = 1:length(TFbase_FC1n)
    load([path_TF1 TFbase_FC1n{i}]); % Load each participant's file for the no-stimulation condition
    TFbl_FC1{i} = Base_TF_fc; % Store in cell array
end

% 6M
for i = 1:length(TFbeep_FC2n)
    load([path_TF2 TFbeep_FC2n{i}]);
    TFstim_FC2{i} = Beep_TF_fc;
end

for i = 1:length(TFbase_FC2n)
    load([path_TF2 TFbase_FC2n{i}]);
    TFbl_FC2{i} = Base_TF_fc;
end

% 12M
for i = 1:length(TFbeep_FC3n)
    load([path_TF3 TFbeep_FC3n{i}]);
    TFstim_FC3{i} = Beep_TF_fc;
end

for i = 1:length(TFbase_FC3n)
    load([path_TF3 TFbase_FC3n{i}]);
    TFbl_FC3{i} = Base_TF_fc;
end

%% --- Single subject plots ---

figure;
for p = 1:size(TFstim_FC2,2)
    subplot(7,10,p); plotTFR(TFstim_FC2{p},   mean(TFstim_FC2{p}.powspctrm  ) , -0.2, 1.5, 1, 30, -0.1, 0.5, [], 'ITPC Difference 2W vs 6M');

end

%% --- Grand averages across participants ---

cfg_g=[];
cfg_g.keepindividual = 'yes';

% Compute grand averages for all participants at each developmental stage
% Stimulation condition
BEEP_all_FC2 = ft_freqgrandaverage(cfg_g, TFstim_FC2{:});
BEEP_all_FC3 = ft_freqgrandaverage(cfg_g, TFstim_FC3{:});
BEEP_all_FC1 = ft_freqgrandaverage(cfg_g, TFstim_FC1{:});
% No-stimulation condition
BASE_all_FC2 = ft_freqgrandaverage(cfg_g, TFbl_FC2{:});
BASE_all_FC3 = ft_freqgrandaverage(cfg_g, TFbl_FC3{:});
BASE_all_FC1 = ft_freqgrandaverage(cfg_g, TFbl_FC1{:});

%% ----- TF Plotting (difference in power) ------

% Calculate the mean power spectrum
% Stimulation condition
BEEP_all_FC1m = mean(squeeze(mean(BEEP_all_FC1 .powspctrm, 2)));
BEEP_all_FC2m = mean(squeeze(mean(BEEP_all_FC2.powspctrm, 2)));
BEEP_all_FC3m = mean(squeeze(mean(BEEP_all_FC3.powspctrm, 2)));

% No-stimulation condition
BASE_all_FC1m = mean(squeeze(mean(BASE_all_FC1 .powspctrm, 2)));
BASE_all_FC2m = mean(squeeze(mean(BASE_all_FC2.powspctrm, 2)));
BASE_all_FC3m = mean(squeeze(mean(BASE_all_FC3.powspctrm, 2)));

% --- 2W
figure;
plotTFR(BEEP_all_FC1,BEEP_all_FC1m - BASE_all_FC1m, -0.2, 1.5, 0.5, 30, -0.1, 0.3, [], 'TF 2W');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% --- 6M
figure;
plotTFR(BEEP_all_FC2,BEEP_all_FC2m - BASE_all_FC2m, -0.2, 1.5, 0.5, 30, -0.1, 0.3, [], 'TF 6M');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% --- 12M
figure;
plotTFR(BEEP_all_FC3,BEEP_all_FC3m - BASE_all_FC3m, -0.2, 1.5, 0.5, 30, -0.1, 0.3, [], 'TF 12M');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

%% --- TF Stats ---

cfg = [];
cfg.statistic       = 'ft_statfun_depsamplesT'; % between groups independent samples statistics
cfg.method          = 'montecarlo'; % Monte Carlo method for calculating the significance probability (p-value)
cfg.correctm        = 'cluster';
cfg.clusteralpha    = 0.05;
cfg.frequency       = [0.5 30];
cfg.latency        = [-0.2 1.5];
cfg.clusterstatistic = 'maxsum';
cfg.avgoverchan     = 'yes';
cfg.tail            = 0;
cfg.clustertail     = 0;
cfg.alpha           = 0.025;
cfg.numrandomization = 5000;
cfg.uvar            = 1;  % Define within-subject variance
cfg.ivar            = 2;  % Define between-group variance

%2W
nSubj1 = size(BEEP_all_FC1.powspctrm,1);
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
[stat_TF_vs_BL_2W] = ft_freqstatistics(cfg, BEEP_all_FC1, BASE_all_FC1);

% Plot t-values (stimuation vs no-stimulation condition)
figure; plotTFR_clusters(stat_TF_vs_BL_2W,stat_TF_vs_BL_2W.stat, -0.2, 1.5, 0.5, 30, -4 ,4, [], 'Power', 'ClusterStats', stat_TF_vs_BL_2W, 'ClusterType', 'both' )
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% 6M
nSubj1 = size(BEEP_all_FC2.powspctrm,1);
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
[stat_TF_vs_BL_6M] = ft_freqstatistics(cfg, BEEP_all_FC2, BASE_all_FC2);

% Plot t-values (stimuation vs no-stimulation condition)
figure; plotTFR_clusters(stat_TF_vs_BL_6M,stat_TF_vs_BL_6M.stat, -0.2, 1.5, 0.5, 30, -4 ,4, [], 'Power', 'ClusterStats', stat_TF_vs_BL_6M, 'ClusterType', 'both' )
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% 12M
nSubj1 = size(BEEP_all_FC3.powspctrm,1);
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
[stat_TF_vs_BL_12M] = ft_freqstatistics(cfg, BEEP_all_FC3, BASE_all_FC3);

% Plot t-values (stimuation vs no-stimulation condition)
figure; plotTFR_clusters(stat_TF_vs_BL_12M,stat_TF_vs_BL_12M.stat, -0.2, 1.5, 0.5, 30, -4 ,4, [], 'Power', 'ClusterStats', stat_TF_vs_BL_12M, 'ClusterType', 'both' )
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

%%  ITPC ANALYSIS
%  =======================
%% --- Load filenames and exclude participants ---
% 2W
% Load filenames for stimulation condition
ITPCbeep_FC1 = dir(fullfile(path_ITPC1, '*FC*beep*.mat'));
ITPCbeep_FC1n = {ITPCbeep_FC1(:).name};
ITPCbeep_FC1n([1,4,5,6,13,17,18,21,22,23,24,28,29,30,31,34,36,39,40,41,42,49,57,59,61])= []; % Exclude participants (indices)

% Load filenames for no-stimulation condition
ITPCbase_FC1 = dir(fullfile(path_ITPC1, '*FC*base*.mat'));
ITPCbase_FC1n = {ITPCbase_FC1(:).name};
ITPCbase_FC1n([1,4,5,6,13,17,18,21,22,23,24,28,29,30,31,34,36,39,40,41,42,49,57,59,61])= []; % Exclude participants (indices)

% 6M
ITPCbeep_FC2 = dir(fullfile(path_ITPC2, '*FC*beep*.mat'));
ITPCbeep_FC2n = {ITPCbeep_FC2(:).name};
ITPCbeep_FC2n([1,25,29,43,52,59,60,62,67]) =[]; % Exclude participants (indices)
 
ITPCbase_FC2 = dir(fullfile(path_ITPC2, '*FC*base*.mat'));
ITPCbase_FC2n = {ITPCbase_FC2(:).name};
ITPCbase_FC2n([1,25,29,43,52,59,60,62,67]) =[]; % Exclude participants (indices)

%12M
ITPCbeep_FC3 = dir(fullfile(path_ITPC3, '*FC*beep*.mat'));
ITPCbeep_FC3n = {ITPCbeep_FC3(:).name};
ITPCbeep_FC3n([3, 22, 29, 38, 39, 40, 45, 51, 54, 58, 59, 61]) =[]; % Exclude participants (indices)

ITPCbase_FC3 = dir(fullfile(path_ITPC3, '*FC*base*.mat'));
ITPCbase_FC3n = {ITPCbase_FC3(:).name};
ITPCbase_FC3n([3, 22, 29, 38, 39, 40, 45, 51, 54, 58, 59, 61]) =[]; % Exclude participants (indices)
 
%% --- Load files ---

%2W
for i = 1:length(ITPCbeep_FC1n)
    load([path_ITPC1 ITPCbeep_FC1n{i}]); % Load each participant's file for the stimulation condition
    ITPCstim_FC1{i} = Beep_i_fc; % Store in cell array
end

for i = 1:length(ITPCbase_FC1n)
    load([path_ITPC1 ITPCbase_FC1n{i}]); % Load each participant's file for the no-stimulation condition
    ITPCbl_FC1{i} = Base_i_fc; % Store in cell array
end

%6M
for i = 1:length(ITPCbeep_FC2n)
    load([path_ITPC2 ITPCbeep_FC2n{i}]);
    ITPCstim_FC2{i} = Beep_i_fc;
end

for i = 1:length(ITPCbase_FC2n)
    load([path_ITPC2 ITPCbase_FC2n{i}]);
    ITPCbl_FC2{i} = Base_i_fc;
end

% 12M
for i = 1:length(ITPCbeep_FC3n)
    load([path_ITPC3 ITPCbeep_FC3n{i}]);
    ITPCstim_FC3{i} = Beep_i_fc;
end

for i = 1:length(ITPCbase_FC3n)
    load([path_ITPC3 ITPCbase_FC3n{i}]);
    ITPCbl_FC3{i} = Base_i_fc;
end

%% --- Single subject plots ---

figure;
for p = 1:size(ITPCstim_FC2,2)
    subplot(7,10,p); plotTFR(ITPCstim_FC2{p},   mean(ITPCbl_FC2{p}.itpc) , -0.2, 1.5, 1, 30, -0.1, 0.5, [], 'ITPC Difference 2W vs 6M');
end

%% --- Grand averages across participants ---

cfg_g=[];
cfg_g.keepindividual = 'yes';
cfg_g.parameter = 'itpc';

% Compute grand averages for all participants at each developmental stage
% Stimualtion condition
BEEP_all_FC2 = ft_freqgrandaverage(cfg_g, ITPCstim_FC2{:});
BEEP_all_FC3 = ft_freqgrandaverage(cfg_g, ITPCstim_FC3{:});
BEEP_all_FC1 = ft_freqgrandaverage(cfg_g, ITPCstim_FC1{:});
% No-stimulation condition
BASE_all_FC2 = ft_freqgrandaverage(cfg_g, ITPCbl_FC2{:});
BASE_all_FC3 = ft_freqgrandaverage(cfg_g, ITPCbl_FC3{:});
BASE_all_FC1 = ft_freqgrandaverage(cfg_g, ITPCbl_FC1{:});


%% ----- ITPC Plotting (difference plots) ------

% Calculate the mean power spectrum
% Stimulation condition
BEEP_all_FC1m = mean(squeeze(mean(BEEP_all_FC1.itpc, 2)));
BEEP_all_FC2m = mean(squeeze(mean(BEEP_all_FC2.itpc, 2)));
BEEP_all_FC3m = mean(squeeze(mean(BEEP_all_FC3.itpc, 2)));

% No-stimulation condition
BASE_all_FC1m = mean(squeeze(mean(BASE_all_FC1.itpc, 2)));
BASE_all_FC2m = mean(squeeze(mean(BASE_all_FC2.itpc, 2)));
BASE_all_FC3m = mean(squeeze(mean(BASE_all_FC3.itpc, 2)));

% --- 2W
figure;
plotTFR(BEEP_all_FC1,BEEP_all_FC1m - BASE_all_FC1m, -0.2, 1.5, 0.5, 30, -0.1, 0.3, [], 'ITPC 2W');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% --- 6M
figure;
plotTFR(BEEP_all_FC2,BEEP_all_FC2m - BASE_all_FC2m, -0.2, 1.5, 0.5, 30, -0.1, 0.3, [], 'ITPC 6M');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% --- 12M
figure;
plotTFR(BEEP_all_FC3,BEEP_all_FC3m - BASE_all_FC3m, -0.2, 1.5, 0.5, 30, -0.1, 0.3, [], 'ITPC 12M');
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

%% --- ITPC Stats ---

cfg = [];
cfg.statistic       = 'ft_statfun_depsamplesT'; % between groups independent samples statistics
cfg.method          = 'montecarlo'; % Monte Carlo method for calculating the significance probability (p-value)
cfg.correctm        = 'cluster';
cfg.parameter       = 'itpc';
cfg.clusteralpha    = 0.05;
cfg.frequency       = [0.5 30];
cfg.latency        = [-0.2 1.5];
cfg.clusterstatistic = 'maxsum';
cfg.avgoverchan     = 'yes';
cfg.tail            = 0;
cfg.clustertail     = 0;
cfg.alpha           = 0.025;
cfg.numrandomization = 5000;
cfg.uvar            = 1;  % Define within-subject variance
cfg.ivar            = 2;  % Define between-group variance

% 2W
nSubj1 = size(BEEP_all_FC1.itpc,1);
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
[stat_ITPC_2W] = ft_freqstatistics(cfg, BEEP_all_FC1, BASE_all_FC1);

% Plot t-values (stimuation vs no-stimulation condition)
figure; plotTFR_clusters(stat_ITPC_2W,stat_ITPC_2W.stat, -0.2, 1.5, 0.5, 30, -4 ,4, [], 'ITPC', 'ClusterStats', stat_ITPC_2W, 'ClusterType', 'both' )
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% 6M
nSubj1 = size(BEEP_all_FC2.itpc,1);
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
[stat_ITPC_6M] = ft_freqstatistics(cfg, BEEP_all_FC2, BASE_all_FC2);

% Plot t-values (stimuation vs no-stimulation condition)
figure; plotTFR_clusters(stat_ITPC_6M,stat_ITPC_6M.stat, -0.2, 1.5, 0.5, 30, -4 ,4, [], 'ITPC', 'ClusterStats', stat_ITPC_6M, 'ClusterType', 'both' )
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% 12M
nSubj1 = size(BEEP_all_FC3.itpc,1);
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
[stat_ITPC_12M] = ft_freqstatistics(cfg, BEEP_all_FC3, BASE_all_FC3);

% Plot t-values (stimuation vs no-stimulation condition)
figure; plotTFR_clusters(stat_ITPC_12M,stat_ITPC_12M.stat, -0.2, 1.5, 0.5, 30, -4 ,4, [], 'ITPC', 'ClusterStats', stat_ITPC_12M, 'ClusterType', 'both' )
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%