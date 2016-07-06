%% The Master Script to Setup data files for analysis

%% The Setup Loop
%Set up participant data files, one participant (all datafiles) per loop

disp('Running pp setup loop...')

exptnum = 3; %Data from Experiment 3 is being analysed, so settings for Expt 3 will be used

%settings(3) is settings for expt 3
settings(3).ivs = 2; %there are 2 ivs (mcue and spd)
settings(3).thv = 'Motion Coherence'; %mv is the 'thresholded variable'
%ivtables(1) is mcue
settings(3).ivtables(1).keywds = {' MiD ',' L ','CD_','IOVD_','full_'}; 
settings(3).ivtables(1).list = {'MID','LAT','CD','IOVD','FULL'};
%ivtables(2) is spd
settings(3).ivtables(2).keywds = {'spd0.3','spd0.9','spd2'}; 
settings(3).ivtables(2).list = [0.3,0.9,2];


more = input('Set up a pp data file? y/n \n','s');
while 1
    if or(more == 'y', more == 'Y')
                
%Make Readfilescript into a function that takes in number of IV's and their lookuptables and detects them, freeing up the analysis function from needing to do any detection
        
        [imported, indvars] = readfilefunc(exptnum, settings); %import the Psykinematix outputs from "New Discrimination" tables.
        %This outputs imported: a struct of all data tables (one per expt
        %file) and indvars, the levels of the IV's, one per file
                
        [data, datacomb, indvars, newpoints] = datafilesetup(imported, indvars); %make the data and combined data tables
        
        save([pn ppcode '.mat'],'exptnum', 'settings','-append') %save the settings
        save([pn ppcode '.mat'],'data', 'datacomb', 'indvars', 'newpoints','-append') %save the new outputs
        
        ccc
    else
        break
    end
    more = input('Set up another pp data file? y/n \n','s');
end

%% The analysis MAT file setup loop
% Select .mat files to analyse, then analyse them

disp('Beginning anaylsis MAT file setup loop...')
disp('Select a MAT file to analyse...')

mat = 0;
more = 'y';
while 1
    if or(more == 'y', more == 'Y')
        mat = mat+1;
        [fn, pn] = uigetfile('.mat');
        Mats{mat} = [pn fn];
        copyfile('C:\Users\bjp4\Documents\MATLAB\Study 3 Analysis\Folder structure',pn) %NB: Copy the Folder Structure to pn
    else
        break
    end
    more = input('Analyse another mat file? y/n \n','s');
end

if mat == 0 % Ends the script if no MAT files are selected
    warning('NO MAT FILES SELECTED')
    return
end

%% Analysis loop
disp('Beginning analysis loop...')

%%Variable and function setup
addpath(genpath('C:\Users\bjp4\Documents\MATLAB\Toolboxes')); %Make sure the Toolboxes are active

%Number of IV's

IVs = 2;

% Table of size code - size value (chars 4:5 of the coded name)
sizecvt = {'15',1.5;'03',3;'05',5};

% Table of contrast code - contrast value (chars 6:7 of the coded name)
contcvt = {'03',3;'92',92};

% with the coming updates, sizecvt and contcvt should not be needed here as
% lists will be made

% [] = analyse(sizecvt, contcvt, Mats, IVs); %analyse function here... this will produde the plots and excel files

