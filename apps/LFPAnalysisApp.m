%% LFPAnalysisApp.m
% =========================================================================
% PROCESS LFP DATA - ERP AND CSD ANALYSIS ON LOADED LFP
% =========================================================================
% Launched from Main. Loads .mat with lfp_data (and optionally stim, Fs)
% saved from ExtractEphysApp. User selects channels, runs ERP Analysis
% (ERPConfigApp for window/baseline, then trial average) and CSD Analysis
% (current source density across channels). Results plotted in AxContainer.
% =========================================================================

classdef LFPAnalysisApp < handle
    %% PROPERTIES: UI, loaded LFP/Stim/t/Fs, selected channels, ERP params and last results
    properties
        UIFig
        LoadBtn
        FileLabel

        ChannelList
        ChannelLabel
        ERBBtn
        CSDBtn


        AxContainer

        % Data
        LFP
        Stim
        t_lfp
        t_stim
        Fs_lfp
        Fs_stim

        % Analysis
        SelectedChannels
        ERPParams
        LastERP      
        LastTime    
    end

    methods
        %% Constructor - Build UI; data loaded via Load LFP Data
        function app = LFPAnalysisApp()
            app.buildUI();
        end

        %% buildUI - Figure, Load/Channel/ERP/CSD, AxContainer, defined footer
        function buildUI(app)
            T = UITheme;
            app.UIFig = figure('Name', 'ERP Analysis App', ...
                'Position', [300 300 1000 720], 'Resize', 'on', ...
                'Color', T.bgGray);

            % --- Footer panel (defined, no overlap with content) ---
            footerPanel = uipanel(app.UIFig, 'Units', 'normalized', 'Position', [0 0 1 0.05], ...
                'BorderType', 'none', 'BackgroundColor', T.bgGray);
            uicontrol(footerPanel, 'Style', 'pushbutton', 'String', '© Copyrights by Alejandro Suarez, Ph.D.', ...
                'Units', 'normalized', 'Position', [0.45 0.1 0.54 0.8], ...
                'HorizontalAlignment', 'right', 'FontSize', 9, 'ForegroundColor', [0.1 0.4 0.7], ...
                'BackgroundColor', T.bgGray, 'Callback', @(~,~)web('https://github.com/alesuarez92', '-browser'));

            % --- Load and file label ---
            app.LoadBtn = uicontrol(app.UIFig, 'Style','pushbutton', ...
                'String','Load LFP Data', 'Units', 'normalized', ...
                'Position', [0.02 0.90 0.14 0.05], ...
                'Callback', @(~,~)app.loadData());
            app.FileLabel = uicontrol(app.UIFig, 'Style','text', ...
                'String','No file loaded.', 'Units', 'normalized', ...
                'Position', [0.02 0.855 0.5 0.03], ...
                'HorizontalAlignment','left');

            % --- Channel list (left column, clear spacing) ---
            uicontrol(app.UIFig, 'Style','text', 'String','Loaded Channels:', ...
                'Units', 'normalized', 'Position', [0.20 0.90 0.14 0.03], 'HorizontalAlignment','left');
            app.ChannelList = uicontrol(app.UIFig, 'Style','listbox', ...
                'Units', 'normalized', 'Position', [0.20 0.58 0.12 0.30], ...
                'Max', 16, 'Min', 1, 'String', {}, 'Enable', 'off');
            app.ChannelLabel = uicontrol(app.UIFig, 'Style','text', ...
                'String','No channels loaded.', ...
                'Units', 'normalized', 'Position', [0.20 0.55 0.22 0.025], ...
                'HorizontalAlignment','left');

            % --- ERP and CSD buttons (spaced, above axes) ---
            app.ERBBtn = uicontrol(app.UIFig, 'Style','pushbutton', 'String','ERP Analysis', ...
                'Units', 'normalized', 'Position', [0.42 0.88 0.18 0.06], ...
                'Enable', 'off', 'Callback', @(~,~)app.openERPConfig());
            app.CSDBtn = uicontrol(app.UIFig, 'Style','pushbutton', 'String','CSD Analysis', ...
                'Units', 'normalized', 'Position', [0.62 0.88 0.18 0.06], ...
                'Enable', 'off', 'Callback', @(~,~)computeCSD(app));

            % --- Axes container (above footer, below toolbar) ---
            app.AxContainer = uipanel(app.UIFig, ...
                'Title','ERP Results', 'Units', 'normalized', ...
                'Position', [0.01 0.06 0.98 0.78]);
        end

        function loadData(app)
            uistack(app.UIFig, 'bottom');
            drawnow;
            [file, path] = uigetfile('*.mat', 'Select LFP Data File');
            figure(app.UIFig);
            if isequal(file, 0)
                return;
            end

            s = load(fullfile(path, file));
            app.LFP = s.lfp_data;
            app.Stim = s.stim_data;
            app.t_lfp = s.t_lfp;
            app.t_stim = s.t_stim;
            app.Fs_lfp = s.lfp_fs;
            app.Fs_stim = s.stim_fs;

            % Update label and listbox
            nChan = size(app.LFP, 1);
            chanLabels = arrayfun(@(i) sprintf('Ch %d', i), 1:nChan, 'UniformOutput', false);
            app.ChannelList.String = chanLabels;
            app.ChannelList.Value = 1:min(4, nChan);
            app.ChannelList.Enable = 'on';
            app.ERBBtn.Enable = 'on';
            app.ChannelLabel.String = sprintf('%d channels loaded', nChan);
            app.FileLabel.String = file;
        end

        function openERPConfig(app)
            app.SelectedChannels = app.ChannelList.Value;
            if isempty(app.SelectedChannels)
                errordlg('Please select at least one channel for ERP analysis.');
                return;
            end

            cfg = ERPConfigApp(app.Fs_lfp);
            uiwait(cfg.UIFig);
            if isempty(cfg.Params)
                return;
            end
            app.ERPParams = cfg.Params;

            % Next: computeERP()
            app.computeERP();
        end

        function computeERP(app)
            % Extract parameters
            fs = app.Fs_lfp;
            preS = app.ERPParams.preTime;
            postS = app.ERPParams.postTime;
            threshold = app.ERPParams.threshold;
            minISI = app.ERPParams.minISI;
            chIdx = app.SelectedChannels;
        
            % Detect stimulus onsets
            stim = app.Stim;
            stim = stim - mean(stim);
            above = stim > threshold;
            onsets = find(diff([0 above]) == 1);
            isi = diff(onsets) / app.Fs_stim;
            validIdx = [true, isi > minISI];
            onsets = onsets(validIdx);
            onsetTimes = onsets / app.Fs_stim;
        
            % Convert to LFP indices
            preSamples = round(preS * fs);
            postSamples = round(postS * fs);
            totalSamples = preSamples + postSamples + 1;
            erpMat = zeros(length(chIdx), totalSamples, length(onsetTimes));
        
            for t = 1:length(onsetTimes)
                centerIdx = round(onsetTimes(t) * fs);
                idxRange = centerIdx - preSamples : centerIdx + postSamples;
                if idxRange(1) < 1 || idxRange(end) > size(app.LFP, 2)
                    continue;
                end
                erpMat(:,:,t) = app.LFP(chIdx, idxRange);
            end
        
            % Average and standard deviation ERP
            erpAvg = mean(erpMat, 3, 'omitnan');
            erpStd = std(erpMat, 0, 3, 'omitnan');
            t = linspace(-preS, postS, totalSamples);
        
            % Display number of epochs averaged
            annotation(app.UIFig, 'textbox', [0.01 0.66 0.3 0.03], 'String', sprintf('Averaged %d epochs', size(erpMat, 3)), ...
                      'EdgeColor','none', 'FontWeight','bold');
        
            % Clear previous plots
            delete(findall(app.AxContainer, 'Type', 'tiledlayout'));
        
            % Create combined ERP plot (all channels in one plot)
            if length(chIdx) > 1
                axAll = axes('Parent', app.AxContainer, 'Position', [0.05 0.1 0.9 0.8]);
                hold(axAll, 'on');
                colors = lines(length(chIdx));
                for i = 1:length(chIdx)
                    plot(axAll, t, erpAvg(i,:), 'Color', colors(i,:), 'DisplayName', sprintf('Ch %d', chIdx(i)));
                end
                plot(axAll, [0 0], ylim(axAll), 'r--', 'DisplayName', 'Stimulus Onset');
                title(axAll, 'ERP Overlay');
                xlabel(axAll, 'Time (s)'); ylabel(axAll, 'Amplitude');
                legend(axAll, 'show');
            end
        
            % Create multi-channel windowed plots (4 channels max per window)
            numPlots = ceil(length(chIdx) / 4);
            for w = 1:numPlots
                idxStart = (w-1)*4 + 1;
                idxEnd = min(w*4, length(chIdx));
                chans = chIdx(idxStart:idxEnd);
        
                fig = figure('Name', sprintf('ERP Window %d', w), 'Position', [100+100*w, 100+50*w, 600, 800]);
                ax = tiledlayout(fig, length(chans), 1, 'TileSpacing','compact', 'Padding','compact');
                for i = 1:length(chans)
                    nexttile(ax);
                    fill([t fliplr(t)], [erpAvg(idxStart+i-1,:) + erpStd(idxStart+i-1,:), ...
                         fliplr(erpAvg(idxStart+i-1,:) - erpStd(idxStart+i-1,:))], [0.8 0.8 1], 'EdgeColor', 'none'); hold on;
                    plot(t, erpAvg(idxStart+i-1,:), 'b');
                    ylimits = ylim;
                    plot([0 0], ylimits, 'r--');
                    ylim(ylimits);
                    ylabel(sprintf('Ch %d', chans(i)));
                    title(sprintf('ERP - Channel %d', chans(i)));
                    if i == length(chans)
                        xlabel('Time (s)');
                    else
                        set(gca,'XTickLabel',[]);
                    end
                end
            end
            app.LastERP  = erpAvg;
            app.LastTime = t;
            app.CSDBtn.Enable = 'on';

        end

        function computeCSD(app)
            if isempty(app.LastERP) || isempty(app.LastTime)
                errordlg('No ERP data available. Run ERP analysis first.');
                return;
            end
        
            % Ask user for parameters
            prompt = {
                'Enter inter-electrode spacing (micrometers):', ...
                'Enter custom channel order (e.g., 5 4 3 2 1):'
            };
            dlgtitle = 'CSD Parameters';
            dims = [1 50];
            definput = {'100', num2str(app.SelectedChannels)};
            answer = inputdlg(prompt, dlgtitle, dims, definput);
            if isempty(answer), return; end
        
            spacing_um = str2double(answer{1}) * 1e-6;  % meters
            chan_order = str2num(answer{2});           %#ok<ST2NM>
            [~, reorder] = ismember(chan_order, app.SelectedChannels);
        
            % Reorder ERP to match user input
            erp = app.LastERP(reorder, :);
            t   = app.LastTime;
        
            % Compute second spatial derivative (discrete Laplacian)
            dz  = spacing_um;
            csd = -diff(erp, 2, 1) / dz^2;
            csd = padarray(csd, [1 0], 'replicate', 'both');
        
            % Plot
            figure('Name', 'CSD Map', 'Position', [200 100 800 600]);
            imagesc(t, 1:length(chan_order), csd);
            colormap(jet);
            colorbar;
            xlabel('Time (s)');
            ylabel('Channel (ordered)');
            title('Current Source Density (CSD)');
            hold on;
            plot([0 0], ylim, 'k--');
        end


    end
end