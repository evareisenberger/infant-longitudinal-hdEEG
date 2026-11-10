%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  Paths and setup

clear;

% Add paths
addpath(genpath('/xxx/Helper')) % Add path to costumn helper script
Baby_baby_paths; % Costumn script that sets up all project-specific paths and folders

addpath('/xxx/DrosteEffect-BrewerMap-5b84f95'); % Add path to helper package needed for visualization

%% --- Paths to data ---

path_ERP1 = 'xxx';
path_ERP2 = 'xxx';
path_ERP3 = 'xxx';

%%  ERP ANALYSIS
%  =======================

%% --- Load filenames and exclude participants ---

% 2W
ERPbeep_FC1 = dir(fullfile(path_ERP1, '*FC*beep*.mat'));
ERPbeep_FC1n = {ERPbeep_FC1(:).name};
ERPbeep_FC1n([2,3,4,10,12,15,16,17,18,21,25,30]) = []; % Exclude participants (indices)

%6M
ERPbeep_FC2 = dir(fullfile(path_ERP2, '*FC*beep*.mat'));
ERPbeep_FC2n = {ERPbeep_FC2(:).name};
ERPbeep_FC2n([1,25,29,43,52,59,60,62,67]) = []; % Exclude participants (indices)

% 12M
ERPbeep_FC3 = dir(fullfile(path_ERP3, '*FC*beep*.mat'));
ERPbeep_FC3n = {ERPbeep_FC3(:).name};
ERPbeep_FC3n([3, 22, 29, 38, 39, 40, 45, 51, 54, 58, 59, 61]) = []; % Exclude participants (indices)

%% --- Load files ---

% 2W
for i = 1:length(ERPbeep_FC1n)
    load([path_ERP1 ERPbeep_FC1n{i}]); % Load each participant's file for the stimulation condition
    ERPstim_FC1{i} = Beep_ERP_fc; % Store in cell array
end

% 6M
for i = 1:length(ERPbeep_FC2n)
    load([path_ERP2 ERPbeep_FC2n{i}]);
    ERPstim_FC2{i} = Beep_ERP_fc;
end

% 12M
for i = 1:length(ERPbeep_FC3n)
    load([path_ERP3 ERPbeep_FC3n{i}]);
    ERPstim_FC3{i} = Beep_ERP_fc;
end

%% --- Matching subjects across age groups --- 

%Extract participant IDs from characters 4 to 8 for 2W/ 6M and 5:9 for 12M
getIDs = @(names) cellfun(@(x) x(4:8), names, 'UniformOutput', false);
getIDs_12M = @(names) cellfun(@(x) x(5:9), names, 'UniformOutput', false);

IDs_2W = getIDs(ERPbeep_FC1n);
IDs_6M = getIDs(ERPbeep_FC2n);
IDs_12M = getIDs_12M(ERPbeep_FC3n);

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

%% --- Grand averages across matched subjects ---

cfg_g=[]; cfg_g.keepindividual = 'yes';

% 2W
ERPstim_FC1N = ERPstim_FC1(idx_2W_matched_6M);
ERPstim_FC2N = ERPstim_FC2(idx_6M_matched_2W);

BEEP_all_FC1_N = ft_timelockgrandaverage(cfg_g, ERPstim_FC1N{:});
BEEP_all_FC2_N = ft_timelockgrandaverage(cfg_g, ERPstim_FC2N{:});

% 6M
ERPstim_FC1O = ERPstim_FC1(idx_2W_matched_12M);
ERPstim_FC3O = ERPstim_FC3(idx_12M_matched_2W);

BEEP_all_FC1_O = ft_timelockgrandaverage(cfg_g, ERPstim_FC1O{:});
BEEP_all_FC3_O = ft_timelockgrandaverage(cfg_g, ERPstim_FC3O{:});

% 12M
ERPstim_FC2P = ERPstim_FC2(idx_6M_matched_12M);
ERPstim_FC3P = ERPstim_FC3(idx_12M_matched_6M);

BEEP_all_FC2_P = ft_timelockgrandaverage(cfg_g, ERPstim_FC2P{:});
BEEP_all_FC3_P = ft_timelockgrandaverage(cfg_g, ERPstim_FC3P{:});

%% --- Saving group level .mat files to plot ERPs in R ---

savepath = 'xxx'; % Define path where to save the data

% Averaging the indiviudal ERP data (stimulation condition) across the second dimension and reshape output by removing singleton dimensions using squeeze
ERP_2W_vs_6M = squeeze(mean(BEEP_all_FC1_N.individual,2));
ERP_6M_vs_2W = squeeze(mean(BEEP_all_FC2_N.individual,2));

ERP_2W_vs_12M = squeeze(mean(BEEP_all_FC1_O.individual,2));
ERP_12M_vs_2W = squeeze(mean(BEEP_all_FC3_O.individual,2));

ERP_6M_vs_12M = squeeze(mean(BEEP_all_FC2_P.individual,2));
ERP_12M_vs_6M = squeeze(mean(BEEP_all_FC3_P.individual,2));

ERP_long_time = BEEP_all_FC1_N.time; % Extract time vector

% Save .mat files
save([savepath 'ERP_Long_2W_vs_6M.mat'],'ERP_2W_vs_6M')
save([savepath 'ERP_Long_6M_vs_2W.mat']   ,'ERP_6M_vs_2W')

