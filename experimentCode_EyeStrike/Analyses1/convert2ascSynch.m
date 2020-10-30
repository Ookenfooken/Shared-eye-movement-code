function convert2ascSynch(sbj)

%% Convert edf to asc for Baseball Data
%  currently ignore all asc files named _e or _s

startFolder = [pwd '\Analyses1\']; %where is the edf2asc program?
dataPath = [pwd '\data\' sbj.filename '\'];

% run edf2asc.exe over the current subject:
[res, stat] = system([startFolder 'edf2asc -y ' dataPath '*.edf']);

% read out Eyelink Messages (provide important time stamps for synchronization):
ascfiles = dir([dataPath '\*.asc']);
syncIndex = [];
for j = 1:length(ascfiles)
ascfile = ascfiles(j).name;
path = fullfile(dataPath, ascfile);
fid = fopen(path);

textscan(fid, '%*[^\n]', 25);
entries = textscan(fid, '%s %s %s %*[^\n]'); 
label = strfind(entries{1}, 'MSG');

for ii = 1:length(label)
    if label{ii} == 1
        switch entries{1,3}{ii}
            case 'SYNCTIME'
                syncIndex(j,1) = str2num(entries{2}{ii});
            case 'FIX_ON'
                syncIndex(j,2) = str2num(entries{2}{ii});
            case 'STIM_ON'
                syncIndex(j,3) = str2num(entries{2}{ii});
            case 'STIM_OCCLUDED'
                syncIndex(j,4) = str2num(entries{2}{ii});
            case 'STIM_REAPPEAR'
                syncIndex(j,5) = str2num(entries{2}{ii});
            case 'INTERCEPT'
                syncIndex(j,6) = str2num(entries{2}{ii});
        end

    end
end
%     idx = find(not(cellfun('isempty', label)));
%      
%     convert2ascSynch(sbj)
%     syncIndex(j,1) = idx(1);
%     syncIndex(j,2) = idx(2);
%     syncIndex(j,3) = idx(3);
%     syncIndex(j,4) = idx(4);        
fclose(fid);
end
cd(dataPath)
save('syncIndex', 'syncIndex')
cd(startFolder)
[res, stat] = system([startFolder 'edf2asc -y -s -miss 9999 -nflags ' dataPath '\*.edf']);

end