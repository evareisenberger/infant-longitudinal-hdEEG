%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  Paths and setup

%  =======================
clear;

% Add paths
addpath(genpath('/xxx/Helper')) % Add path to costumn helper script
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

TFbeep_FC1 = dir(fullfile(path_TF1, '*FC*TFbeep*.mat'));
TFbeep_FC1n = {TFbeep_FC1(:).name};
TFbeep_FC1n([2,3,4,10,12,15,16,17,18,21,25,30]) = []; % Exclude participants (indices)

TFbeep_FC2 = dir(fullfile(path_TF2, '*FC*TFbeep*.mat'));
TFbeep_FC2n = {TFbeep_FC2(:).name};
TFbeep_FC2n([1,25,29,43,52,59,60,62,67]) = []; % Exclude participants (indices)

TFbeep_FC3 = dir(fullfile(path_TF3, '*FC*TFbeep*.mat'));
TFbeep_FC3n = {TFbeep_FC3(:).name};
TFbeep_FC3n([3, 22, 29, 38, 39, 40, 45, 51, 54, 58, 59, 61]) = []; % Exclude participants (indices)

%% --- Load files ---

for i = 1:length(TFbeep_FC1n)
    load([path_TF1 TFbeep_FC1n{i}]); % Load each participant's file for the stimulation condition
    TFstim_FC1{i} = Beep_TF_fc;  % Store in cell array
end

for i = 1:length(TFbeep_FC2n)
    load([path_TF2 TFbeep_FC2n{i}]);
    TFstim_FC2{i} = Beep_TF_fc;
end

for i = 1:length(TFbeep_FC3n)
    load([path_TF3 TFbeep_FC3n{i}]);
    TFstim_FC3{i} = Beep_TF_fc;
end

%% --- Matching subjects across age groups --- 

%Extract participant IDs from characters 4 to 8 for 2W/ 6M and 5:9 for 12M
getIDs = @(names) cellfun(@(x) x(4:8), names, 'UniformOutput', false);
getIDs_12M = @(names) cellfun(@(x) x(5:9), names, 'UniformOutput', false);

IDs_2W = getIDs(TFbeep_FC1n);
IDs_6M = getIDs(TFbeep_FC2n);
IDs_12M = getIDs_12M(TFbeep_FC3n);

% Match 2W vs 6M
[isMatch_2W_6M, idx_2W_6M] = ismember(IDs_2W, IDs_6M);
idx_2W_matched_6M = find(isMatch_2W_6M);
idx_6M_matched_2W = idx_2W_6M(isMatch_2W_6M);

% Match 2W vs 12M
[isMatch_2W_12M, idx_2W_12M] = ismember(IDs_2W, IDs_12M);
idx_2W_matched_12M = find(isMatch_2W_12M);
idx_12M_matched_2W = idx_2W_12M(isMatch_2W_12M);

% Match 6M vs 12M
[isMatch_6M_12M, idx_6M_12M] = ismember(IDs_6M, IDs_12M);
idx_6M_matched_12M = find(isMatch_6M_12M);
idx_12M_matched_6M = idx_6M_12M(isMatch_6M_12M);

%% --- Select common subjects ---

% --- 2W vs 6M
TFstim_FC1N = TFstim_FC1(idx_2W_matched_6M);
TFstim_FC2N = TFstim_FC2(idx_6M_matched_2W);

% --- 2w vs 12M
TFstim_FC1O = TFstim_FC1(idx_2W_matched_12M);
TFstim_FC3O = TFstim_FC3(idx_12M_matched_2W);

% --- 6M w 12M
TFstim_FC2P = TFstim_FC2(idx_6M_matched_12M);
TFstim_FC3P = TFstim_FC3(idx_12M_matched_6M);


%% --- Grand averages across common subjects ---

cfg_g=[]; cfg_g.keepindividual = 'yes';

BEEP_TF_FC1_N = ft_freqgrandaverage(cfg_g,TFstim_FC1N{:});
BEEP_TF_FC2_N = ft_freqgrandaverage(cfg_g,TFstim_FC2N{:});

BEEP_TF_FC1_O = ft_freqgrandaverage(cfg_g,TFstim_FC1O{:});
BEEP_TF_FC3_O = ft_freqgrandaverage(cfg_g,TFstim_FC3O{:});

BEEP_TF_FC2_P = ft_freqgrandaverage(cfg_g,TFstim_FC2P{:});
BEEP_TF_FC3_P = ft_freqgrandaverage(cfg_g,TFstim_FC3P{:});

%% --- TF Stats ---