save([savepath 'ERP_Long_2W_vs_12M.mat'],'ERP_2W_vs_12M')
save([savepath 'ERP_Long_12M_vs_2W.mat']   ,'ERP_12M_vs_2W')

save([savepath 'ERP_Long_6M_vs_12M.mat'],'ERP_6M_vs_12M')
save([savepath 'ERP_Long_12M_vs_6M.mat']   ,'ERP_12M_vs_6M')

save([savepath 'ERP_Long_time.mat'],['ERP_long_time'])

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

% Statistical pairwise comparisons

% --- 2W vs 6M

subj = size(BEEP_all_FC1_N.individual,1);

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
[stat_ERP_FC_2W_vs_6M] = ft_timelockstatistics(cfg, BEEP_all_FC2_N , BEEP_all_FC1_N );

% --- 2W vs 12M

subj = size(BEEP_all_FC1_O.individual,1);

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
[stat_ERP_FC_2W_vs_12M] = ft_timelockstatistics(cfg, BEEP_all_FC3_O, BEEP_all_FC1_O);

% --- 6M vs 12M 

subj = size(BEEP_all_FC2_P.individual,1);

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
[stat_ERP_FC_6M_vs_12M] = ft_timelockstatistics(cfg, BEEP_all_FC3_P, BEEP_all_FC2_P);

%% --- Plotting ---

% Define colors
color_2W = [1 0 0];   % Red
color_6M = [0 0 1];   % Blue
color_12M = [0 1 0];  % Green

% Shared time vector
X = BEEP_all_FC1_N.time(:); 

% Means and SEMs for each pairwise comparison
% --- 2W vs 6M

ERPm_2W_N = mean(squeeze(mean(BEEP_all_FC1_N.individual,2)));
ERPs_2W_N = std(squeeze(mean(BEEP_all_FC1_N.individual,2)))./ sqrt(size(BEEP_all_FC1_N.individual,1));
ERPm_6M_N = mean(squeeze(mean(BEEP_all_FC2_N.individual,2)));
ERPs_6M_N = std(squeeze(mean(BEEP_all_FC2_N.individual,2)))./ sqrt(size(BEEP_all_FC2_N.individual,1));

% --- 2W vs 12M
ERPm_2W_O = mean(squeeze(mean(BEEP_all_FC1_O.individual,2)));
ERPs_2W_O = std(squeeze(mean(BEEP_all_FC1_O.individual,2)))./ sqrt(size(BEEP_all_FC1_O.individual,1));
ERPm_12M_O = mean(squeeze(mean(BEEP_all_FC3_O.individual,2)));
ERPs_12M_O = std(squeeze(mean(BEEP_all_FC3_O.individual,2)))./ sqrt(size(BEEP_all_FC3_O.individual,1));

% --- 6M vs 12M
ERPm_6M_P = mean(squeeze(mean(BEEP_all_FC2_P.individual,2)));
ERPs_6M_P = std(squeeze(mean(BEEP_all_FC2_P.individual,2)))./ sqrt(size(BEEP_all_FC2_P.individual,1));
ERPm_12M_P = mean(squeeze(mean(BEEP_all_FC3_P.individual,2)));
ERPs_12M_P = std(squeeze(mean(BEEP_all_FC3_P.individual,2)))./ sqrt(size(BEEP_all_FC3_P.individual,1));

figure;

% --- 2W vs 6M
subplot(1,3,1);
hold on;
bl1 = boundedline(X, ERPm_2W_N, ERPs_2W_N, 'cmap', color_2W, 'transparency', 0.2);
bl2 = boundedline(X, ERPm_6M_N, ERPs_6M_N, 'cmap', color_6M, 'transparency', 0.2);
set([bl1, bl2], 'LineWidth', 2);
line([0 0], ylim, 'color', 'k', 'LineStyle', '--');
title('2W vs 6M');
xlim([-0.2 1.5]);
ylim([-5 5]);
xlabel('Time [s]');
ylabel('Amplitude [\muV]');
legend([bl1, bl2], {'2W', '6M'}, 'Location', 'best');
grid on;

% --- 2W vs 12M
subplot(1,3,2);
hold on;
bl3 = boundedline(X, ERPm_2W_O, ERPs_2W_O, 'cmap', color_2W, 'transparency', 0.2);
bl4 = boundedline(X, ERPm_12M_O, ERPs_12M_O, 'cmap', color_12M, 'transparency', 0.2);
set([bl3, bl4], 'LineWidth', 2);
line([0 0], ylim, 'color', 'k', 'LineStyle', '--');
title('2W vs 12M');
xlim([-0.2 1.5]);
ylim([-5 5]);
xlabel('Time [s]');
ylabel('Amplitude [\muV]');
legend([bl3, bl4], {'2W', '12M'}, 'Location', 'best');
grid on;

% --- 6M vs 12M
subplot(1,3,3);
hold on;
bl5 = boundedline(X, ERPm_6M_P, ERPs_6M_P, 'cmap', color_6M, 'transparency', 0.2);
bl6 = boundedline(X, ERPm_12M_P, ERPs_12M_P, 'cmap', color_12M, 'transparency', 0.2);
set([bl5, bl6], 'LineWidth', 2);
line([0 0], ylim, 'color', 'k', 'LineStyle', '--');
title('6M vs 12M');
xlim([-0.2 1.5]);
ylim([-5 5]);
xlabel('Time [s]');
ylabel('Amplitude [\muV]');
legend([bl5, bl6], {'6M', '12M'}, 'Location', 'best');
grid on;

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%