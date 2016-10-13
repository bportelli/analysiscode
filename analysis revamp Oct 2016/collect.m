
matID = [sprintf('%0.0f',clock) '_allTogether'];

k = 1;
m = 1;
while m % Collect directories with files to combine
pn{k} = uigetdir();
k = k+1;
m = input('Input 1 to get another directory...\n');
end

for k = 1:length(pn)
    
savedir = [pn{k} '\COLLECTED\'];
mkdir(savedir) % Create the folder to receive the converted files

List = ls(pn{k}); % List all files in pn
inputFormat = 'mat';

% Set up EMPTY TABLE
Tcom = [];

for ii = 3:size(List,1)
    
    currFile = strtrim(List(ii,:)); %remove leading or trailing whitespace
    
    if strfind(currFile,['.',inputFormat]) > 0 %If it's a MAT file...
        disp(['Collecting ',currFile])
		load([pn currFile '\' '.mat'], 'T1','expName');
		
		%% Put in some code to collect the ExpName into the table too
		
		%Then...
				Tcom = [Tcom; T1]; %Add table to collection
		
    end
    
end

save([savedir '\' matID],'Tcom') %save MAT
writetable(Tcom,[savedir '\' matID,'.csv'])

disp('Collection complete')

end