cfg                  = [];
cfg.method           = 'montecarlo'; % use the Monte Carlo Method to calculate the significance probability
cfg.statistic       ='ft_statfun_depsamplesT'; %between groups independant sampels statistics
cfg.frequency        = [0.5 30];
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;       % alpha level of the sample-specific test statistic that
cfg.latency          = [-0.2 1.5];
cfg.avgoverchan      = 'yes';
cfg.clusterstatistic = 'maxsum';   % test statistic that will be evaluated under the
cfg.tail             = 0;          % -1, 1 or 0 (default = 0); one-sided or two-sided test
cfg.clustertail      = 0;
cfg.alpha            = 0.025;      % alpha level of the permutation test
cfg.numrandomization = 5000;        % number of draws from the permutation distribution
cfg.uvar             = 1;
cfg.ivar             = 2;

% Statistical pairwise comparisons

% --- 2W vs 6M
subj = size(BEEP_TF_FC1_N.powspctrm,1);
design1 = zeros(2,2*subj);
for m = 1:subj
 design1(1,m) = m;
end
for m = 1:subj
design1(1,subj+m) = m;
end
design1(2,1:subj) = 1;
design1(2,subj+1:2*subj) = 2;
cfg.design= design1; 

% Run the stats
[stat_TF_FC_2W_vs_6M]   = ft_freqstatistics(cfg, BEEP_TF_FC2_N, BEEP_TF_FC1_N);

% Plot t-values
figure; plotTFR_clusters(stat_TF_FC_2W_vs_6M,stat_TF_FC_2W_vs_6M.stat, -0.2, 1.5, 0.5, 30, -4 ,4, [], 'Power', 'ClusterStats', stat_TF_FC_2W_vs_6M, 'ClusterType', 'both' )
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% --- 2W vs 12M
subj = size(BEEP_TF_FC1_O.powspctrm,1);
design2 = zeros(2,2*subj);
for m = 1:subj
 design2(1,m) = m;
end
for m = 1:subj
design2(1,subj+m) = m;
end
design2(2,1:subj) = 1;
design2(2,subj+1:2*subj) = 2;
cfg.design= design2; 

% Run the stats
[stat_TF_FC_2W_vs_12M]   = ft_freqstatistics(cfg, BEEP_TF_FC3_O, BEEP_TF_FC1_O);

% Plot t-values
figure; plotTFR_clusters(stat_TF_FC_2W_vs_12M,stat_TF_FC_2W_vs_12M.stat, -0.2, 1.5, 0.5, 30, -4 ,4, [], 'Power', 'ClusterStats', stat_TF_FC_2W_vs_12M, 'ClusterType', 'both' )
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% --- 6M vs 12M
subj = size(BEEP_TF_FC2_P.powspctrm,1);
design3 = zeros(2,2*subj);
for m = 1:subj
 design3(1,m) = m;
end
for m = 1:subj
design3(1,subj+m) = m;
end
design3(2,1:subj) = 1;
design3(2,subj+1:2*subj) = 2;
cfg.design= design3; 

% Run the stats
[stat_TF_FC_6M_vs_12M]   = ft_freqstatistics(cfg, BEEP_TF_FC3_P, BEEP_TF_FC2_P);

% Plot t-values
figure; plotTFR_clusters(stat_TF_FC_6M_vs_12M,stat_TF_FC_6M_vs_12M.stat, -0.2, 1.5, 0.5, 30, -4 ,4, [], 'Power', 'ClusterStats', stat_TF_FC_6M_vs_12M, 'ClusterType', 'both' )
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

%%  ITPC ANALYSIS
%  =======================

%% --- Load filenames and exclude participants ---

ITPCbeep_FC1 = dir(fullfile(path_ITPC1, '*FC*ITPCbeep*.mat'));
ITPCbeep_FC1n = {ITPCbeep_FC1(:).name};
ITPCbeep_FC1n([2,3,4,10,12,15,16,17,18,21,25,30]) = []; % Exclude participants (indices)

ITPCbeep_FC2 = dir(fullfile(path_ITPC2, '*FC*ITPCbeep*.mat'));
ITPCbeep_FC2n = {ITPCbeep_FC2(:).name};
ITPCbeep_FC2n([1,25,29,43,52,59,60,62,67]) = []; % Exclude participants (indices)

ITPCbeep_FC3 = dir(fullfile(path_ITPC3, '*FC*ITPCbeep*.mat'));
ITPCbeep_FC3n = {ITPCbeep_FC3(:).name};
ITPCbeep_FC3n([3, 22, 29, 38, 39, 40, 45, 51, 54, 58, 59, 61]) = []; % Exclude participants (indices)

%% --- Load files ---

for i = 1:length(ITPCbeep_FC1n)
    load([path_ITPC1 ITPCbeep_FC1n{i}]); % Load each participant's file for the stimulation condition
    ITPCstim_FC1{i} = Beep_i_fc;  % Store in cell array
