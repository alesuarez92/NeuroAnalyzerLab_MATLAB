%% SignalFeatures.m
% =========================================================================
% SIGNAL FEATURES - EXTRACT RESPONSE FEATURES FROM PROCESSED SIGNALS
% =========================================================================
% Static helpers for signal characterization: FWHM, peak latency, onset
% delay, areas under the curve (positive/negative), rise/decay times,
% peak amplitude, and stimulation-response integration. All methods assume
% time vector t (seconds) and signal y; optional baseline window or baseline
% value. Used by SignalCharacterizationApp.
% =========================================================================

classdef SignalFeatures
    methods(Static)
        %% peakLatency - Time from t(1) or t0 to maximum (or minimum) value
        % t, y: vectors; t0: optional start time (e.g. stimulus onset). direction: 'max' or 'min'
        function [lat, amp] = peakLatency(t, y, t0, direction)
            if nargin < 3, t0 = t(1); end
            if nargin < 4, direction = 'max'; end
            idx = t >= t0;
            if ~any(idx), lat = NaN; amp = NaN; return; end
            t_ = t(idx); y_ = y(idx);
            if strcmpi(direction, 'min')
                [amp, i] = min(y_);
            else
                [amp, i] = max(y_);
            end
            lat = t_(i) - t0;
        end

        %% onsetDelay - Time to first cross a fraction of peak (e.g. 0.5 = 50% of peak)
        % t, y: vectors; t0: stimulus onset; frac: fraction of peak (0–1); direction 'max' or 'min'
        function delay = onsetDelay(t, y, t0, frac, direction)
            if nargin < 4, frac = 0.5; end
            if nargin < 5, direction = 'max'; end
            [~, amp] = SignalFeatures.peakLatency(t, y, t0, direction);
            idx = t >= t0;
            if ~any(idx), delay = NaN; return; end
            t_ = t(idx); y_ = y(idx);
            if strcmpi(direction, 'min')
                thr = amp + frac * (mean(y_(1:min(3,numel(y_)))) - amp);
            else
                thr = amp - frac * (amp - mean(y_(1:min(3,numel(y_)))));
            end
            if strcmpi(direction, 'min')
                cross = find(y_ <= thr, 1);
            else
                cross = find(y_ >= thr, 1);
            end
            if isempty(cross), delay = NaN; return; end
            delay = t_(cross) - t0;
        end

        %% fwhm - Full width at half maximum (seconds) around peak after t0
        % t, y: vectors; t0: onset; direction 'max' or 'min'
        function w = fwhm(t, y, t0, direction)
            if nargin < 4, direction = 'max'; end
            [amp, ~] = SignalFeatures.peakLatency(t, y, t0, direction);
            idx = t >= t0;
            if ~any(idx), w = NaN; return; end
            t_ = t(idx); y_ = y(idx);
            base = mean(y_(1:min(5, numel(y_))));
            if strcmpi(direction, 'min')
                half = amp + 0.5 * (base - amp);
                above = y_ <= half;
            else
                half = amp - 0.5 * (amp - base);
                above = y_ >= half;
            end
            ii = find(above);
            if isempty(ii), w = NaN; return; end
            w = t_(ii(end)) - t_(ii(1));
        end

        %% aucPositive - Area under the curve for y > baseline (trapz)
        function a = aucPositive(t, y, baseline)
            if nargin < 3, baseline = mean(y(1:min(round(numel(y)/10), numel(y)))); end
            y_ = y - baseline;
            y_(y_ < 0) = 0;
            a = trapz(t, y_);
        end

        %% aucNegative - Area under the curve for y < baseline (absolute value)
        function a = aucNegative(t, y, baseline)
            if nargin < 3, baseline = mean(y(1:min(round(numel(y)/10), numel(y)))); end
            y_ = baseline - y;
            y_(y_ < 0) = 0;
            a = trapz(t, y_);
        end

        %% riseTime - Time from 10% to 90% of peak (from t0)
        function rt = riseTime(t, y, t0, direction)
            if nargin < 4, direction = 'max'; end
            [amp, ~] = SignalFeatures.peakLatency(t, y, t0, direction);
            idx = t >= t0;
            if ~any(idx), rt = NaN; return; end
            t_ = t(idx); y_ = y(idx);
            if strcmpi(direction, 'min')
                lo = amp + 0.9 * (min(y_) - amp);
                hi = amp + 0.1 * (min(y_) - amp);
            else
                lo = amp - 0.9 * (amp - max(y_));
                hi = amp - 0.1 * (amp - max(y_));
            end
            iLo = find(y_ >= lo, 1); iHi = find(y_ >= hi, 1);
            if strcmpi(direction, 'min')
                iLo = find(y_ <= lo, 1); iHi = find(y_ <= hi, 1);
            end
            if isempty(iLo) || isempty(iHi), rt = NaN; return; end
            rt = abs(t_(iHi) - t_(iLo));
        end

        %% decayTime - Time from peak to 50% return toward baseline (after t0)
        function dt = decayTime(t, y, t0, direction)
            if nargin < 4, direction = 'max'; end
            [amp, ~] = SignalFeatures.peakLatency(t, y, t0, direction);
            idx = t >= t0;
            if ~any(idx), dt = NaN; return; end
            t_ = t(idx); y_ = y(idx);
            base = mean(y_(1:min(5,numel(y_))));
            if strcmpi(direction, 'min')
                half = amp + 0.5 * (base - amp);
                after = find(t_ > t_(y_ == min(y_), 1), 1);
                if isempty(after), dt = NaN; return; end
                cross = find(y_(after:end) >= half, 1) + after - 1;
            else
                half = amp - 0.5 * (amp - base);
                after = find(y_ == max(y_), 1, 'last');
                cross = find(y_(after:end) <= half, 1) + after - 1;
            end
            if isempty(cross), dt = NaN; return; end
            dt = t_(cross) - t_(after);
        end

        %% peakAmplitude - Max or min value relative to baseline (after t0)
        function [amp, tPeak] = peakAmplitude(t, y, t0, direction, baseline)
            if nargin < 4, direction = 'max'; end
            if nargin < 5, baseline = []; end
            idx = t >= t0;
            if ~any(idx), amp = NaN; tPeak = NaN; return; end
            t_ = t(idx); y_ = y(idx);
            if isempty(baseline), baseline = mean(y_(1:min(5,numel(y_)))); end
            if strcmpi(direction, 'min')
                [v, i] = min(y_);
            else
                [v, i] = max(y_);
            end
            amp = v - baseline;
            tPeak = t_(i);
        end

        %% stimResponseIntegration - Integral of response * stim (or dot product) over window
        % stim and response same length as t; t0 = stimulus onset. Returns integral of response from t0.
        function val = stimResponseIntegration(t, stim, response, t0)
            if nargin < 4, t0 = t(1); end
            idx = t >= t0;
            if ~any(idx), val = NaN; return; end
            val = trapz(t(idx), response(idx));
        end
    end
end
