%% Master Analysis Function for Study 4
% NB: Analysis of Demos is currently commented out

function [NAMES] = master4()
%% Constants And Variable Setup
StudyDir = 'C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\COMPLETED';

% Get Names and Participant Directories
d=dir(StudyDir);
str = {d.name};
[s,v] = listdlg('PromptString','Select a file:',...
    'SelectionMode','multiple',...
    'ListString',str);
NAMES = str(s);

for k = 1:length(NAMES)
    ampn(k)= {[StudyDir '\' NAMES{k}]};
end

%% Which parts of this function should be run?

sect = {'ReadIn','SingleRuns','Demos','CombinedSetup','CombinedAna','AddCols'};
[s1,~] = listdlg('PromptString','Which sections to run:',...
    'SelectionMode','multiple',...
    'ListString',sect);

%% Read tables in
if any(s1==1)
    readTablesIn()
end

%% Single runs
%Analyse and produce quick plots

if any(s1==2)
    % Add Palamedes to path
    addpath(genpath('C:\Users\bjp4\Documents\MATLAB\Toolboxes'));
    [fnm, pnm] = SingleRuns();
end


%% Demos
%Produce plots for the demo file results
% CAUTION: remove the "clear" bit from here before using!!

% if any(s1==3)
% whoHasDemos = [12,14,15]; %First, find out who has demos (numbered according to position in ampn)
% for k = whoHasDemos;
%     disp(ampn{k})
%     demo_files(ampn{k})
%     clearvars -EXCEPT k ampn
% end
% end

%% Combined SETUP
%Set up the combined data files

if any(s1==4)
    for k = 1:length(ampn)
        
        if exist(fnm,'var')
            fn = fnm{k};pn = pnm{k}; %Just get them from before
        else
            [fn, pn] = uigetfile(ampn{k});
        end
        
        disp(ampn{k})
        combisetup(pn, fn)
        clear pn fn
    end
end

%% Combined Analyse
if any(s1==5)
for k = 1:length(ampn)
    
    if exist(fnm,'var')
        fn = fnm{k};pn = pnm{k}; %Just get them from before
    else
        [fn, pn] = uigetfile(ampn{k});
    end
    
    load([pn fn],'datacomb', 'expName_comb', 'expDateSess_comb', 'readID', 'pn')
    disp(ampn{k})
    analyse710_auto(datacomb, expName_comb, expDateSess_comb, readID, pn, NAMES{k},1)
    clear 'datacomb' 'expName_comb' 'expDateSess_comb' 'readID' 'pn'
end

end

%collect CURRRENTLY ADAPTED TO COMBI
%collect(ampn(13:15))

%% Adding Columns - Width, Contrast, Speed
%regex process 'reads' the experiment names and identifies the IV's

if any(s1==6)
for pp = 1:length(NAMES)
    tata = readtable(['C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\COMPLETED\' NAMES{pp} '\Combined\collectedTable.xls']);
    tataO = extractWCS(tata);
    writetable(tataO,['C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\COMPLETED\' NAMES{pp} '\' NAMES{pp} '.xlsx']);
    clear tata tataO
end
end

%% Sub-functions

    function readTablesIn()
        for k = 1:length(ampn)
            disp(ampn{k})
            read_in_tables_removeold();
        end
    end


    function [fnm, pnm] = SingleRuns()
        for k = 1:length(ampn)
            [fnm{k}, pnm{k}] = uigetfile(ampn{k});
            load([pnm{k} fnm{k}],'data', 'expName', 'expDateSess', 'readID', 'pn')
            disp(ampn{k})
            analyse710_auto(data, expName, expDateSess, readID, pnm{k},NAMES{k},0) % THIS ALSO DOES COLLECTING NOW
            clear 'data' 'expName' 'expDateSess' 'readID' 'pn'
        end
    end

end

%% Old Code
%
% % Collect directories with files to use
% k = 1;
% m = 1;
% while m
%     ampn{k} = uigetdir();
%     k = k+1;
%     m = input('Input 1 to get another directory...\n');
% end


