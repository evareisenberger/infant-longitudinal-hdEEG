function EEGc = perform_epoch_rej(EEG)
    % This function performs epoch rejection on the input EEG dataset.
    % Input:
    %   EEG - EEG dataset structure (e.g., from EEGlab)
    % Output:
    %   EEG_T - EEG dataset after epoch rejection

    % Perform automatic rejection of epochs
    [EEGc, rmepochs] = pop_autorej(EEG,'threshold',1000, 'startprob',10,'maxrej',10,'nogui', 'on');

    % Calculate epoch properties
    epoch_props = epoch_properties(EEGc, 1:EEGc.nbchan);

    % Determine bad epochs using min_z function
    BadEpochs = min_z(epoch_props);

    % Reject the bad epochs
    EEGc = pop_rejepoch(EEGc, BadEpochs, 0);

    % Display a message indicating completion
    disp('Epoch rejection complete.');

end

