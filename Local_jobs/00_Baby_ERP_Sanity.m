%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  Paths and setup

% clear; % Uncomment if you want to clear your workspace before

% Add paths
addpath('xxx') % Add path to costumn helper script
Baby_baby_paths % Costumn script that sets up all project-specific paths and folders
addpath('xxx/Cluster_jobs')

% Choose subject
VP = 'xxx'; % Change accordingly

%% --- Paths to Data (Preprocessed Final) ---

path2W = 'xxx';
path6M =  'xxx';
path12M = 'xxx';

%%  Single Subject Analysis
%  =======================

% Load files
EEG_2W = pop_loadset([path2W VP '_2W_ICAdone.set']); % 2W
EEG_6M = pop_loadset([path6M VP '_6M_ICAdone.set']); % 6M
EEG_12M = pop_loadset([path12M VP '_12M_ICAdone.set']); % 12M

% Apply bandpass filter (keep frequenciesbetween 0.5 and 45 Hz)
EEG_2W = pop_eegfiltnew(EEG_2W, [0.5, 45]);
EEG_6M = pop_eegfiltnew(EEG_6M, [0.5, 45]);
EEG_12M = pop_eegfiltnew(EEG_12M, [0.5, 45]);

% Resample to decrease computation time 
EEG_2W = pop_resample(EEG_2W, 125);
EEG_6M = pop_resample(EEG_6M, 125);
EEG_12M = pop_resample(EEG_12M, 125);

% Stims - Extract the 'type' field from each event from the event structure of the EEG data (stored in a cell array)
stims_2W = {EEG_2W.event(:).type}; 
stims_6M = {EEG_6M.event(:).type}; 
stims_12M = {EEG_12M.event(:).type};

% Select only "beep" events (marked with 'C' in the event labels)
beeps_2W = stims_2W(cellfun(@(x) contains(x, 'C'), stims_2W));
beeps_6M = stims_6M(cellfun(@(x) contains(x, 'C'), stims_6M));
beeps_12M = stims_12M(cellfun(@(x) contains(x, 'C'), stims_12M));

% Epoch the EEG data around each beep marker (segments from -3 to 3 seconds relative to each beep tone)
Epoch_2W = pop_epoch(EEG_2W,beeps_2W, [-3 3]); Epoch_2W = perform_epoch_rej(Epoch_2W) ;
Epoch_6M = pop_epoch(EEG_6M,beeps_6M, [-3 3]);
Epoch_12M = pop_epoch(EEG_12M,beeps_12M, [-3 3]);

%% --- ERPs ---

% Convert data to FieldTrip format for further ERP processing
Epoch_2W2 = eeglab2fieldtrip(Epoch_2W, 'preprocessing', 'none');
Epoch_6M2 = eeglab2fieldtrip(Epoch_6M, 'preprocessing', 'none');
Epoch_12M2 = eeglab2fieldtrip(Epoch_12M, 'preprocessing', 'none');

% Define channels of interest
cfg=[];
cfg.channel = {'E24', 'E124', 'E11','E36', 'E104', 'E129'}; % fronto-central F3=24, F4=124, Fz=11, C3=36, C4=104, Cz=129
% cfg.channel = {'E45', 'E39', 'E50', 'E108', 'E115', 'E101'}; %temporal
 % cfg.demean = 'yes'; cfg.baselinewindow = [-0.2 0];

% Grand average
ERP2W  = ft_timelockanalysis(cfg, Epoch_2W2);   
ERP6M  = ft_timelockanalysis(cfg, Epoch_6M2);   
ERP12M = ft_timelockanalysis(cfg, Epoch_12M2);   

%% --- Plotting ---

% 2W
figure; subplot(1,3,1);
b1 = plot(ERP2W.time, mean(ERP2W.avg)); 
ylim([-4, 4]); xlim([-3 3]); 
line([0 0], [-4 4], 'color','r','Linewidth', 1);
line([-1.5 -1.5], [-4 4], 'color','r','Linewidth', 1);
line([1.5 1.5], [-4 4], 'color','r','Linewidth', 1);
set(b1,'LineStyle','-','LineWidth',3, 'color', 'b') % Adjusting the ERP trace
hXLabel = xlabel('\fontsize{26} Time (s)');
hYLabel = ylabel('\fontsize{26} Amplitude (uv)');
set(gca,'FontName','sans serif','FontSize',16);
haxes1 = gca; % Handle to axes
haxes1_pos = get(haxes1,'Position'); % Store position of first axes
set(gca,'Box','off','TickLength',[.0 .0],'XGrid','off','YGrid','off', 'XColor',[0 0 0],'YColor',[0 0 0],'LineWidth',2.5, 'FontSize', 20);
set([ hXLabel, hYLabel],'FontName','sans serif','FontSize',24);
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]); % squared

% 6M
subplot(1,3,2);
b2 = plot(ERP2W.time, mean(ERP6M.avg)); 
ylim([-4, 4]); xlim([-3, 3]); 
line([0 0], [-4 4], 'color','r','Linewidth', 1);
line([-1.5 -1.5], [-4 4],'color','r', 'Linewidth', 1)
line([1.5 1.5], [-4 4], 'color','r','Linewidth', 1);
set(b2,'LineStyle','-','LineWidth',3, 'color', 'r')
hXLabel = xlabel('\fontsize{26} Time (s)');
set(gca,'FontName','sans serif','FontSize',16);
haxes1 = gca;
haxes1_pos = get(haxes1,'Position');
set(gca,'Box','off','TickLength',[.0 .0],'XGrid','off','YGrid','off', 'XColor',[0 0 0],'YColor',[0 0 0],'LineWidth',2.5, 'FontSize', 20);
set([ hXLabel, hYLabel],'FontName','sans serif','FontSize',24);
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

% 12M
subplot(1,3,3); 
b3 = plot(ERP12M.time, mean(ERP12M.avg)); 
ylim([-4, 4]); xlim([-3, 3]); 
line([0 0], [-4 4], 'color','r','Linewidth', 1);
line([-1.5 -1.5], [-4 4], 'color','r','Linewidth', 1);
line([1.5 1.5], [-4 4], 'color','r','Linewidth', 1);
set(b3,'LineStyle','-','LineWidth',3, 'color', 'g')
hXLabel = xlabel('\fontsize{26} Time (s)');
set(gca,'FontName','sans serif','FontSize',16);
haxes1 = gca; 
haxes1_pos = get(haxes1,'Position');
set(gca,'Box','off','TickLength',[.0 .0],'XGrid','off','YGrid','off', 'XColor',[0 0 0],'YColor',[0 0 0],'LineWidth',2.5, 'FontSize', 20);
set([ hXLabel, hYLabel],'FontName','sans serif','FontSize',24);
set(gcf, 'Units', 'pixels', 'Position', [100,100,600,600]);
pbaspect([1 1 1]);

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%