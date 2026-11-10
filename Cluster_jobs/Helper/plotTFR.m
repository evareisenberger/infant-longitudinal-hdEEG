function plotTFR(ft_struc, tfr_vec, xstart, xend, ystart, yend, cmin, cmax, cm, Ptitle)
    % plotTimeFrequency - Plots time-frequency decomposition results
    %
    % Syntax:  plotTimeFrequency(NStim_all, NDum_all, statsN, outputFileName)
    %
    % Inputs:
    %    NStim_all - Structure containing the stimulus data
    %    NDum_all - Structure containing the dummy data
    %    statsN - Structure containing the stats information
    %    outputFileName - Name of the output file for saving the figure (optional)
    %
    % Example: 
    %    plotTimeFrequency(NStim_all, NDum_all, statsN, 'output.pdf')

    %% Add necessary paths
    addpath(genpath('/home/b1044271/EEGsleep/Codes'));

    %% Prepare data structure for plotting
    temp = ft_struc;
    
    %%  The vector to plot (has to be 3d with subj X ch X time) - ch has to be a single channel or an average
    temp.powspctrm = tfr_vec;

    meanpow = double(squeeze(temp.powspctrm));

    %% Interpolate for plotting
    tim_interp = linspace(temp.time(1), temp.time(end), 10000);
    freq_interp = linspace(0.5, 40, 100);

    % Create time/frequency grids
    [tim_grid_orig, freq_grid_orig] = meshgrid(temp.time, temp.freq);
    [tim_grid_interp, freq_grid_interp] = meshgrid(tim_interp, freq_interp);
    
    
        meanpow(isnan(meanpow)) = 0;


    % Interpolate power
    pow_interp = interp2(tim_grid_orig, freq_grid_orig, meanpow, tim_grid_interp, freq_grid_interp, 'spline');

    %% Plotting
    imagesc(tim_interp, freq_interp, pow_interp);
    axis xy;
    xlabel('time (s)', 'FontSize', 22);
    ylabel('frequency (Hz)', 'FontSize', 22);
    
        %% Determine colorbar limits
    if nargin < 7 || isempty(cmin)
        cmin = min(meanpow(:)) ;
    end
    if nargin < 8 || isempty(cmax)
        cmax = max(meanpow(:));
    end
    
    caxis([cmin cmax]);
    
    if cm
    colormap(cm);
    else
        colormap(brewermap(256, '*RdYlBu'));
    end

    % Colorbar
    h = colorbar();
    h.LineWidth = 1.5;
    
    ylim([ystart yend]);
    xlim([xstart xend]);
    
    set(gca, 'FontSize', 18, 'TickLength', [0.01 0.01], 'XGrid', 'off', 'YGrid', 'off', 'XColor', [0 0 0], 'YColor', [0 0 0], 'LineWidth', 2); 
    hold on; line([0 0], [0 40], 'color', 'k', 'LineStyle', '--', 'LineWidth', 2);

    % Add line at t = 0s
    hold on;
    plot(zeros(size(freq_interp)), freq_interp, '--k', 'LineWidth', 2);
    
    title(Ptitle, 'FontSize', 22);
    ylabel(h, 'uv2', 'FontSize', 22);


end