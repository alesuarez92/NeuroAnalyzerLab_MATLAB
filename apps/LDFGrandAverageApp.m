%% LDFGrandAverageApp.m
% =========================================================================
% AVERAGE LDF VIEWER - GRAND AVERAGE OF SEGMENTED LDF TRIALS
% =========================================================================
% Launched from Main. Loads one or more .mat files containing segmentedLDF
% and segmentedTime (from ProcessingLDFApp). Displays segments, plots grand
% average (mean ± SD), optional "Relative to Baseline" correction. Buttons:
% Load Segmented Files, Clear Segments, Plot Grand Average.
% =========================================================================

classdef LDFGrandAverageApp < handle
    %% PROPERTIES: UI, loaded segment matrix, time axis, grand average figure handles
    properties
        UIFig
        LoadBtn
        PlotBtn
        ClearBtn
        Ax
        SegmentedData
        SegmentedTime
        RelativeCheck
        GrandFig  % handle to the grand average figure
        GrandPlot % handle to the average line
        GrandAxes % handle the Axes
        ShadedArea % handle to std shading
    end

    methods
        %% Constructor - Init SegmentedData empty, build UI
        function app = LDFGrandAverageApp()
            app.SegmentedData = [];
            app.buildUI();
        end

        %% buildUI - Toolbar, axes, defined footer (no overlap)
        function buildUI(app)
            T = UITheme;
            app.UIFig = figure('Name', 'Average LDF Viewer', ...
                'Position', [400 300 820 540], 'Resize', 'on', ...
                'Color', T.bgGray);

            % --- Footer panel ---
            footerPanel = uipanel(app.UIFig, 'Units', 'normalized', 'Position', [0 0 1 0.05], ...
                'BorderType', 'none', 'BackgroundColor', T.bgGray);
            uicontrol(footerPanel, 'Style', 'pushbutton', 'String', '© Copyrights by Alejandro Suarez, Ph.D.', ...
                'Units', 'normalized', 'Position', [0.45 0.1 0.54 0.8], ...
                'HorizontalAlignment', 'right', 'FontSize', 9, 'ForegroundColor', [0.1 0.4 0.7], ...
                'BackgroundColor', T.bgGray, 'Callback', @(~,~)web('https://github.com/alesuarez92', '-browser'));

            % --- Toolbar row ---
            app.LoadBtn = uicontrol(app.UIFig, 'Style','pushbutton','String','Load Segmented Files', ...
                'Units', 'normalized', 'Position', [0.04 0.88 0.18 0.06], ...
                'Callback', @(~,~)app.loadFiles());
            app.ClearBtn = uicontrol(app.UIFig, 'Style','pushbutton','String','Clear Segments', ...
                'Units', 'normalized', 'Position', [0.24 0.88 0.14 0.06], ...
                'Callback', @(~,~)app.clearSegments());
            app.PlotBtn = uicontrol(app.UIFig, 'Style','pushbutton','String','Plot Grand Average', ...
                'Units', 'normalized', 'Position', [0.40 0.88 0.16 0.06], ...
                'Callback', @(~,~)app.plotGrandAverage());
            uicontrol(app.UIFig, 'Style','text','String','Relative to Baseline:', ...
                'Units', 'normalized', 'Position', [0.58 0.88 0.16 0.04], 'HorizontalAlignment','left');
            app.RelativeCheck = uicontrol(app.UIFig, 'Style','checkbox', ...
                'Units', 'normalized', 'Position', [0.74 0.885 0.03 0.04], ...
                'Value', 0, 'Callback', @(src,~)app.updateSegmentPlot());

            % --- Axes (above footer, below toolbar) ---
            app.Ax = axes(app.UIFig, 'Units', 'normalized', 'Position', [0.08 0.08 0.84 0.76]);
        end

        function loadFiles(app)
            uistack(app.UIFig, 'bottom');
            drawnow;
            [files, path] = uigetfile('*.mat', 'Select Segmented Files', 'MultiSelect', 'on');
            figure(app.UIFig);
            if isequal(files, 0), return; end
            if ischar(files), files = {files}; end

            for i = 1:length(files)
                data = load(fullfile(path, files{i}));
                if isfield(data, 'segmentedLDF') && isfield(data, 'segmentedTime')
                    if isempty(app.SegmentedData)
                        app.SegmentedData = data.segmentedLDF;
                        app.SegmentedTime = data.segmentedTime;
                    else
                        if isequal(app.SegmentedTime, data.segmentedTime)
                            app.SegmentedData = [app.SegmentedData; data.segmentedLDF];
                        else
                            warning('Skipped file "%s": time axes do not match.', files{i});
                        end
                    end
                end
            end

            msgbox(sprintf('Total segments loaded: %d', size(app.SegmentedData,1)),'modal');

            % Plot immediately
            axes(app.Ax); cla(app.Ax); hold on;
            plot(app.SegmentedTime, app.SegmentedData');% 'Color', [0.6 0.6 0.9 0.3]);
            xlabel('Time (s)'); ylabel('LDF');
            title(sprintf('All Segments Loaded (n = %d)', size(app.SegmentedData, 1)));
            grid on;
        
        end

        function updateSegmentPlot(app)
            if isempty(app.SegmentedData)
                return;
            end
        
            segments = app.SegmentedData;
            t = app.SegmentedTime;
        
            if app.RelativeCheck.Value
                baselineMask = t < 0;
                if ~any(baselineMask)
                    errordlg('No pre-stimulus baseline available for correction.');
                    return;
                end
                baselineMeans = mean(segments(:, baselineMask), 2);
                segments = segments - baselineMeans;
            end
        
            axes(app.Ax); cla(app.Ax); hold on;
            plot(t, segments');%, 'Color', [0.6 0.6 0.9 0.3]);
            xlabel('Time (s)'); ylabel('LDF');
            if app.RelativeCheck.Value
                label = 'All Segments (Relative)';
            else
                label = 'All Segments';
            end
            title(sprintf('%s (n = %d)', label, size(segments,1)));
            grid on;
            
%             if isfield(app, 'GrandFig') && ~isempty(app.GrandFig) && isvalid(app.GrandFig)
%                 app.plotGrandAverage();  % update the grand average but only if it is already shown
%             end
        end

        function clearSegments(app)
            app.SegmentedData = [];
            app.SegmentedTime = [];
            cla(app.Ax);  % Clear the plot
            title(app.Ax, 'No Data Loaded');
        end

        function plotGrandAverage(app)
            if isempty(app.SegmentedData)
                errordlg('No segmented data loaded.');
                return;
            end
        
            segments = app.SegmentedData;
            t = app.SegmentedTime;
        
            % Apply relative baseline correction if needed
            if app.RelativeCheck.Value
                baselineMask = t < 0;
                if ~any(baselineMask)
                    errordlg('No pre-stimulus baseline available for correction.');
                    return;
                end
                baselineMeans = mean(segments(:, baselineMask), 2);
                segments = segments - baselineMeans;
            end
        
            avg = mean(segments, 1);
            stddev = std(segments, 0, 1);
        
            % === Reuse the same figure ===
            if isempty(app.GrandFig) || ~isvalid(app.GrandFig)
                app.GrandFig = figure('Name','Grand Average of Segments');
                app.GrandAxes = axes(app.GrandFig);  % Store axes if needed
            else
                figure(app.GrandFig);                % Bring figure to front
                cla(app.GrandFig.CurrentAxes);       % Clear previous plots
            end
        
            ax = app.GrandFig.CurrentAxes;
        
            % Plot shaded area for std
            app.ShadedArea = fill(ax, ...
                [t, fliplr(t)], ...
                [avg + stddev, fliplr(avg - stddev)], ...
                [0.8 0.8 1], 'EdgeColor','none', 'FaceAlpha', 0.4);
        
            hold(ax, 'on');
        
            % Plot average trace
            app.GrandPlot = plot(ax, t, avg, 'b-', 'LineWidth', 2);
        
            xlabel(ax, 'Time (s)');
            ylabel(ax, 'LDF');
            title(ax, sprintf('Grand Average (n = %d)', size(segments,1)));
            grid(ax, 'on');
        end

    end
end