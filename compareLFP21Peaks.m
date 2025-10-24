function isSimilar = compareLFPPeaks(peak1_time, peak1_volt, peak2_time, peak2_volt, options)

arguments
    peak1_time (1,:) double {mustBeReal, mustBeVector, mustBeNonempty}  
    peak1_volt (1,:) double {mustBeReal, mustBeVector, mustBeNonempty}
    peak2_time (1,:) double {mustBeReal, mustBeVector, mustBeNonempty}
    peak2_volt (1,:) double {mustBeReal, mustBeVector, mustBeNonempty}
    options.peakThresh double = 0.1    
    options.halfXThresh double = 0.3   
    options.zeroXThresh double = 0.1   
    options.Visualize logical = false  
end


peak1_time = peak1_time(:);
peak1_volt = peak1_volt(:);
peak2_time = peak2_time(:);
peak2_volt = peak2_volt(:); 
validateattributes(peak1_time, {'double'}, {'numel',21}, 'compareLFPPeaks', 'peak1_time');
validateattributes(peak1_volt, {'double'}, {'numel',21}, 'compareLFPPeaks', 'peak1_volt');
validateattributes(peak2_time, {'double'}, {'numel',21}, 'compareLFPPeaks', 'peak2_time');
validateattributes(peak2_volt, {'double'}, {'numel',21}, 'compareLFPPeaks', 'peak2_volt');


peak1 = struct('times_21', peak1_time, 'voltages_21', peak1_volt);
peak2 = struct('times_21', peak2_time, 'voltages_21', peak2_volt);


[isSimilar, features] = comparePeaksCore(peak1, peak2, options.peakThresh, options.halfXThresh, options.zeroXThresh);


if options.Visualize
    fprintf('可视化开关已激活，准备生成对比图...\n');
    visualizeComparison(peak1, peak2, features, isSimilar, options.halfXThresh, options.zeroXThresh); % 传递isSimilar
    drawnow; 
end


    function [result, feat] = comparePeaksCore(p1, p2, yTh, hxTh, zxTh)

        [~, maxIdx1] = max(abs(p1.voltages_21));
        peakY1 = p1.voltages_21(maxIdx1);
        [~, maxIdx2] = max(abs(p2.voltages_21));
        peakY2 = p2.voltages_21(maxIdx2);
        commonHalfY = 0.5 * min(abs(peakY1), abs(peakY2)) * sign(peakY1);
        

        [halfX1_left, halfX1_right] = findBilateralCrossing(p1, commonHalfY);
        [halfX2_left, halfX2_right] = findBilateralCrossing(p2, commonHalfY);
        

        [zeroX1_left, zeroX1_right] = findBilateralZeroCrossings(p1);
        [zeroX2_left, zeroX2_right] = findBilateralZeroCrossings(p2);
        

        yDiff = abs(peakY1 - peakY2) / max(abs([peakY1, peakY2]));
        

        hxDiff_left = abs(halfX1_left - halfX2_left) / max(abs([halfX1_left, halfX2_left]));
        hxDiff_right = abs(halfX1_right - halfX2_right) / max(abs([halfX1_right, halfX2_right]));
        

        zxDiff_left = abs(zeroX1_left - zeroX2_left) / max(abs([zeroX1_left, zeroX2_left]));
        zxDiff_right = abs(zeroX1_right - zeroX2_right) / max(abs([zeroX1_right, zeroX2_right]));
        

        result = yDiff <= yTh && ...
                 hxDiff_left <= hxTh && hxDiff_right <= hxTh && ...
                 zxDiff_left <= zxTh && zxDiff_right <= zxTh;
        

        feat = struct(...
            'peak1', struct(...
                'Y', peakY1, ...
                'halfX_left', halfX1_left, ...
                'halfX_right', halfX1_right, ...
                'zeroX_left', zeroX1_left, ...
                'zeroX_right', zeroX1_right), ...
            'peak2', struct(...
                'Y', peakY2, ...
                'halfX_left', halfX2_left, ...
                'halfX_right', halfX2_right, ...
                'zeroX_left', zeroX2_left, ...
                'zeroX_right', zeroX2_right), ...
            'commonHalfY', commonHalfY);
    end
    
    
    function [t_left, t_right] = findBilateralCrossing(peak, threshold)
        
        idx = find(diff(sign(peak.voltages_21 - threshold)) ~= 0);
        
        
        left_idx = idx(peak.times_21(idx) < 0);  
        right_idx = idx(peak.times_21(idx) > 0); 
        
        
        if ~isempty(left_idx)
            [~, closest_left] = min(abs(peak.times_21(left_idx)));
            t_left = interp1(...
                peak.voltages_21(left_idx(closest_left):left_idx(closest_left)+1),...
                peak.times_21(left_idx(closest_left):left_idx(closest_left)+1),...
                threshold);
        else
            t_left = NaN;
        end
        
        
        if ~isempty(right_idx)
            [~, closest_right] = min(abs(peak.times_21(right_idx)));
            t_right = interp1(...
                peak.voltages_21(right_idx(closest_right):right_idx(closest_right)+1),...
                peak.times_21(right_idx(closest_right):right_idx(closest_right)+1),...
                threshold);
        else
            t_right = NaN;
        end
    end

    
    function t = findCrossingTime(peak, threshold)
        
        idx = find(diff(sign(peak.voltages_21 - threshold)) ~= 0);
        if isempty(idx)
            t = NaN; 
            return
        end
        
        
        [~, closestIdx] = min(abs(peak.times_21(idx) - 0)); 
        t = interp1(peak.voltages_21(idx(closestIdx):idx(closestIdx)+1),...
                    peak.times_21(idx(closestIdx):idx(closestIdx)+1),...
                    threshold);
    end
 
   
    function [leftX, rightX] = findBilateralZeroCrossings(peak)
       
        idx = find(diff(sign(peak.voltages_21)) ~= 0);
        if isempty(idx)
            leftX = NaN;
            rightX = NaN;
            return;
        end
        
        
        zeroXs = arrayfun(@(i) interp1(...
            peak.voltages_21(i:i+1),...
            peak.times_21(i:i+1),...
            0), idx);
        
        
        leftXs = zeroXs(zeroXs < 0);
        rightXs = zeroXs(zeroXs > 0);
        
        
        leftX = getClosestCrossing(leftXs);
        rightX = getClosestCrossing(rightXs);
        
        
        function x = getClosestCrossing(xs)
            if isempty(xs)
                x = NaN;
            else
                [~, closest] = min(abs(xs));
                x = xs(closest);
            end
        end
    end

   
end