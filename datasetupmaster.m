%% The Master Script to Setup data files for analysis

%% The Setup Loop
%Set up participant data files, one participant (all datafiles) per loop

while 1  
more = input('You are about to set up (another) pp data file. Continue? y/n \n','s');
    
if more == 'y'

Readfilescript %import the Psykinematix outputs from "New Discrimination" tables

[data, datacomb, mcuecomb, spdcomb, newpoints] = datafilesetup(imported, mcue, spd); %make the data and combined data tables

save([pn ppcode '.mat'],'data', 'datacomb', 'mcuecomb', 'spdcomb', 'newpoints','-append') %save the new outputs

ccc

else
    break
end
end

%% The analysis loop
% Select .mat files to analyse, then analyse them

mat = 0;
while 1
    more = input('Analyse another mat file? y/n \n','s'); %Gather up some Mat files for analysin'
    if more == 'y'
        mat = mat+1;
        [fn, pn] = uigetfile('.mat');
        Mats{mat} = [pn fn];
    else
        break
    end
end

if mat == 0 % Ends the script if no MAT files are selected
    warning('NO MAT FILES SELECTED')
    return
end



