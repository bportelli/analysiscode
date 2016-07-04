%% The Master Script to Setup data files for analysis

while 1  
more = input('Set up (another) pp file? y/n \n','s');
    
if more == 'y'

Readfilescript %import the Psykinematix outputs from "New Discrimination" tables
[data, datacomb, mcuecomb, spdcomb, newpoints] = datafilesetup(imported, mcue, spd); %make the data and combined data tables

save([pn ppcode '.mat'],'data', 'datacomb', 'mcuecomb', 'spdcomb', 'newpoints','-append') %save the new outputs
ccc

else
return    
end
end
%Run the analysis