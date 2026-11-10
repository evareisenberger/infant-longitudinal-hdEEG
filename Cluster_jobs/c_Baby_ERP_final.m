
%% This function runs on the server and organizes and formats data into .mat files for later ERP, TF and ITPC analyses.

function c_Baby_ERP_final(prepro_files, timepoint)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =======================
%  Paths and setup

% FieldTrip
addpath('xxx') % Change accordingly
% Initialize FieldTrip default settings
obob_init_ft;

% EEGLab
addpath(genpath('xxx')); % Change accordingly
% Start EEGLab without the graphical interface
eeglab nogui

% Add path to Helper
addpath('xxx') % Add path to costumn helper script
Baby_baby_paths % Costumn script that sets up all project-specific paths and folders

% Add path to SleepStages
path_sleepstaging = 'xxx'; % Change accordingly
% Stage_0 = WAKE, Stage_1 = REM, Stage_2 = Transitional, Stage_3 = NREM

rng(0)

%% --- Define output paths ---

path_ERP  = 'xxx'; % Change accordingly
path_TF   = 'xxx'; % Change accordingly
path_ITPC = 'xxx'; % Change accordingly
path_tr  = 'xxx'; % Change accordingly

% Check if directories exist
if ~exist(path_ERP, 'dir')
        mkdir(path_ERP)
end

if ~exist(path_TF, 'dir')
        mkdir(path_TF)
end

if ~exist(path_ITPC, 'dir')
        mkdir(path_ITPC)
end

if ~exist(path_tr, 'dir')
        mkdir(path_tr)
end

%% Data prep for ERP, TF and ITPC
%  =======================

%% Define stims for baseline

baseline_stims = {'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8'};

%% Choose channels

FCchannel = {'E24', 'E124', 'E11','E36', 'E104', 'E129'}; % fronto-central F3=24, F4=124, Fz=11, C3=36, C4=104, Cz=129
Tchannel = {'E45', 'E39', 'E50', 'E108', 'E115', 'E101'}; % temporal T7/3=45 and T8/4=108 plus the one in front and behind it

