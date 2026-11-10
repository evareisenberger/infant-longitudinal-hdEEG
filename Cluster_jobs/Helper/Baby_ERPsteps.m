%% This function is referred to in c_Baby_ERP_final

function [Beep_ERP, Base_ERP, ERPtrials] = Baby_ERPsteps(data, timepoint)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  ERP steps

% Extract all event types from EEG structure
 stims = {data.event(:).type};

% Identify all events that contain letter C (these are the beep markers)
beep_mark = stims(cellfun(@(x) contains(x, 'C'), stims));
        
        % If no beep markers are found, display a message and exit function
        if isempty(beep_mark)
            sprintf('no beeps were found')
            return
        end

% Epoch EEG data around each beep marker (-0.2 to 1.5 seconds)
Epoch_beep = pop_epoch(data,beep_mark, [-0.2 1.5]);

% Get the total number of trials
ERPtrials(1,1)=  length(Epoch_beep.epoch);

% Reject epochs
Epoch_beep = perform_epoch_rej(Epoch_beep);

% Get the number of trials used
ERPtrials(1,2)=  length(Epoch_beep.epoch);

% Get the number of rejected trials
ERPtrials(1,3)=  ERPtrials(1,1) - length(Epoch_beep.epoch);

%% --- No-stimulation (baseline) condition ---

% Define marker for the beginning of the no-stimulation period
b_init = 'VBeg';

% Find indices of all baseline start markers in events list
bn = find(contains(stims, b_init));

% If there are multiple markers, remove the first one
if length(bn) > 1
   data.event(bn(1)) =[];
end
        
%% Try/ catch prevents the script from breaking if an error occurs
   try
        
       % Depending on the measurement time point, epoch differently
        if strcmp(timepoint, '2W')
        Epoch_base      =  pop_epoch(data,b_init, [8 28]); % Create one big epoch (8-28s)
        Base_epoched_o  =  eeg_regepochs(Epoch_base, 'recurrence', 0.2, 'limits', [-0.2 1.5], 'eventtype', '1'); % Segment the big epoch into smaller segments of equal length every 0.2s
        elseif strcmp(timepoint, '2WA')
        Base_epoched_o  = pop_epoch(data, {'bl'}, [-0.2 1.5]); % Directly epoch around bl events
        else
        Epoch_base      =  pop_epoch(data,b_init, [10 170]); % Create one big epoch (10-170s)
        Base_epoched_o  =  eeg_regepochs(Epoch_base, 'recurrence', 1, 'limits', [-0.2 1.5], 'eventtype', '1'); % Segment the big epoch into smaller segments of equal length every 1s
        end

  % Remove badies
  Base_epoched_o  =  perform_epoch_rej(Base_epoched_o);

    %% --- Equalize number of trials --- 

    % Find minimum number of epochs between stimulation and no-stimulation condition
    min_ERP = min([length(Base_epoched_o.epoch) length(Epoch_beep.epoch)]);
        
    % Select random trials to equalize trial counts
        Base_epoched2 = pop_select(Base_epoched_o, 'trial', datasample(1:length(Base_epoched_o.epoch), min_ERP, 'Replace', false));
        Beep_epoched2 = pop_select(Epoch_beep, 'trial', datasample(1:length(Epoch_beep.epoch), min_ERP, 'Replace', false));

    % Convert to fieldtrip
        Beeps_epoched = eeglab2fieldtrip(Beep_epoched2, 'preprocessing', 'none');
        Base_epoched  = eeglab2fieldtrip(Base_epoched2, 'preprocessing', 'none');
    
  %% --- Perform timelock analysis on the epoched data --- 
    cfg=[]; 
    % cfg.demean = 'yes'; % Baseline type: mean %comment out for no baseline correction
    % cfg.baselinewindow = [-0.2 0]; 
    Beep_ERP = ft_timelockanalysis(cfg, Beeps_epoched); 
    Base_ERP = ft_timelockanalysis(cfg, Base_epoched);
    
    % Apply baseline correction to the timelocked data
    cfg_b=[];
    cfg_b.baseline=[-0.2 0]; % Set baseline period (pre-stimulus)
    cfg_b.baselinetype = 'relchange'; % Baseline type: relative change
        Beep_ERP =  ft_timelockbaseline (cfg_b, Beep_ERP);
        Base_ERP =  ft_timelockbaseline (cfg_b, Base_ERP);
    
    % Optional: Channel selection  
    % cfg_fc=[]; cfg_fc.channel = FCchannel;
    %     Beep_ERP_fc = ft_selectdata(cfg_fc, Beep_ERP);
    %     Base_ERP_fc = ft_selectdata(cfg_fc, Base_ERP);
    % 
    % cfg_t=[]; cfg_t.channel = Tchannel;
    %      Beep_ERP_t = ft_selectdata(cfg_t, Beep_ERP);
    %      Base_ERP_t = ft_selectdata(cfg_t, Base_ERP);

   %% Catch any errors that occur      
   catch

       % If an error occurs, set output to empty (to avoid crashes)
        Beep_ERP = [];
        Base_ERP = [];
        ERPtrials   = [];
        
        end

end

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%