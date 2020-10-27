function convert2ascSynch(Experiment)

%% Convert edf to asc for Baseball Data
%  currently ignore all asc files named _e or _s


%% (1) Set up folders run edf2asc.exe:

% startFolder = [pwd '\Analyses1\'];                                        % where is the edf2asc program?
startFolder = [pwd '/Analyses1/'];
% dataPath = [pwd '\data\' Experiment.sbj.sbjFolder(6:end) '\'];
dataPath = [pwd '/data/' Experiment.sbj.sbjFolder(6:end) '/'];
 
% run edf2asc.exe over the current subject:
% [res, stat] = system([startFolder 'edf2asc -y ' dataPath '\*.edf']);

% read out Ezelink Messages (provide important time stamps for synchronization):
% ascfiles = dir([dataPath '\*.asc']);
ascfiles = dir([dataPath '/*.asc']);
nHeader = 10;                                                               % the header contains information about the session and EL.
eventLog = table();


%% (2)  loop over all asc files for 1 subject/data folder

for j = 1:length(ascfiles)
    ascfile = ascfiles(j).name;
    path = fullfile(dataPath, ascfile);
    fid = fopen(path);
    
    textscan(fid, '%*[^\n]', nHeader);                                      % skip the header and then search for messages
    entries = textscan(fid, '%s %s %s %s %*[^\n]');
    for lineN = 1:size(entries{1}, 1)
        if strcmp(entries{1}{lineN}, 'MSG')
            if strcmp(entries{3}{lineN}, 'TRIAL_START')
                trialN = str2num(entries{4}{lineN});
                eventLog.trialStart(trialN, 1) = str2num(entries{2}{lineN});
            elseif strcmp(entries{3}{lineN}, 'STIM_ON')
                eventLog.stimOn(trialN, 1) = str2num(entries{2}{lineN}); 
            elseif strcmp(entries{3}{lineN}, 'FLASH_ON')
                eventLog.flashOn(trialN, 1) = str2num(entries{2}{lineN});
            elseif strcmp(entries{3}{lineN}, 'FLASH_OFF')
                eventLog.flashOff(trialN, 1) = str2num(entries{2}{lineN});
            elseif strcmp(entries{3}{lineN}, 'TRIAL_END')
                eventLog.trialEnd(trialN, 1) = str2num(entries{2}{lineN});
            end
        end
    end
    fclose(fid);
end
cd(dataPath)
save('eventLog', 'eventLog')
cd(startFolder)

% convert data into samples only and replace missing values with 9999
% [res, stat] = system([startFolder 'edf2asc -y -s -miss 9999 -nflags ' dataPath '\*.edf']);
% 

%% (3) Split .asc-block file into single trial .mat-files:

cd(dataPath)
eyeFiles = dir('*.asc');

% currentTrial = 1; 
for ascN = 1:size(eyeFiles, 1)                                              % loop over all .asc files
    ascFile = eyeFiles(ascN,1).name;
    rawAsc = load(ascFile);
    for trial = 1:Experiment.const.numTrialsPerBlock(ascN)
        currentTrial = trial+(ascN-1)*Experiment.const.numTrialsPerBlock(ascN);
        startI = find(rawAsc(:, 1)==eventLog.trialStart(currentTrial, 1));
        endI = find(rawAsc(:, 1)==eventLog.trialEnd(currentTrial, 1));
        allData = rawAsc(startI:endI, :);
        save(['t' num2str(currentTrial, '%04d') '.mat'], 'allData')
%         currentTrial = currentTrial+1;
    end
end


end