%% COLLECT RESULTS INTO ONE TABLE FOR 1 EXPT AND PP

matID = [sprintf('%0.0f',clock) '_allTogether'];

% k = 1;
% m = 1;
% while m % Collect directories with files to combine
% pn{k} = uigetdir();
% k = k+1;
% m = input('Input 1 to get another directory...\n');
% end

% load('C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\Pilots organised (for meeting)\allmats.mat','pn')

for k = 1:length(pn)
    
savedir = [pn{k} '\COLLECTED\'];
mkdir(savedir) % Create the folder to receive the converted files

List = ls(pn{k}); % List all files in pn
inputFormat = 'mat';

% Set up EMPTY TABLE
Tcoll = [];

for ii = 3:size(List,1)
    
    currFile = strtrim(List(ii,:)); %remove leading or trailing whitespace
    
    if strfind(currFile,['.',inputFormat]) > 0 %If it's a MAT file...
        disp(['Collecting ',currFile])
        
        rootDir = [pn{k} '\' currFile]; % WITH THE CURRENT ARRANGEMENT, the RootDir comes from pn... so this needs to be the other way around??
        rootDir = rootDir(1:regexp(rootDir,'\\Incoming'));
        
		load([pn{k} '\' currFile], 'T1','mainName');
        load([rootDir mainName],'expName');
        
		%% Put in some code to collect the ExpName into the table too
        % MAKE FIRST COLUMN expName, sorted by the 5-7??th chars of expName??
		
        T2 = cell2table('');
        
		%Then...
				Tcoll = [Tcoll; T1]; %Add table to collection
		
    end
    
end

save([savedir '\' matID],'Tcom') %save MAT
writetable(Tcoll,[savedir '\' matID,'.csv'])

disp('Collection complete')

end