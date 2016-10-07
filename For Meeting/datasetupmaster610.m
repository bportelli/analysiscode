%% The Master Script to Setup data files for analysis

% This one handles multiple tables, doesn't combine files, and skips standard error calculations

%Constants

loadsettings; %Loads the settings struct

%% The Setup Loop
%Set up participant data files, one participant (all datafiles) per loop

disp('Running pp setup loop...')

exptnum = input('Type in the Study #...\n');

more = input('Set up a pp data file? y/n \n','s');
while 1
    if lower(more) == 'y'    
    
        [imported, indvars, pn, ppcode] = readfilefunc610(exptnum, settings); %import the Psykinematix outputs from "New Discrimination" tables.
        %This funtion outputs imported: a struct of all data tables (one per expt
        %file) and indvars, the levels of the IV's, one per file
                
        [data, indvars] = datafilesetup610(imported, indvars); %make the data and combined data tables
        
        save([pn ppcode '.mat'],'exptnum','-append') %save the exptnum, for accessing settings in future
        save([pn ppcode '.mat'],'data', 'indvars','-append') %save the new outputs
        
        curr_mat_loc = [pn ppcode]; %current mat file location... to make the next step easier
        
        clc; close all; clearvars -EXCEPT settings exptnum curr_mat_loc
    else
        break
    end
    more = input('Set up another pp data file? y/n \n','s');
end

%% The analysis MAT file choice loop
% Select .mat files to analyse, then analyse them

disp('Beginning MAT file choice loop...')
disp('Select a MAT file to analyse...')

if ~exist('curr_mat_loc','var')
curr_mat_loc = [];
end

mat = 0;
more = 'y';
while 1
    if or(more == 'y', more == 'Y')
        mat = mat+1;
        [fn, pn] = uigetfile('.mat',curr_mat_loc); %Needs to be in a loop because it doesn't handle multiple pn's (??)
        fn = gfcheck(fn,'char');
        Mats{mat} = [pn fn];
        copyfile('C:\Users\bjp4\Documents\MATLAB\Study 3 Analysis\Folder structure',pn) %NB: Copy the Folder Structure to pn
    else
        break
    end
    more = input('Analyse another mat file? y/n \n','s');
end

if mat == 0 % Script-writing error checker; ends the script if no MAT files are selected (mat == 0 should be impossible by this point)
    error('NO MAT FILES SELECTED. THIS SHOULD NOT BE POSSIBLE.')
end

%% Analysis loop
disp('Beginning analysis loop...')

%%Variable and function setup
addpath(genpath('C:\Users\bjp4\Documents\MATLAB\Toolboxes')); %Make sure the Toolboxes are active

% Run the analysis! This will produde the plots and excel files
analyse(Mats, settings, 'comb'); %combined data files first
analyse(Mats, settings, 'sep');

