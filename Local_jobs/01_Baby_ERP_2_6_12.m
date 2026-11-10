%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  Paths and setup

clear;

% Add paths
addpath(genpath('xxx/Helper')) % Add path to costumn helper folder
Baby_baby_paths; % Costumn script that sets up all project-specific paths and folders

addpath('/xxx/Helper/DrosteEffect-BrewerMap-5b84f95'); % Add path to helper package needed for visualization

%% --- Paths to data ---

path_ERP1 = 'xxx';
path_ERP2 = 'xxx';
path_ERP3 = 'xxx';

%%  ERP ANALYSIS
%  =======================

%% --- Load filenames and exclude participants ---

% 2W
% Load filenames for stimulation condition
ERPbeep_FC1 = dir(fullfile(path_ERP1, '*FC*beep*.mat'));
ERPbeep_FC1n = {ERPbeep_FC1(:).name};
ERPbeep_FC1n([1,4,5,6,13,17,18,21,22,23,24,28,29,30,31,34,36,39,40,41,42,49,57,59,61])= []; %Exclude participants (indices)

% Load filenames for no-stimulation condition
ERPbase_FC1 = dir(fullfile(path_ERP1, '*FC*base*.mat'));
ERPbase_FC1n = {ERPbase_FC1(:).name};
ERPbase_FC1n([1,4,5,6,13,17,18,21,22,23,24,28,29,30,31,34,36,39,40,41,42,49,57,59,61])= []; %Exclude participants (indices)

% 6M
ERPbeep_FC2 = dir(fullfile(path_ERP2, '*FC*beep*.mat'));
ERPbeep_FC2n = {ERPbeep_FC2(:).name};
ERPbeep_FC2n([1,25,29,43,52,59,60,62,67]) =[]; % Exclude participants (indices) 

ERPbase_FC2 = dir(fullfile(path_ERP2, '*FC*base*.mat'));
ERPbase_FC2n = {ERPbase_FC2(:).name};
ERPbase_FC2n([1,25,29,43,52,59,60,62,67]) =[]; % Exclude participants (indices)

%12M
ERPbeep_FC3 = dir(fullfile(path_ERP3, '*FC*beep*.mat'));
ERPbeep_FC3n = {ERPbeep_FC3(:).name};
ERPbeep_FC3n([3, 22, 29, 38, 39, 40, 45, 51, 54, 58, 59, 61]) =[]; % Exclude participants (indices)

ERPbase_FC3 = dir(fullfile(path_ERP3, '*FC*base*.mat'));
ERPbase_FC3n = {ERPbase_FC3(:).name};
ERPbase_FC3n([3, 22, 29, 38, 39, 40, 45, 51, 54, 58, 59, 61]) =[]; % Exclude participants (indices) 

%% --- Load files ---

cfg=[];

%2W
for i = 1:length(ERPbeep_FC1n)
    load([path_ERP1 ERPbeep_FC1n{i}]); % Load each participant's file for the stimulation condition
    Beep_ERP_fc =  ft_timelockanalysis(cfg, Beep_ERP_fc); % Compute average ERP
    ERPstim_FC1{i} = Beep_ERP_fc; % Store in cell array
end

for i = 1:length(ERPbase_FC1n)
    load([path_ERP1 ERPbase_FC1n{i}]); % Load each participant's file for the no-stimulation condition
    Base_ERP_fc =  ft_timelockanalysis(cfg, Base_ERP_fc);% Compute average ERP
    ERPbl_FC1{i} = Base_ERP_fc; % Store in cell array
end

%6M
for i = 1:length(ERPbeep_FC2n)
    load([path_ERP2 ERPbeep_FC2n{i}]);
    Beep_ERP_fc =  ft_timelockanalysis(cfg, Beep_ERP_fc);
    ERPstim_FC2{i} = Beep_ERP_fc;
end

for i = 1:length(ERPbase_FC2n)
    load([path_ERP2 ERPbase_FC2n{i}]);
    Base_ERP_fc =  ft_timelockanalysis(cfg, Base_ERP_fc);
    ERPbl_FC2{i} = Base_ERP_fc;
end

% 12M
for i = 1:length(ERPbeep_FC3n)
    load([path_ERP3 ERPbeep_FC3n{i}]);
    Beep_ERP_fc =  ft_timelockanalysis(cfg, Beep_ERP_fc);
    ERPstim_FC3{i} = Beep_ERP_fc;
end

for i = 1:length(ERPbase_FC3n)
    load([path_ERP3 ERPbase_FC3n{i}]);
    Base_ERP_fc =  ft_timelockanalysis(cfg, Base_ERP_fc);
    ERPbl_FC3{i} = Base_ERP_fc;
end

%% --- Single subject plots ---

% 2W
figure;
for p = 1:size(ERPstim_FC1,2)
    subplot(7,10,p);
    plot(ERPstim_FC1{1}.time, mean(ERPstim_FC1{p}.avg) , 'r')
    hold on; plot(ERPbl_FC1{1}.time, mean(ERPbl_FC1{p}.avg) , 'b')
end

% 6M
figure;
for p = 1:size(ERPstim_FC2,2)
    subplot(7,10,p);
    plot(ERPstim_FC2{1}.time, mean(ERPstim_FC2{p}.avg) , 'r')
    hold on; plot(ERPbl_FC2{1}.time, mean(ERPbl_FC2{p}.avg) , 'b')
end

%12M
figure;
for p = 1:size(ERPstim_FC3,2)
    subplot(7,10,p);
    plot(ERPstim_FC3{1}.time, mean(ERPstim_FC3{p}.avg) , 'r')
        hold on; plot(ERPbl_FC3{1}.time, mean(ERPbl_FC3{p}.avg) , 'b')
