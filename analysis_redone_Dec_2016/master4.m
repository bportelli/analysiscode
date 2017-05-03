%% Master Analysis Function (initially written for Study 4)
% NB: Analysis of Demos is currently commented out

function [NAMES] = master4()
%% Constants And Variable Setup
%StudyDir = 'C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\COMPLETED';
StudyDir = 'C:\Users\bjp4\Documents\MATLAB\Study 5 Analysis\COMPLETED';

% Section Names and Order:
% {'ReadIn','SingleRuns','Demos','AddColstoSingle','CombinedSetup','CombinedAna','AddCols'};


% Get Names and Participant Directories
NAMES = getNames();

for k = 1:length(NAMES)
    ampn(k)= {[StudyDir '\' NAMES{k}]};
end


%% Which parts of this function should be run?
s1 = querySections();

%% Set up Sections that Need it

% If analysis is running, will this be with Parametric bootstrap?
% if any([s1==2,s1==6])
if any([s1==6])
    bootstra = masterQueryBoots();
end

% If combining files.... combine by experiment code, or by IV's?
if any(s1==5)
    combiMethod = masterQueryCombi(); %Method 1 is by Expt ID, 0 is by Independent Variables
end

%% Read tables in
if any(s1==1)
    for k = 1:length(ampn)
        disp(ampn{k})
        read_in_tables_removeold();
    end
end

%% Single runs
%Analyse and produce quick plots

% If there is only one MAT file use it, otherwise prompt
[fnm, pnm] = getMATaddress();

if any(s1==2)
    % Add Palamedes to path
    addpath(genpath('C:\Users\bjp4\Documents\MATLAB\Toolboxes'));
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

% if any(s1==3)
% whoHasDemos = [12,14,15]; %First, find out who has demos (numbered according to position in ampn)
% for k = whoHasDemos;
%     disp(ampn{k})
%     demo_files(ampn{k})
%     clearvars -EXCEPT k ampn
% end
% end

%% Adding Columns to Single - Width, Contrast, Speed
%regex process 'reads' the experiment names and identifies the IV's

if any(s1==4)
    for pp = 1:length(NAMES)
        tata = readtable([StudyDir '\' NAMES{pp} '\Incoming\collectedTable.xls']);
        tataO = extractWCS(tata);
        writetable(tataO,[StudyDir '\' NAMES{pp} '\' NAMES{pp} '_SingleRuns.xlsx']);
        clear tata tataO
    end
end


%% Combined SETUP
%Set up the combined data files

if any(s1==5)
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
if any(s1==6)
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

if any(s1==7)
    for pp = 1:length(NAMES)
        tata = readtable([StudyDir '\' NAMES{pp} '\Combined\collectedTable.xls']);
        tataO = extractWCS(tata);
        writetable(tataO,[StudyDir '\' NAMES{pp} '\' NAMES{pp} '.xlsx']);
        clear tata tataO
    end
end

%% Sub-functions

    function NAMES = getNames()
        d=dir(StudyDir);
        str = {d.name};
        [s,~] = listdlg('PromptString','Select a file:',...
            'SelectionMode','multiple',...
            'ListString',str);
        NAMES = str(s);
    end

    function s1 = querySections()
        sect = {'ReadIn','SingleRuns','Demos','AddColstoSingle','CombinedSetup','CombinedAna','AddCols'};
        [s1,~] = listdlg('PromptString','Which sections to run:',...
            'SelectionMode','multiple',...
            'ListString',sect);
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


    function [fnm, pnm] = getMATaddress()
        for k1 = 1:length(ampn)
            % if there is only one MAT file, use it, otherwsise prompt
            d1=dir(ampn{k1});
            matIx = regexp({d1.name},'.mat'); %where's the MAT
            matIx = ~[cellfun(@isempty,matIx)];
            
            if sum(matIx)==1 %If there's only one, use it
                pnm{k1} = [ampn{k1} '\']; fnm{k1} = d1(matIx).name;
            else
                [fnm{k1}, pnm{k1}] = uigetfile(ampn{k1});
            end
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


