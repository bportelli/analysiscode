%% Master Analysis Function (initially written for Study 4)
% NB: Analysis of Demos is currently commented out

function [NAMES] = master4()
%% Constants And Variable Setup
%StudyDir = 'C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\COMPLETED';
% StudyDir = 'C:\Users\bjp4\Documents\MATLAB\Study 5 Analysis\COMPLETED';
StudyDir = 'C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\Participants';
% StudyDir = 'C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\Creating new function test materials';

if ~exist('StudyDir','var')
StudyDir = uigetdir('.','Choose the dir that holds participant folders for this study');
end

% Section Names and Order:
SECT = {'RivalryRead', 'ReadIn','SingleRuns','Demos','AddColstoSingle','CombinedSetup','CombinedAna','AddCols'};

% Get Names and Participant Directories
NAMES = getNames(StudyDir);

if isempty(NAMES) % End function elegantly if cancelled here
   return 
end

for k = 1:length(NAMES)
    ampn(k)= {[StudyDir '\' NAMES{k}]};
end


%% Which parts of this function should be run?
s1 = querySections(SECT);
if isempty(s1) % End function elegantly if cancelled here
   return 
end

SectionsRunning = SECT(s1);

%% Set up Sections that Need it

% If analysis is running, will this be with Parametric bootstrap?
% if any([s1==2,s1==6])
if sum(ismember(SectionsRunning,'CombinedAna')) == 1
    bootstra = masterQueryBoots();
end

% If combining files.... combine by experiment code, or by IV's?
if sum(ismember(SectionsRunning,'CombinedSetup')) == 1
    combiMethod = masterQueryCombi(); %Method 1 is by Expt ID, 0 is by Independent Variables
end


%% Read Rivalry Tables In
rivrun = 0;
if sum(ismember(SectionsRunning,'RivalryRead')) == 1
    rivrun = 1;
    for k = 1:length(ampn)
        disp('PLEASE SELECT THE DATAFILE(S) CONTAINING RIVALRY DATA IN:')
        disp(ampn{k})
        riv.fn = getTXTfile(ampn{k});
        riv.pn = [ampn{k} '\'];
        %[riv.fn, riv.pn] = uigetfile('.txt','MultiSelect','On');
        [riv.fn] = gfcheck(riv.fn,'cell'); %'cell' specifies that fn should be a cell array
        folderSetup(riv.pn); % Set up the folder structure
        rivalryRead(riv.fn, riv.pn);
    end
    clear riv
end

%% Read tables in (not rivalry)
if sum(ismember(SectionsRunning,'ReadIn')) == 1
    for k = 1:length(ampn)
        disp('Please select the datafiles *NOT* containing rivalry data in:')
        disp(ampn{k})
        rd.fn = getTXTfile(ampn{k});
        rd.pn = [ampn{k} '\'];
        %[rd.fn, rd.pn] = uigetfile('.txt','MultiSelect','On');
        [rd.fn] = gfcheck(rd.fn,'cell'); %'cell' specifies that fn should be a cell array
        if rivrun == 0 % Set up the folder structure, if this hasn't been done
            folderSetup(rd.pn);
        end
        read_in_tables_removeold(rd.fn, rd.pn);
    end
    clear rd
end

%% Single runs
%Analyse and produce quick plots

% If there is only one MAT file use it, otherwise prompt
[fnm, pnm] = getAddress(ampn,'.mat');

if sum(ismember(SectionsRunning,'SingleRuns')) == 1
    % Add Palamedes to path
    PALpath = 'C:\Users\bjp4\Documents\MATLAB\Toolboxes'; % Palamedes is assumed to be in here
    if exist(PALpath,'dir')
    addpath(genpath(PALpath)); % If it exists, then add it to the Matlab Path
    end
    % Run analysis
    for k = 1:length(ampn)
        %[fnm{k}, pnm{k}] = uigetfile(ampn{k}); % Not needed bec of previous step
        load([pnm{k} fnm{k}],'data', 'expName', 'expDateSess', 'readID', 'pn')
        disp(ampn{k})
        analyse710_auto(data, expName, expDateSess, readID, pnm{k},NAMES{k},0,0) % THIS ALSO DOES COLLECTING NOW
        clear 'data' 'expName' 'expDateSess' 'readID' 'pn'
    end
    
end


%% Demos
%Produce plots for the demo file results
% CAUTION: remove the "clear" bit from here before using!!

% if sum(ismember(SectionsRunning,'Demos')) == 1
% whoHasDemos = [12,14,15]; %First, find out who has demos (numbered according to position in ampn)
% for k = whoHasDemos;
%     disp(ampn{k})
%     demo_files(ampn{k})
%     clearvars -EXCEPT k ampn
% end
% end

%% Adding Columns to Single - Width, Contrast, Speed
%regex process 'reads' the experiment names and identifies the IV's

if sum(ismember(SectionsRunning,'AddColstoSingle')) == 1
    for pp = 1:length(NAMES)
        tata = readtable([StudyDir '\' NAMES{pp} '\Incoming\collectedTable.xls']);
        tataO = extractWCS(tata);
        writetable(tataO,[StudyDir '\' NAMES{pp} '\' NAMES{pp} '_SingleRuns.xlsx']);
        clear tata tataO
    end
end


%% Combined SETUP
%Set up the combined data files

if sum(ismember(SectionsRunning,'CombinedSetup')) == 1
    for k = 1:length(ampn)
        if exist('fnm','var')
            fn = fnm{k};pn = pnm{k}; %Just get them from before
        else
            [fn, pn] = uigetfile(ampn{k});
        end
        disp(ampn{k})
        combisetup(pn, fn, combiMethod)
        clear pn fn
    end
end

%% Combined Analyse
if sum(ismember(SectionsRunning,'CombinedAna')) == 1
    for k = 1:length(ampn)
        
        if exist('fnm','var')
            fn = fnm{k};pn = pnm{k}; %Just get them from before
        else
            [fn, pn] = uigetfile(ampn{k});
        end
        
        load([pn fn],'datacomb', 'expName_comb', 'expDateSess_comb', 'readID', 'pn')
        disp(ampn{k})
        analyse710_auto(datacomb, expName_comb, expDateSess_comb, readID, pn, NAMES{k},1,bootstra)
        clear 'datacomb' 'expName_comb' 'expDateSess_comb' 'readID' 'pn'
    end
    
end

%collect CURRRENTLY ADAPTED TO COMBI
%collect(ampn(13:15))

%% Adding Columns - Width, Contrast, Speed
%regex process 'reads' the experiment names and identifies the IV's

if sum(ismember(SectionsRunning,'AddCols')) == 1
    for pp = 1:length(NAMES)
        tata = readtable([StudyDir '\' NAMES{pp} '\Combined\collectedTable.xls']);
        tataO = extractWCS(tata);
        writetable(tataO,[StudyDir '\' NAMES{pp} '\' NAMES{pp} '.xlsx']);
        clear tata tataO
    end
end

%% Sub-functions

%RETIRED FUNCTION, NOW USING THE ONE IN THE FOLDER
%     function NAMES = getNames(StudyDir) 
%         d=dir(StudyDir);
%         str = {d.name};
%         str = str(cellfun('isempty',regexp(str,'\.'))); % removes anything that isn't a folder (things that aren't folders have a dot)
%         [s,~] = listdlg('PromptString','Select a participant:',...
%             'SelectionMode','multiple',...
%             'ListString',str);
%         NAMES = str(s);
%     end

    function txtnames = getTXTfile(dire) 
        d=dir(dire);
        str = {d.name};
        str = str(~(cellfun('isempty',regexp(str,'\.txt')))); % removes anything that isn't a txt file
        [s,~] = listdlg('PromptString','Select a txt file:',...
            'SelectionMode','multiple',...
            'ListString',str);
        txtnames = str(s);
    end

% Create empty folder structure
%copyfile('C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\Folder structure',pn)
    function [] = folderSetup(pn)
        folN = {'Fitting','Outputs','Plots','Combined','Incoming'};
        for ff = 1:length(folN)
            mkdir(pn,folN{ff})
            if ff == 4 % If Combined
                for ff2 = 1:3
                    mkdir([pn 'Combined\'],folN{ff2})
                end
            end
        end
    end

    function s1 = querySections(s)
        [s1,~] = listdlg('PromptString','Which sections to run:',...
            'SelectionMode','multiple',...
            'ListString',s);
    end

    function bootstra = masterQueryBoots()
        % Construct a questdlg with three options
        bootchoice = questdlg('Parametric Bootstrap?', ...
            'Bootstrap', ...
            'Yes','No','No');
        % Handle response
        switch bootchoice
            case 'Yes'
                bootstra = 1;
            case 'No'
                bootstra = 0;
        end
    end

    function combiMethod = masterQueryCombi()
        % Construct a questdlg with three options
        bootchoice = questdlg('Perform combination by...', ...
            'File Combination Setup', ...
            'ExptID','IndepVars','ExptID');
        % Handle response
        switch bootchoice
            case 'ExptID'
                combiMethod = 1;
            case 'IndepVars'
                combiMethod = 0;
        end
    end

% RETIRED FUNCTION, NOW USING THE ONE IN FOLDER: [fnm, pnm] = getAddress(ampn,fSuff)
%     function [fnm, pnm] = getMATaddress()
%         for k1 = 1:length(ampn)
%             % if there is only one MAT file, use it, otherwsise prompt
%             d1=dir(ampn{k1});
%             matIx = regexp({d1.name},'.mat'); %where's the MAT
%             matIx = ~[cellfun(@isempty,matIx)];
%             
%             if sum(matIx)==1 %If there's only one, use it
%                 pnm{k1} = [ampn{k1} '\']; fnm{k1} = d1(matIx).name;
%             else
%                 [fnm{k1}, pnm{k1}] = uigetfile(ampn{k1});
%             end
%         end
%     end


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