end

%% --- Grand averages across participants ---

cfg_g=[];
cfg_g.keepindividual = 'yes';

% Compute grand averages for all participants at each developmental stage
% Stimulation condition
BEEP_all_FC2 = ft_timelockgrandaverage(cfg_g, ERPstim_FC2{:});
BEEP_all_FC3 = ft_timelockgrandaverage(cfg_g, ERPstim_FC3{:});
BEEP_all_FC1 = ft_timelockgrandaverage(cfg_g, ERPstim_FC1{:});
% No-stimulation condition
BASE_all_FC2 = ft_timelockgrandaverage(cfg_g, ERPbl_FC2{:});
BASE_all_FC3 = ft_timelockgrandaverage(cfg_g, ERPbl_FC3{:});
BASE_all_FC1 = ft_timelockgrandaverage(cfg_g, ERPbl_FC1{:});

%% --- Saving group level .mat files to plot ERPs in R ---

savepath = ['xxx']; % Define path where to save the data

% Averaging the indiviudal ERP data (stimulation condition) across the second dimension and reshape output by removing singleton dimensions using squeeze
ERP_2Wall = squeeze(mean(BEEP_all_FC1.individual,2));
ERP_6M = squeeze(mean(BEEP_all_FC2.individual,2));
ERP_12M = squeeze(mean(BEEP_all_FC3.individual,2));

% Averaging the indiviudal data (no-stimulation condition) across the second dimension and reshape output by removing singleton dimensions using squeeze
BL_2Wall = squeeze(mean(BASE_all_FC1.individual,2));
BL_6M = squeeze(mean(BASE_all_FC2.individual,2));
BL_12M = squeeze(mean(BASE_all_FC3.individual,2));

ERP_time = BASE_all_FC3.time; % Extract time vector

% Save .mat files
save([savepath 'ERP_2Wall.mat'],'ERP_2Wall')
save([savepath 'ERP_6Mall.mat']   ,'ERP_6M')
save([savepath 'ERP_12Mall.mat']  ,'ERP_12M')

save([savepath 'BL_2Wall.mat'],'BL_2Wall')
save([savepath 'BL_6Mall.mat'],'BL_6M')
save([savepath 'BL_12Mall.mat'],'BL_12M')

save([savepath 'ERP_time.mat'],'ERP_time')

%% --- Plotting ---

% Colors: red = stimulation condition, blue = no-stimulation condition
colors = [1 0 0 ; 0 0 1];

% 2W
figure; subplot(1,3,1); 
[h1, h2] = boundedline( ...
    BEEP_all_FC1.time, mean(squeeze(mean(BEEP_all_FC1.individual,2))), std(squeeze(mean(BEEP_all_FC1.individual,2)))./sqrt(size(BEEP_all_FC1.individual,1)),...
    BASE_all_FC1.time, mean(squeeze(mean(BASE_all_FC1.individual,2))), std(squeeze(mean(BASE_all_FC1.individual,2)))./sqrt(size(BASE_all_FC1.individual,1)), 'cmap', colors, 'transparency', 0.2);
     xlim ([-0.2 1.5]); line([0 0], [-2.5 3], 'Linewidth', 3); ylim([-2.5, 3]);
     xlabel('Time [s]');
     ylabel('Amplitude [\muV]');
     legend([h1(1), h1(2)], {'ERP', 'Baseline'});

% 6M
subplot(1,3,2); 
[h3, h4] = boundedline( ...
    BEEP_all_FC2.time, mean(squeeze(mean(BEEP_all_FC2.individual,2))), std(squeeze(mean(BEEP_all_FC2.individual,2)))./sqrt(size(BEEP_all_FC2.individual,1)),...
    BASE_all_FC2.time, mean(squeeze(mean(BASE_all_FC2.individual,2))), std(squeeze(mean(BASE_all_FC2.individual,2)))./sqrt(size(BASE_all_FC2.individual,1)), 'cmap', colors, 'transparency', 0.2);
    xlim ([-0.2 1.5]), line([0 0], [-2.5 3], 'Linewidth', 3); ylim([-2.5, 3]);
    xlabel('Time [s]');
    ylabel('Amplitude [\muV]');
    legend([h3(1), h3(2)], {'ERP', 'Baseline'});

% 12M
subplot(1,3,3); 
[h5, h6] = boundedline( ...
    BEEP_all_FC3.time, mean(squeeze(mean(BEEP_all_FC3.individual,2))), std(squeeze(mean(BEEP_all_FC3.individual,2)))./sqrt(size(BEEP_all_FC3.individual,1)),...
    BASE_all_FC3.time, mean(squeeze(mean(BASE_all_FC3.individual,2))), std(squeeze(mean(BASE_all_FC3.individual,2)))./sqrt(size(BASE_all_FC3.individual,1)), 'cmap', colors, 'transparency', 0.2);
    xlim ([-0.2 1.5]); line([0 0], [-2.5 3], 'Linewidth', 3); ylim([-2.5, 3]);
    xlabel('Time [s]');
    ylabel('Amplitude [\muV]');
    legend([h5(1), h5(2)], {'ERP', 'Baseline'});


%% --- ERP Stats ---

cfg = [];
cfg.statistic       = 'ft_statfun_depsamplesT'; % Between groups independent samples statistics
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

% 2W
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
[stat_ERP_2W] = ft_timelockstatistics(cfg, BEEP_all_FC1, BASE_all_FC1);

% 6M
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
[stat_ERP_6M] = ft_timelockstatistics(cfg, BEEP_all_FC2, BASE_all_FC2);

% 12M
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
[stat_ERP_12M] = ft_timelockstatistics(cfg, BEEP_all_FC3, BASE_all_FC3);

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%