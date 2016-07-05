%% The Master Script to Setup data files for analysis

%% The Setup Loop
%Set up participant data files, one participant (all datafiles) per loop

disp('Running pp setup loop...')

more = input('Set up a pp data file? y/n \n','s');
while 1
    if or(more == 'y', more == 'Y')
        
        
        keywds = {' MiD ',' L ','CD_','IOVD_','full_'}; %This is searched for in the expt file name
        mcuelist = {'MID','LAT','CD','IOVD','FULL'}; %These two variables must correspond
        
        keywdsspd = {'spd0.3','spd0.9','spd2'};
        spdlist = [0.3,0.9,2];
        
        ivtables = %THIS IS A CELL ARRAY WITH AN IV TABLE IN EACH CELL
        
%Make Readfilescript into a function that takes in number of IV's and their lookuptables and detects them, freeing up the analysis function from needing to do any detection
        
        
        readfilefunc(2, ivtables) %import the Psykinematix outputs from "New Discrimination" tables.
        %readfile func takes an input of 2: the number of IV's
        
        %datafilesetup will now take (imported, ivlists) as its input.
        %ivlists is a cell array, each cell being a list of ivs
        %corresponding to each expt file
        [data, datacomb, mcuecomb, spdcomb, newpoints] = datafilesetup(imported, mcue, spd); %make the data and combined data tables
        
        save([pn ppcode '.mat'],'data', 'datacomb', 'mcuecomb', 'spdcomb', 'newpoints','-append') %save the new outputs
        
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

% [] = analyse(sizecvt, contcvt, Mats, IVs); %analyse function here... this will produde the plots and excel files

