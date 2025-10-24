function [t_aligned, t_21, v_21, t_9, v_9] = extract21PointsFromPeaks(loc, volt, fs, num_points, varargin)
    
    p = inputParser;
    addRequired(p, 'loc', @isvector);
    addRequired(p, 'volt', @isvector);
    addRequired(p, 'fs', @isscalar);
    addRequired(p, 'num_points', @isscalar);
    addParameter(p, 'Visualize', false, @islogical); 
    parse(p, loc, volt, fs, num_points, varargin{:});
    plotFlag = p.Results.Visualize;
 

    [~, max_pos] = max(abs(volt));       
    peak_index = loc(max_pos);            
    t_aligned = (loc - peak_index) * 1000 / fs; 
    

    key_times = zeros(1,9);        
    key_times([1 9]) = [t_aligned(1), t_aligned(end)];     
    key_times(5) = 0;         
    key_times(2:2:8) = findZeroCrossings(t_aligned, volt);  
    key_times([3 7]) = findHalfAmplitude(t_aligned, volt, max_pos);
    key_times([4 6]) = findExtrema(t_aligned, volt);      
    

    t_9 = key_times;
    v_9 = interp1(t_aligned, volt, t_9, 'pchip');
    
    key_times = unique(sort(key_times));       
    

    [t_21, v_21] = interpolatePoints(t_aligned, volt, key_times, num_points);
    

    if plotFlag
        figure;
        hold on;
        

        plot(t_aligned, volt, 'b-', 'LineWidth', 1.5, 'DisplayName','原始波形');
        

        plot(t_9, v_9, 'go', 'MarkerSize', 8, 'MarkerFaceColor','g', 'DisplayName','9个关键点');
        

        plot(t_21, v_21, 'ro-', 'MarkerSize', 8, 'LineWidth', 1.2,...
            'MarkerFaceColor','r', 'DisplayName','21点特征');
        

        title('波形对齐及下采样对比');
        xlabel('时间 (ms)');
        ylabel('电压 (μV)');
        legend('Location','best');
        grid on;
        hold off;
        

        set(gcf, 'Position', [200 200 600 400]);
        set(gca, 'FontSize', 11, 'Box','off');
    end
end

function [left_cross, right_cross] = findZeroCrossings(t, volt)
    cross_idx = find(diff(sign(volt)) ~= 0); 
    if isempty(cross_idx)
        left_cross = t(1);  
        right_cross = t(end);
    else
        zero_times = t(cross_idx);
        [~, idx] = sort(abs(zero_times));
        selected = zero_times(idx(1:min(2,end))); 
        left_cross = min(selected);
        right_cross = max(selected);
    end
end


function [left_half, right_half] = findHalfAmplitude(t, volt, peak_pos)
    threshold = volt(peak_pos)/2;
    cross_idx = find(diff(sign(volt - threshold)) ~= 0); 
    if isempty(cross_idx)
        left_half = t(1);
        right_half = t(end);
    else
        half_times = t(cross_idx);
        [~, idx] = sort(abs(half_times));
        selected = half_times(idx(1:min(2,end)));
        left_half = min(selected);
        right_half = max(selected);
    end
end


function [left_ext, right_ext] = findExtrema(t, volt)
    [~, maxima] = findpeaks(volt);
    [~, minima] = findpeaks(-volt);
    
    maxima = maxima(:);   
    minima = minima(:);  
    
    extrema = unique([maxima; minima]); 
    
    if isempty(extrema)
        left_ext = t(1);
        right_ext = t(end);
    else
        ext_times = t(extrema);
        [~, idx] = sort(abs(ext_times));
        selected = ext_times(idx(1:min(2,end)));
        left_ext = min(selected);
        right_ext = max(selected);
    end
end


function [t_new, v_new] = interpolatePoints(t, v, key_times, num_points)
    key_sorted = unique(sort(key_times));
    remaining = num_points - length(key_sorted);
    
    if remaining > 0
        diffs = diff(key_sorted);
        total_space = sum(diffs);
        points_per_diff = round(remaining * diffs / total_space);
        points_per_diff(end+1:length(diffs)) = 0; 
        
        
        remainder = remaining - sum(points_per_diff);
        [~, idx] = sort(diffs, 'descend');
        points_per_diff(idx(1:abs(remainder))) = points_per_diff(idx(1:abs(remainder))) + sign(remainder);
        
        
        t_supplement = [];
        for i = 1:length(diffs)
            if points_per_diff(i) > 0
                new_t = linspace(key_sorted(i), key_sorted(i+1), points_per_diff(i)+2);
                t_supplement = [t_supplement, new_t(2:end-1)];
            end
        end
        t_new = sort([key_sorted, t_supplement]);
    else
        t_new = key_sorted;
    end
    
    
    if length(t_new) > num_points
        remove_idx = round(linspace(1, length(t_new), length(t_new)-num_points));
        t_new(remove_idx) = [];
    elseif length(t_new) < num_points
        t_new = [t_new, linspace(t_new(end), t(end), num_points-length(t_new))];
    end
    
    
    v_new = interp1(t, v, t_new, 'pchip');
end