%% This function is referred to in c_Baby_ERP_final

function [Beep_TF, Base_TF, Beep_i, Base_i, TFtrials ] = Baby_TFsteps(data, timepoint)  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  TF steps

 % Extract all event types from EEG structure
 stims = {data.event(:).type};

 % Identify all events that contain letter C (these are the beep markers)
 beep_mark = stims(cellfun(@(x) contains(x, 'C'), stims));
 
 % Epoch EEG data around each beep marker (-4 to 4 seconds)
 Epoch_beep2 = pop_epoch(data,beep_mark, [-4 4]);

 % Get the total number of trials
 TFtrials(1,1)=  length(Epoch_beep2.epoch);

% Reject epochs
 Epoch_beep2 = perform_epoch_rej(Epoch_beep2);

% Get the number of trials used
TFtrials(1,2)=  length(Epoch_beep2.epoch); % Number of trials used

% Get the number of rejected trials
TFtrials(1,3)=  TFtrials(1,1) - length(Epoch_beep2.epoch); % Number of rejected trials

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
        Epoch_base  = pop_epoch(data,b_init, [8 28]); % Create one big epoch (8-28s)
        Epoch_base2 = eeg_regepochs(Epoch_base, 'recurrence', 0.2, 'limits', [-4 4], 'eventtype', '1'); % Segment the big epoch into smaller segments of equal length every 0.2s
    elseif strcmp(timepoint, '2WA')
        Epoch_base2  = pop_epoch(data, {'bl'}, [-4 4]);
   else
        Epoch_base  = pop_epoch(data,b_init, [10 170]); % Create one big baseline epoch (10-170s)
        Epoch_base2 = eeg_regepochs(Epoch_base, 'recurrence', 1, 'limits', [-4 4], 'eventtype', '1'); % Segment the big epoch into smaller segments of equal length every 1s
    end

    % Remove baddies
    Epoch_base2 = perform_epoch_rej(Epoch_base2);

    
    %% --- Equalize number of trials ---

    % Find minimum number of epochs between stimulation and no-stimulation condition
    min_TF = min([length(Epoch_base2.epoch) length(Epoch_beep2.epoch)]);
    
    % Select random trials
    Base_epoched2a = pop_select(Epoch_base2, 'trial', datasample(1:length(Epoch_base2.epoch), min_TF, 'Replace', false));
    Beep_epoched2a = pop_select(Epoch_beep2, 'trial', datasample(1:length(Epoch_beep2.epoch), min_TF, 'Replace', false));

    % Convert to fieldtrip
    Beep_epochedTF= eeglab2fieldtrip(Beep_epoched2a, 'preprocessing', 'none');
    Base_epochedTF= eeglab2fieldtrip(Base_epoched2a, 'preprocessing', 'none');

    %% --- Perform TFR analysis ---

    cfg_f=[];
    cfg_f.method    = 'mtmconvol';
    cfg_f.output    = 'pow';
    cfg_f.toi       = -4: 0.05: 4;
    cfg_f.foi       = 0.5:0.5:30;
    cfg_f.taper     = 'hanning';
    cfg_f.t_ftimwin = ones(length(cfg_f.foi),1)*0.5;
    cfg_f.pad       =  'nextpow2';

    Beep_TF =      ft_freqanalysis (cfg_f, Beep_epochedTF);
    Base_TF =      ft_freqanalysis (cfg_f, Base_epochedTF);

    % Baseline correction
    cfg_b=[];
    cfg_b.baseline=[-0.2 0]; % Set baseline period (pre-stimulus)
    cfg_b.baselinetype = 'relchange'; % Baseline type: relative change
    Beep_TF =      ft_freqbaseline (cfg_b, Beep_TF);
    Base_TF =      ft_freqbaseline (cfg_b, Base_TF);

    % Optional: Channel selection  
    % cfg_fc=[]; cfg_fc.channel = FCchannel;
    % Beep_TF_fc = ft_selectdata(cfg_fc, Beep_TF);
    % Base_TF_fc = ft_selectdata(cfg_fc, Base_TF);
    % 
    % cfg_t=[]; cfg_t.channel = Tchannel;
    % Beep_TF_t = ft_selectdata(cfg_t, Beep_TF);
    % Base_TF_t = ft_selectdata(cfg_t, Base_TF);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  ITPC steps

  % Get fourier spectrum info first by running freqanalysis
  cfg_c=[];
  cfg_c.method    = 'mtmconvol';
  cfg_c.output    = 'fourier';
  cfg_c.toi       = -4: 0.05: 4;
  cfg_c.foi       = 0.5:0.5:30;
  cfg_c.taper     = 'hanning';
  cfg_c.t_ftimwin = ones(length(cfg_f.foi),1)*0.5;
  cfg_c.pad       =  'nextpow2';

  % Fourier spectra for stimulation and no-stimulation condition
  B_ITPC  = ft_freqanalysis(cfg_c,Beep_epochedTF);
  B2_ITPC = ft_freqanalysis(cfg_c,Base_epochedTF);

  % Extract the Fourier spectrum
  F_Beep  = B_ITPC.fourierspctrm;     
  F_Base  = B2_ITPC.fourierspctrm;
  
  % Get the number of trials
  N = size(F_Beep,1);
    
 %% --- Compute ITPC (stimulation condition) ---

    % Make a new FieldTrip-style data structure containing the ITPC
    % Copy the descriptive fields over from the frequency decomposition
    itc_B           = [];
    itc_B.label     = B_ITPC.label;
    itc_B.freq      = B_ITPC.freq;
    itc_B.time      = B_ITPC.time;
    itc_B.dimord    = 'chan_freq_time';

    % Compute inter-trial phase coherence (itpc)
    itc_B.itpc      = F_Beep./abs(F_Beep); % Divide by amplitude
    itc_B.itpc      = sum(itc_B.itpc,1);   % Sum phase angles
    itc_B.itpc      = abs(itc_B.itpc)/N;   % Take the absolute value and normalize
    itc_B.itpc      = squeeze(itc_B.itpc); % Remove the first singleton dimension

    % Store ITPC for the stimulation condition
    Beep_ITPC = itc_B;
    Beep_i = itc_B;

     %% --- Compute ITPC (no-stimulation condition) ---

    itc_B2           = [];
    itc_B2.label     = B2_ITPC.label;
    itc_B2.freq      = B2_ITPC.freq;
    itc_B2.time      = B2_ITPC.time;
    itc_B2.dimord    = 'chan_freq_time';

    % Compute inter-trial phase coherence (itpc)
    itc_B2.itpc      = F_Base./abs(F_Base);  % Divide by amplitude
    itc_B2.itpc      = sum(itc_B2.itpc,1);   % Sum phase angles
    itc_B2.itpc      = abs(itc_B2.itpc)/N;   % Take the absolute value and normalize
    itc_B2.itpc      = squeeze(itc_B2.itpc); % Remove the first singleton dimension

    % Store ITPC for the no-stimulation condition
    Base_ITPC = itc_B2;
    Base_i = itc_B2;

    %% Final steps
   
    % Apply baseline correction for ITPC (stimulation and no-stimulation condition)
    cfg_bi=[];cfg_bi.baseline = [-0.2 0];cfg_bi.parameter='itpc';
    Beep_i =      ft_freqbaseline (cfg_bi, Beep_ITPC);
    Base_i =      ft_freqbaseline (cfg_bi, Base_ITPC);

  % Optional: Channel selection  
    % cfg_fc=[]; cfg_fc.channel = FCchannel;
    % Beep_i_fc = ft_selectdata(cfg_fc, Beep_ITPC);
    % Base_i_fc = ft_selectdata(cfg_fc, Base_ITPC);
    % 
    % cfg_t=[]; cfg_t.channel = Tchannel;
    % Beep_i_t = ft_selectdata(cfg_t, Beep_ITPC);
    % Base_i_t = ft_selectdata(cfg_t, Base_ITPC);

    %% Catch any errors that occur 
    catch

        % If an error occurs, set output to empty (to avoid crashes)
        Beep_TF = [];
        Base_TF = [];
        TFtrials   = [];
        Beep_i = [];
        Base_i = [];

    end

end

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%