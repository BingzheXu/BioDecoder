tic
clear;

fs = 3000;                    
num_points = 21;               
thresholds = struct(...      
    'peakThresh', 0.1, ...     
    'halfXThresh', 0.6, ...   
    'zeroXThresh', 0.4);       

matFiles ='merged_peak_library';
data = load(matFiles);
mergedPeakTable = data.mergedPeakTable;

LibraryMat='Class_Library_update.mat'; % Please use the most updated library.
if exist(LibraryMat, 'file')
    load(LibraryMat);  
    fprintf('Library Loaded: %s\n', LibraryMat);
else
    fprintf('Library Not Found, contact author for the updated library\n');
end
 
if ~exist('updatedLibrary', 'var')
    updatedLibrary = struct('ClassID',{}, 'TemplateTime',{}, 'TemplateVoltage',{}, 'Members',{});
end

mergedPeakTable = initFeatureColumns(mergedPeakTable); 
mergedPeakTable = extractAllFeatures(mergedPeakTable, fs, num_points);
[classifiedTable, classLibrary] = initializeClassificationSystem(mergedPeakTable, updatedLibrary);
[classifiedTable, classLibrary] = autoClassifyPeaks(classifiedTable, classLibrary, thresholds);

save('Classified_Peaks.mat', 'classifiedTable', '-v7.3');



function mergedPeakTable = initFeatureColumns(mergedPeakTable)
    requiredVars = {'times_21', 'voltages_21', 'ClassLabel'};    
    for var = requiredVars
        varName = var{1};
        if ~any(strcmp(varName, mergedPeakTable.Properties.VariableNames))
            if strcmp(varName, 'ClassLabel')
                mergedPeakTable.(varName) = zeros(height(mergedPeakTable),1); 
            else
                mergedPeakTable.(varName) = cell(height(mergedPeakTable),1);   
            end
        end
    end    
    if iscell(mergedPeakTable.ClassLabel)
        mergedPeakTable.ClassLabel = cell2mat(mergedPeakTable.ClassLabel);
    end
    mergedPeakTable.ClassLabel(:) = 0; 
end

function mergedPeakTable = extractAllFeatures(mergedPeakTable, fs, num_points)
    for row = 1:height(mergedPeakTable)
        loc = mergedPeakTable.Locations{row};
        volt = mergedPeakTable.Voltage{row};        
        [~, t_21, v_21] = extract21PointsFromPeaks(loc, volt, fs, num_points);        
        mergedPeakTable.times_21{row} = t_21(:);
        mergedPeakTable.voltages_21{row} = v_21(:);
    end
end

function [classifiedTable, classLibrary] = initializeClassificationSystem(mergedPeakTable, updatedLibrary)
    classifiedTable = mergedPeakTable;
    if exist('updatedLibrary', 'var') && ~isempty(updatedLibrary)
        classLibrary = updatedLibrary;
        fprintf('updated library loaded\n');
    else
        fprintf('Library Not Found，contact author for the updated library\n');
    end
end

function [classifiedTable, classLibrary] = autoClassifyPeaks(classifiedTable, classLibrary, thresholds)
    for i = 1:height(classifiedTable)
        currentPeak = getCurrentPeak(classifiedTable(i,:));    
        if isempty(classLibrary)
            classifiedTable.ClassLabel(i) = 1;
            continue;
        end        
        isClassified = false;
        for class_num = 1:numel(classLibrary)
            if compareWithTemplate(currentPeak, classLibrary(class_num), thresholds)
                classLibrary(class_num) = updateClassTemplate(classLibrary(class_num), currentPeak); 
                classifiedTable.ClassLabel(i) = classLibrary(class_num).ClassID;
                isClassified = true;
                break;
            end
        end        
        if ~isClassified  
            classifiedTable.ClassLabel(i) = 0;  
        end
    end
end

function currentPeak = getCurrentPeak(row)
    currentPeak = struct(...
        'FileName', row.FileName{1}, ...
        'Channel', row.Channel, ...
        'PeakID', row.PeakID, ...
        'rawLocations', row.Locations{1}, ...     
        'rawVoltage', row.Voltage{1}, ...         
        'times_21', row.times_21{1}, ...
        'voltages_21', row.voltages_21{1});
end

function isSimilar = compareWithTemplate(currentPeak, classTemplate, thresholds)
    isSimilar = compareLFP21Peaks(...
        currentPeak.times_21, currentPeak.voltages_21,...
        classTemplate.TemplateTime, classTemplate.TemplateVoltage,...
        'peakThresh', thresholds.peakThresh,...
        'halfXThresh', thresholds.halfXThresh,...
        'zeroXThresh', thresholds.zeroXThresh);
end

function updatedClass = updateClassTemplate(oldClass, newPeak)
    newMember = struct(...
        'FileName', newPeak.FileName, ...
        'Channel', newPeak.Channel, ...
        'PeakID', newPeak.PeakID, ...
        'rawLocations', newPeak.rawLocations, ...  
        'rawVoltage', newPeak.rawVoltage, ...       
        'times_21', newPeak.times_21, ...
        'voltages_21', newPeak.voltages_21);   
    updatedClass = oldClass;
    updatedClass.Members = [oldClass.Members; newMember];   
end

toc