end

for i = 1:length(ITPCbeep_FC2n)
    load([path_ITPC2 ITPCbeep_FC2n{i}]);
    ITPCstim_FC2{i} = Beep_i_fc;
end

for i = 1:length(ITPCbeep_FC3n)
    load([path_ITPC3 ITPCbeep_FC3n{i}]);
    ITPCstim_FC3{i} = Beep_i_fc;
end

%% --- Select common subjects ---

% --- 2W vs 6M
ITPCstim_FC1N = ITPCstim_FC1(idx_2W_matched_6M);
ITPCstim_FC2N = ITPCstim_FC2(idx_6M_matched_2W);

% --- 2w vs 12M
ITPCstim_FC1O = ITPCstim_FC1(idx_2W_matched_12M);
ITPCstim_FC3O = ITPCstim_FC3(idx_12M_matched_2W);

% --- 6M w 12M
ITPCstim_FC2P = ITPCstim_FC2(idx_6M_matched_12M);
ITPCstim_FC3P = ITPCstim_FC3(idx_12M_matched_6M);

%% --- Grand averages across common subjects ---

cfg_g = [];
cfg_g.keepindividual = 'yes';
cfg_g.parameter = 'itpc';

BEEP_ITPC_FC1_N = ft_freqgrandaverage(cfg_g,ITPCstim_FC1N{:});
BEEP_ITPC_FC2_N = ft_freqgrandaverage(cfg_g,ITPCstim_FC2N{:});

BEEP_ITPC_FC1_O = ft_freqgrandaverage(cfg_g,ITPCstim_FC1O{:});
BEEP_ITPC_FC3_O = ft_freqgrandaverage(cfg_g,ITPCstim_FC3O{:});

BEEP_ITPC_FC2_P = ft_freqgrandaverage(cfg_g,ITPCstim_FC2P{:});
BEEP_ITPC_FC3_P = ft_freqgrandaverage(cfg_g,ITPCstim_FC3P{:});

%% --- ITPC Stats ---

cfg                  = [];
cfg.method           = 'montecarlo'; % use the Monte Carlo Method to calculate the significance probability
cfg.parameter        = 'itpc'
cfg.statistic        ='ft_statfun_depsamplesT'; %between groups independant sampels statistics
cfg.frequency        = [0.5 30];
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;       % alpha level of the sample-specific test statistic that
cfg.latency          = [-0.2 1.5];
cfg.avgoverchan      = 'yes';
cfg.clusterstatistic = 'maxsum';   % test statistic that will be evaluated under the
cfg.tail             = 0;          % -1, 1 or 0 (default = 0); one-sided or two-sided test
cfg.clustertail      = 0;
cfg.alpha            = 0.025;      % alpha level of the permutation test
cfg.numrandomization = 5000;        % number of draws from the permutation distribution
cfg.uvar             = 1;
cfg.ivar             = 2;

% Statistical pairwise comparisons

% --- 2W vs 6M
cfg.design = design1; 
% Run the stats
[stat_ITPC_FC_2W_vs_6M]   = ft_freqstatistics(cfg, BEEP_ITPC_FC2_N, BEEP_ITPC_FC1_N);

% Plot t-values
figure; plotTFR_clusters(stat_ITPC_FC_2W_vs_6M,stat_ITPC_FC_2W_vs_6M.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], '2W vs 6M T-values', 'ClusterStats', stat_ITPC_FC_2W_vs_6M, 'ClusterType', 'both' ); 
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% --- 2W vs 12M
cfg.design = design2;
% Run the stats
[stat_ITPC_FC_2W_vs_12M]   = ft_freqstatistics(cfg, BEEP_ITPC_FC3_O, BEEP_ITPC_FC1_O);

% Plot t-values
figure;plotTFR_clusters(stat_ITPC_FC_2W_vs_12M,stat_ITPC_FC_2W_vs_12M.stat,-0.2, 1.5, 0.5, 30,-4 ,4, [],'2W vs 12M T-values', 'ClusterStats', stat_ITPC_FC_2W_vs_12M, 'ClusterType', 'both' ); set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% --- 6M vs 12M
cfg.design = design3;
% Run the stats
[stat_ITPC_FC_6M_vs_12M]   = ft_freqstatistics(cfg, BEEP_ITPC_FC3_P, BEEP_ITPC_FC2_P);
% Plot t-values
figure;plotTFR_clusters(stat_ITPC_FC_6M_vs_12M,stat_ITPC_FC_6M_vs_12M.stat, -0.2, 1.5, 0.5, 30,-4 ,4, [], '6M vs 12M T-values', 'ClusterStats', stat_ITPC_FC_6M_vs_12M, 'ClusterType', 'both' ); set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%