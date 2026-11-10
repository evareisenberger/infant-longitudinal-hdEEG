function plotTFR(ft_struc, tfr_vec, xstart, xend, ystart, yend, cmin, cmax, cm, Ptitle, varargin)
    % plotTFR - Plots time-frequency decomposition results with optional cluster marking
    %
    % Syntax:  plotTFR(ft_struc, tfr_vec, xstart, xend, ystart, yend, cmin, cmax, cm, Ptitle, cluster_stats)
    %
    % Inputs:
    %    ft_struc - FieldTrip time-frequency structure
    %    tfr_vec - Vector to plot (3D with subj ? ch ? time)
    %    xstart, xend - X-axis limits
    %    ystart, yend - Y-axis limits
    %    cmin, cmax - Color axis limits (optional)
    %    cm - Colormap (optional)
    %    Ptitle - Plot title
    %    cluster_stats - FieldTrip cluster statistics structure (optional)
    %
    % Optional Name-Value Pairs:
    %    'ClusterStats' - FieldTrip cluster statistics structure
    %    'ClusterType' - 'positive', 'negative', or 'both' (default)
    %    'ClusterColor' - Color for cluster contours (default: 'k')
    %    'ClusterLineWidth' - Line width for contours (default: 2)
    %
    
% Example: 
%  plotTFR_clusters(stat_e, stat_e.stat, -0.2, 1, 1, 30, -4 ,4, [], 'Power', 'ClusterStats', stat_e, 'ClusterType', 'both');


    %% Add necessary paths
    addpath(genpath('/home/b1044271/EEGsleep/Codes'));

    %% Parse optional cluster parameters
    p = inputParser;
    addParameter(p, 'ClusterStats', [], @isstruct);
    addParameter(p, 'ClusterType', 'both', @(x) ismember(x, {'positive', 'negative', 'both'}));
    addParameter(p, 'ClusterColor', 'k', @(x) ischar(x) || (isnumeric(x) && numel(x)==3));
    addParameter(p, 'ClusterLineWidth', 2, @isnumeric);
    parse(p, varargin{:});
    
    cluster_stats = p.Results.ClusterStats;
    cluster_type = p.Results.ClusterType;
    cluster_color = p.Results.ClusterColor;
    cluster_linewidth = p.Results.ClusterLineWidth;

    %% Prepare data structure for plotting
    temp = ft_struc;
    temp.powspctrm = tfr_vec;
    meanpow = double(squeeze(temp.powspctrm));
    meanpow(isnan(meanpow)) = 0;

    %% Interpolate for plotting
    tim_interp = linspace(temp.time(1), temp.time(end), 10000);
    freq_interp = linspace(0.5, 40, 100);

    % Create time/frequency grids
    [tim_grid_orig, freq_grid_orig] = meshgrid(temp.time, temp.freq);
    [tim_grid_interp, freq_grid_interp] = meshgrid(tim_interp, freq_interp);

    % Interpolate power
    pow_interp = interp2(tim_grid_orig, freq_grid_orig, meanpow, tim_grid_interp, freq_grid_interp, 'spline');

    %% Plotting
    imagesc(tim_interp, freq_interp, pow_interp);
    axis xy;
    xlabel('time (s)', 'FontSize', 22);
    ylabel('frequency (Hz)', 'FontSize', 22);
    
    %% Determine colorbar limits
    if nargin < 7 || isempty(cmin)
        cmin = min(meanpow(:));
    end
    if nargin < 8 || isempty(cmax)
        cmax = max(meanpow(:));
    end
    caxis([cmin cmax]);
    
    if nargin >= 9 && ~isempty(cm)
        colormap(cm);
    else
        colormap(brewermap(256, '*RdYlBu'));
    end

    % Colorbar
    h = colorbar();
    h.LineWidth = 1.5;
    
    ylim([ystart yend]);
    xlim([xstart xend]);
    
    set(gca, 'FontSize', 18, 'TickLength', [0.01 0.01], 'XGrid', 'off', 'YGrid', 'off', ...
             'XColor', [0 0 0], 'YColor', [0 0 0], 'LineWidth', 2); 
    
    % Add line at t = 0s
    hold on;
    plot(zeros(size(freq_interp)), freq_interp, '--k', 'LineWidth', 2);
    
    title(Ptitle, 'FontSize', 22);
    ylabel(h, 'uv2', 'FontSize', 22);

    %% Add cluster contours if provided
    if ~isempty(cluster_stats)
        % Set default cluster alpha if not specified
        addParameter(p, 'ClusterAlpha', 0.025, @isnumeric);
        parse(p, varargin{:});
        cluster_alpha = p.Results.ClusterAlpha;
        
        % For positive clusters
        if strcmpi(cluster_type, 'positive') || strcmpi(cluster_type, 'both')
            if isfield(cluster_stats, 'posclusters') && ~isempty(cluster_stats.posclusters)
                % Create significant positive cluster mask
                pos_mask = false(size(cluster_stats.stat));
                for i = 1:length(cluster_stats.posclusters)
                    if cluster_stats.posclusters(i).prob < cluster_alpha
                        pos_mask(cluster_stats.posclusterslabelmat == i) = true;
                    end
                end
                
                % Average across channels if needed
                if ndims(pos_mask) == 3
                    pos_mask = squeeze(mean(pos_mask, 1));
                end
                
                % Interpolate and plot
                pos_mask_interp = interp2(tim_grid_orig, freq_grid_orig, ...
                                       double(pos_mask), ...
                                       tim_grid_interp, freq_grid_interp, 'nearest');
                contour(tim_interp, freq_interp, pos_mask_interp, 1, 'linecolor', cluster_color, ...
                       'LineWidth', cluster_linewidth);
            end
        end
        
        % For negative clusters
        if strcmpi(cluster_type, 'negative') || strcmpi(cluster_type, 'both')
            if isfield(cluster_stats, 'negclusters') && ~isempty(cluster_stats.negclusters)
                % Create significant negative cluster mask
                neg_mask = false(size(cluster_stats.stat));
                for i = 1:length(cluster_stats.negclusters)
                    if cluster_stats.negclusters(i).prob < cluster_alpha
                        neg_mask(cluster_stats.negclusterslabelmat == i) = true;
                    end
                end
                
                % Average across channels if needed
                if ndims(neg_mask) == 3
                    neg_mask = squeeze(mean(neg_mask, 1));
                end
                
                % Interpolate and plot
                neg_mask_interp = interp2(tim_grid_orig, freq_grid_orig, ...
                                       double(neg_mask), ...
                                       tim_grid_interp, freq_grid_interp, 'nearest');
                contour(tim_interp, freq_interp, neg_mask_interp, 1, 'linecolor', cluster_color, ...
                       'LineWidth', cluster_linewidth);
            end
        end
    end

end