%% --- Load current file ---
    
    if strcmp(timepoint, '2W') || strcmp(timepoint, '2WA') 
        EEG = pop_loadset(strcat(ica_folder_2W, prepro_files));
    elseif strcmp(timepoint, '6M')
        EEG = pop_loadset(strcat(ica_folder_6M, prepro_files));
    else
        EEG = pop_loadset(strcat(ica_folder_12M, prepro_files));
    end

    % Add high pass filter
    EEG = pop_eegfiltnew(EEG, 0.5,[]);
    
    % Get subject ID
    subj_id = EEG.filename(1:5);

    %% --- 2W files (require different processing) ---
    
    if strcmp(timepoint, '2W')

        VPn=str2double(EEG.filename(4:5)); % Extract the subject ID from the filename
    
        % Construct the name of the corresponding sleep staging text file
        % If subject number > 10, add a 0 in front
        if VPn < 10
            VP_SS = sprintf('VP0%d_stages.txt', VPn);
        else
            VP_SS = sprintf('VP%d_stages.txt', VPn);
        end
    
        % Combine directory path and filename to gett full path of sleep staging file
        SS = [path_sleepstaging VP_SS];

        % Import sleep stage events (e.g. stage_0, stage_1 etc.)
        eventstruct = importevent(SS, EEG.event, EEG.srate, 'fields',{'type','latency'}, 'timeunit', NaN);
       
        EEG.event = eventstruct;

        % Ensure event consistency (standard EEGlab check)
        eeg_checkset(EEG, 'eventconsistency');

        % Resample to 125 Hz to decrease computation time 
        EEG = pop_resample(EEG, 125);

        % Extract event types and latencies for later use
        events={EEG.event.type};
        stimes = {EEG.event(:).latency};

        % Find no-stimulation (baseline) condition stimulus events (all that have B)
        base = find(contains(events, baseline_stims)); 

        % Get the first baseline stimulus and its latency
        b_init = events(base(1));
        b_time = cell2mat(stimes(base(1)));

        % Insert dummy markers ('bl') to create evenyl spaced artifical events
        x = length(EEG.event);
        epochs = 120; % We would add 90 events

        for ie = 1:epochs-1
            EEG.event(1,x+ie).type = 'bl';
            EEG.event(1,x+ie).latency = b_time + ie * 125;
            EEG.event(1,x+ie).urevent = 4;
        end

        % Re-check event consistency after adding dummy markers
        eeg_checkset(EEG, 'eventconsistency');

        %% --- 2W WAKE
        % The try and catch prevents from throwing an error if there are no epochs

        try

        % Create epochs from -29.9 to 0s
        EEG_W = pop_epoch(EEG, {'stage_0'}, [-29.9 0]);

        % Select channels of interest
        EEG_W_FC = pop_select(EEG_W , 'channel', FCchannel);
        EEG_W_T = pop_select(EEG_W , 'channel', Tchannel);

        % --- Perform epcoching and run ERP analysis
        [Beep_ERP_fc, Base_ERP_fc, ERPtrials] = Baby_ERPsteps(EEG_W_FC, timepoint);
        [Beep_ERP_t, Base_ERP_t, ERPtrials] = Baby_ERPsteps(EEG_W_T, timepoint);

        % Save if not empty
        if ~isempty(Beep_ERP_fc) || ~isempty(Base_ERP_fc) 
            save([path_ERP, timepoint, '/Wake/', timepoint, '_', subj_id ,'_FC', '_Wake', '_ERPbeep.mat'] , 'Beep_ERP_fc');
            save([path_ERP, timepoint, '/Wake/', timepoint, '_', subj_id ,'_FC', '_Wake','_ERPbase.mat'] , 'Base_ERP_fc');
            save([path_ERP, timepoint, '/Wake/', timepoint, '_', subj_id ,'_T', '_Wake','_ERPbeep.mat'] , 'Beep_ERP_t');
            save([path_ERP, timepoint, '/Wake/', timepoint, '_', subj_id ,'_T', '_Wake','_ERPbase.mat'] , 'Base_ERP_t');
            save([path_tr, subj_id ,'_ERPtrials_' timepoint , '_W.mat'] , 'ERPtrials');
        end

        % --- Perform TF and ITPC analyses
        [Beep_TF_fc, Base_TF_fc, Beep_i_fc,Base_i_fc, TFtrials] = Baby_TFsteps(EEG_W_FC, timepoint);
        [Beep_TF_t, Base_TF_t, Beep_i_t,Base_i_t, TFtrials] = Baby_TFsteps(EEG_W_FC, timepoint);

        % Save if not empty
        if ~isempty(Beep_TF_fc) || ~isempty(Base_TF_fc) 
        save([path_TF, timepoint, '/Wake/', timepoint, '_', subj_id ,'_FC', '_Wake', '_TFbeep.mat'] , 'Beep_TF_fc');
        save([path_TF, timepoint, '/Wake/', timepoint, '_', subj_id ,'_FC', '_Wake', '_TFbase.mat'] , 'Base_TF_fc');
        save([path_TF, timepoint, '/Wake/', timepoint, '_', subj_id ,'_T', '_Wake', '_TFbeep.mat'] , 'Beep_TF_t');
        save([path_TF, timepoint, '/Wake/', timepoint, '_', subj_id ,'_T', '_Wake', '_TFPbase.mat'] , 'Base_TF_t');
        
        save([path_tr, subj_id ,'_TFtrials_' timepoint , '_W.mat'] , 'TFtrials');       
        
        save([path_ITPC, timepoint, '/Wake/', timepoint, '_', subj_id ,'_FC', '_Wake', '_ITPCbeep.mat'] , 'Beep_i_fc');
        save([path_ITPC, timepoint, '/Wake/', timepoint, '_', subj_id ,'_FC', '_Wake', '_ITPCbase.mat'] , 'Base_i_fc');
        save([path_ITPC, timepoint, '/Wake/', timepoint, '_', subj_id ,'_T', '_Wake','_ITPCbeep.mat'] , 'Beep_i_t');
        save([path_ITPC, timepoint, '/Wake/', timepoint, '_', subj_id ,'_T', '_Wake', '_ITPCPbase.mat'] , 'Base_i_t');
        end

        catch
        EEG_W=[];
        end

        %% --- 2W REM
        
        try
        EEG_R = pop_epoch(EEG, {'stage_1'}, [-29.9 0]);   

        EEG_R_FC = pop_select(EEG_R , 'channel', FCchannel);
        EEG_R_T = pop_select(EEG_R , 'channel', Tchannel);

        % --- Perform epcoching and run ERP analysis
        [Beep_ERP_fc, Base_ERP_fc, ERPtrials] = Baby_ERPsteps(EEG_R_FC, timepoint);
        [Beep_ERP_t, Base_ERP_t, ERPtrials] = Baby_ERPsteps(EEG_R_T, timepoint);

        % Save if not empty
        if ~isempty(Beep_ERP_fc)  || ~isempty(Base_ERP_fc) 
        save([path_ERP, timepoint, '/REM/', timepoint, '_', subj_id ,'_FC', '_REM', '_ERPbeep.mat'] , 'Beep_ERP_fc');
        save([path_ERP, timepoint, '/REM/', timepoint, '_', subj_id ,'_FC', '_REM','_ERPbase.mat'] , 'Base_ERP_fc');
        save([path_ERP, timepoint, '/REM/', timepoint, '_', subj_id ,'_T', '_REM', '_ERPbeep.mat'] , 'Beep_ERP_t');
        save([path_ERP, timepoint, '/REM/', timepoint, '_', subj_id ,'_T', '_REM', '_ERPbase.mat'] , 'Base_ERP_t');
        save([path_tr, subj_id ,'_ERPtrials_' timepoint , '_R.mat'] , 'ERPtrials');
        end

        % --- Perform TF and ITPC analyses
        [Beep_TF_fc, Base_TF_fc, Beep_i_fc , Base_i_fc ,  TFtrials] = Baby_TFsteps(EEG_R_FC, timepoint);
        [Beep_TF_t, Base_TF_t, Beep_i_t , Base_i_t ,  TFtrials] = Baby_TFsteps(EEG_R_T, timepoint);

        % Save if not empty
        if ~isempty(Beep_TF_fc) || ~isempty(Base_TF_fc) 
        save([path_TF, timepoint, '/REM/', timepoint, '_', subj_id ,'_FC', '_REM', '_TFbeep.mat'] , 'Beep_TF_fc');
        save([path_TF, timepoint, '/REM/', timepoint, '_', subj_id ,'_FC', '_REM', '_TFbase.mat'] , 'Base_TF_fc');
        save([path_TF, timepoint, '/REM/', timepoint, '_', subj_id ,'_T', '_REM', '_TFbeep.mat'] , 'Beep_TF_t');
        save([path_TF, timepoint, '/REM/', timepoint, '_', subj_id ,'_T', '_REM', '_TFbase.mat'] , 'Base_TF_t');
        
        save([path_tr, subj_id ,'_TFtrials_' timepoint , '_R.mat'] , 'TFtrials');   
        
        save([path_ITPC, timepoint, '/REM/', timepoint, '_', subj_id ,'_FC', '_REM', '_ITPCbeep.mat'] , 'Beep_i_fc');
        save([path_ITPC, timepoint, '/REM/', timepoint, '_', subj_id ,'_FC', '_REM', '_ITPCbase.mat'] , 'Base_i_fc');
        save([path_ITPC, timepoint, '/REM/', timepoint, '_', subj_id ,'_T', '_REM', '_ITPCbeep.mat'] , 'Beep_i_t');
        save([path_ITPC, timepoint, '/REM/', timepoint, '_', subj_id ,'_T', '_REM', '_ITPCPbase.mat'] , 'Base_i_t');
        end

        catch
        EEG_R=[];
        end

        %% --- 2W NREM
        
        try
        EEG_N = pop_epoch(EEG, {'stage_3'}, [-29.9 0]);

        EEG_N_FC = pop_select(EEG_N , 'channel', FCchannel);
        EEG_N_T = pop_select(EEG_N , 'channel', Tchannel);

        % --- Perform epcoching and run ERP analysis
        [Beep_ERP_fc, Base_ERP_fc, ERPtrials] = Baby_ERPsteps(EEG_N_FC, timepoint);
        [Beep_ERP_t, Base_ERP_t, ERPtrials] = Baby_ERPsteps(EEG_N_T, timepoint);

        % Save if not empty
        if ~isempty(Beep_ERP_fc) || ~isempty(Base_ERP_fc) 
        save([path_ERP, timepoint, '/NREM/', timepoint, '_', subj_id ,'_FC', '_NREM', '_ERPbeep.mat'] , 'Beep_ERP_fc');
        save([path_ERP, timepoint, '/NREM/', timepoint, '_', subj_id ,'_FC', '_NREM', '_ERPbase.mat'] , 'Base_ERP_fc');
        save([path_ERP, timepoint, '/NREM/', timepoint, '_', subj_id ,'_T', '_NREM', '_ERPbeep.mat'] , 'Beep_ERP_t');
        save([path_ERP, timepoint, '/NREM/', timepoint, '_', subj_id ,'_T', '_NREM', '_ERPbase.mat'] , 'Base_ERP_t');
        save([path_tr, subj_id ,'_ERPtrials_' timepoint , '_N.mat'] , 'ERPtrials');
        end
           
        % --- Perform TF and ITPC analyses
        [Beep_TF_fc, Base_TF_fc, Beep_i_fc , Base_i_fc ,  TFtrials] = Baby_TFsteps(EEG_N_FC, timepoint);
        [Beep_TF_t, Base_TF_t, Beep_i_t , Base_i_t ,  TFtrials] = Baby_TFsteps(EEG_N_T, timepoint);

        % Save if not empty
        if ~isempty(Beep_TF_fc) || ~isempty(Base_TF_fc) 
        save([path_TF, timepoint, '/NREM/', timepoint, '_', subj_id ,'_FC', '_NREM', '_TFbeep.mat'] , 'Beep_TF_fc');
        save([path_TF, timepoint, '/NREM/', timepoint, '_', subj_id ,'_FC', '_NREM', '_TFbase.mat'] , 'Base_TF_fc');
        save([path_TF, timepoint, '/NREM/', timepoint, '_', subj_id ,'_T', '_NREM', '_TFbeep.mat'] , 'Beep_TF_t');
        save([path_TF, timepoint, '/NREM/', timepoint, '_', subj_id ,'_T', '_NREM', '_TFbase.mat'] , 'Base_TF_t');
       
        save([path_tr, subj_id ,'_TFtrials_' timepoint , '_N.mat'] , 'TFtrials');   

        save([path_ITPC, timepoint, '/NREM/', timepoint, '_', subj_id ,'_FC', '_NREM', '_ITPCbeep.mat'] , 'Beep_i_fc');
        save([path_ITPC, timepoint, '/NREM/', timepoint, '_', subj_id ,'_FC', '_NREM', '_ITPCbase.mat'] , 'Base_i_fc');
        save([path_ITPC, timepoint, '/NREM/', timepoint, '_', subj_id ,'_T', '_NREM', '_ITPCbeep.mat'] , 'Beep_i_t');
        save([path_ITPC, timepoint, '/NREM/', timepoint, '_', subj_id ,'_T', '_NREM', '_ITPCPbase.mat'] , 'Base_i_t');
        end

        catch
        EEG_N=[];
        end

        %% --- 2W TRANSITIONAL
        
        try
        EEG_T = pop_epoch(EEG, {'stage_2'}, [-29.9 0]);

        EEG_T_FC = pop_select(EEG_T , 'channel', FCchannel);
        EEG_T_T = pop_select(EEG_T , 'channel', Tchannel);

        % --- Perform epcoching and run ERP analysis
        [Beep_ERP_fc, Base_ERP_fc, ERPtrials] = Baby_ERPsteps(EEG_T_FC, timepoint);
        [Beep_ERP_t, Base_ERP_t, ERPtrials] = Baby_ERPsteps(EEG_T_T, timepoint);

        % Save if not empty
        if ~isempty(Beep_ERP_fc) || ~isempty(Base_ERP_fc) 
        save([path_ERP, timepoint, '/Transitional/', timepoint, '_', subj_id ,'_FC', '_Trans', '_ERPbeep.mat'] , 'Beep_ERP_fc');
        save([path_ERP, timepoint, '/Transitional/', timepoint, '_', subj_id ,'_FC', '_Trans', '_ERPbase.mat'] , 'Base_ERP_fc');
        save([path_ERP, timepoint, '/Transitional/', timepoint, '_', subj_id ,'_T', '_Trans', '_ERPbeep.mat'] , 'Beep_ERP_t');
        save([path_ERP, timepoint, '/Transitional/', timepoint, '_', subj_id ,'_T', '_Trans', '_ERPbase.mat'] , 'Base_ERP_t');
        save([path_tr, subj_id ,'_ERPtrials_' timepoint , '_T.mat'] , 'ERPtrials');
        end

        % --- Perform TF and ITPC analyses
        [Beep_TF_fc, Base_TF_fc, Beep_i_fc , Base_i_fc ,  TFtrials] = Baby_TFsteps(EEG_T_FC, timepoint);
        [Beep_TF_t, Base_TF_t, Beep_i_t , Base_i_t ,  TFtrials] = Baby_TFsteps(EEG_T_T, timepoint);
    
        % Save if not empty
        if ~isempty(Beep_TF_fc) || ~isempty(Base_TF_fc) 
        save([path_TF, timepoint, '/Transitional/', timepoint, '_', subj_id ,'_FC', '_Trans', '_TFbeep.mat'] , 'Beep_TF_fc');
        save([path_TF, timepoint, '/Transitional/', timepoint, '_', subj_id ,'_FC', '_Trans', '_TFbase.mat'] , 'Base_TF_fc');
        save([path_TF, timepoint, '/Transitional/', timepoint, '_', subj_id ,'_T', '_Trans', '_TFbeep.mat'] , 'Beep_TF_t');
        save([path_TF, timepoint, '/Transitional/', timepoint, '_', subj_id ,'_T', '_Trans', '_TFbase.mat'] , 'Base_TF_t');
       
        save([path_tr, subj_id ,'_TFtrials_' timepoint , '_T.mat'] , 'TFtrials');   
        
        save([path_ITPC, timepoint, '/Transitional/', timepoint, '_', subj_id ,'_FC', '_Trans', '_ITPCbeep.mat'] , 'Beep_i_fc');        
        save([path_ITPC, timepoint, '/Transitional/', timepoint, '_', subj_id ,'_FC', '_Trans', '_ITPCbase.mat'] , 'Base_i_fc');
        save([path_ITPC, timepoint, '/Transitional/', timepoint, '_', subj_id ,'_T', '_Trans', '_ITPCbeep.mat'] , 'Beep_i_t');
        save([path_ITPC, timepoint, '/Transitional/', timepoint, '_', subj_id ,'_T', '_Trans', '_ITPCPbase.mat'] , 'Base_i_t');
        end

        catch
        EEG_T=[];
        end

        %% --- 2W WAKE+TRANSITIONAL
        
        try
        EEG_WT = pop_epoch(EEG, {'stage_2', 'stage_0'}, [-29.9 0]);

        EEG_WT_FC = pop_select(EEG_WT , 'channel', FCchannel);
        EEG_WT_T = pop_select(EEG_WT , 'channel', Tchannel);

        % --- Perform epcoching and run ERP analysis
        [Beep_ERP_fc, Base_ERP_fc, ERPtrials] = Baby_ERPsteps(EEG_WT_FC, timepoint);
        [Beep_ERP_t, Base_ERP_t, ERPtrials] = Baby_ERPsteps(EEG_WT_T, timepoint);

        % Save if not empty
        if ~isempty(Beep_ERP_fc) || ~isempty(Base_ERP_fc) 
        save([path_ERP, timepoint, '/WT/', timepoint, '_', subj_id ,'_FC', '_WT', '_ERPbeep.mat'] , 'Beep_ERP_fc');
        save([path_ERP, timepoint, '/WT/', timepoint, '_', subj_id ,'_FC', '_WT', '_ERPbase.mat'] , 'Base_ERP_fc');
        save([path_ERP, timepoint, '/WT/', timepoint, '_', subj_id ,'_T', '_WT', '_ERPbeep.mat'] , 'Beep_ERP_t');
        save([path_ERP, timepoint, '/WT/', timepoint, '_', subj_id ,'_T', '_WT', '_ERPbase.mat'] , 'Base_ERP_t');
        save([path_tr, subj_id ,'_ERPtrials_'  ,timepoint, '_WT.mat'] , 'ERPtrials');
        end

        % --- Perform TF and ITPC analyses
        [Beep_TF_fc, Base_TF_fc, Beep_i_fc , Base_i_fc ,  TFtrials] = Baby_TFsteps(EEG_WT_FC, timepoint);
        [Beep_TF_t, Base_TF_t, Beep_i_t , Base_i_t ,  TFtrials] = Baby_TFsteps(EEG_WT_T, timepoint);
    
        % Save if not empty
        if ~isempty(Beep_TF_fc) || ~isempty(Base_TF_fc) 
        save([path_TF, timepoint, '/WT/', timepoint, '_', subj_id ,'_FC', '_WT', '_TFbeep.mat'] , 'Beep_TF_fc');
        save([path_TF, timepoint, '/WT/', timepoint, '_', subj_id ,'_FC', '_WT', '_TFbase.mat'] , 'Base_TF_fc');
        save([path_TF, timepoint, '/WT/', timepoint, '_', subj_id ,'_T', '_WT', '_TFbeep.mat'] , 'Beep_TF_t');
        save([path_TF, timepoint, '/WT/', timepoint, '_', subj_id ,'_T', '_WT', '_TFbase.mat'] , 'Base_TF_t');
        save([path_tr, subj_id ,'_TFtrials_' timepoint , '_WT.mat'] , 'TFtrials');   
        
        save([path_ITPC, timepoint, '/WT/', timepoint, '_', subj_id ,'_FC', '_WT', '_ITPCbeep.mat'] , 'Beep_i_fc');        
        save([path_ITPC, timepoint, '/WT/', timepoint, '_', subj_id ,'_FC', '_WT', '_ITPCbase.mat'] , 'Base_i_fc');
        save([path_ITPC, timepoint, '/WT/', timepoint, '_', subj_id ,'_T', '_WT', '_ITPCbeep.mat'] , 'Beep_i_t');
        save([path_ITPC, timepoint, '/WT/', timepoint, '_', subj_id ,'_T', '_WT', '_ITPCPbase.mat'] , 'Base_i_t');
        end

        catch
        EEG_WT=[];
        end

 %% --- 6M & 12M ---
    
    else

    % Resample to 125 Hz to decrease computation time
    EEG = pop_resample(EEG, 125);

    % Create dummy baseline markers (as above)
    events={EEG.event.type};
    stimes = {EEG.event(:).latency};
    base = find(contains(events, baseline_stims));
    b_init = events(base(1));
    b_time = cell2mat(stimes(base(1)));

    x = length(EEG.event);
    epochs = 120;

    for ie = 1:epochs-1
        EEG.event(1,x+ie).type = 'bl';
        EEG.event(1,x+ie).latency = b_time + ie * 125;
        EEG.event(1,x+ie).urevent = 4;
    end

    eeg_checkset(EEG, 'eventconsistency');
    
    % Select channels
    EEG_FC = pop_select(EEG, 'channel', FCchannel);
    EEG_T = pop_select(EEG , 'channel', Tchannel);
    
    % --- Perform epcoching and run ERP analysis
    [Beep_ERP_fc, Base_ERP_fc,  ERPtrials] = Baby_ERPsteps(EEG_FC, timepoint);
    [Beep_ERP_t, Base_ERP_t, ERPtrials] = Baby_ERPsteps(EEG_T, timepoint);

    % Save if not empty
    if ~isempty(Beep_ERP_fc) 
        save([path_ERP, timepoint,  '_', subj_id ,'_FC', '_ERPbeep.mat'] , 'Beep_ERP_fc');
        save([path_ERP, timepoint,  '_', subj_id ,'_FC', '_ERPbase.mat'] , 'Base_ERP_fc');
        save([path_ERP, timepoint,  '_', subj_id ,'_T', '_ERPbeep.mat'] , 'Beep_ERP_t');
        save([path_ERP, timepoint,  '_', subj_id ,'_T', '_ERPbase.mat'] , 'Base_ERP_t');
        save([path_tr, subj_id ,'_ERPtrials_' ,timepoint, '.mat'] , 'ERPtrials');
    end

    % --- Perform TF and ITPC analyses
    [Beep_TF_fc, Base_TF_fc, Beep_i_fc , Base_i_fc ,  TFtrials] = Baby_TFsteps(EEG_FC, timepoint);
    [Beep_TF_t, Base_TF_t, Beep_i_t , Base_i_t ,  TFtrials] = Baby_TFsteps(EEG_T, timepoint);
    
    % Save if not empty
    if ~isempty(Beep_TF_fc) 
        save([path_TF, timepoint, '_', subj_id ,'_FC', '_TFbeep.mat'] , 'Beep_TF_fc');
        save([path_TF, timepoint, '_', subj_id ,'_FC', '_TFbase.mat'] , 'Base_TF_fc');
        save([path_TF, timepoint, '_', subj_id ,'_T', '_TFbeep.mat'] , 'Beep_TF_t');
        save([path_TF, timepoint, '_', subj_id ,'_T', '_TFbase.mat'] , 'Base_TF_t');
        
        save([path_tr, subj_id ,'_TFtrials_' timepoint , '.mat'] , 'TFtrials');  

        save([path_ITPC, timepoint, '_', subj_id ,'_FC', '_ITPCbeep.mat'] , 'Beep_i_fc');        
        save([path_ITPC, timepoint, '_', subj_id ,'_FC', '_ITPCbase.mat'] , 'Base_i_fc');
        save([path_ITPC, timepoint, '_', subj_id ,'_T', '_ITPCbeep.mat'] , 'Beep_i_t');
        save([path_ITPC, timepoint,  '_', subj_id ,'_T', '_ITPCPbase.mat'] , 'Base_i_t');
    end
    end

end

%% =======================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%