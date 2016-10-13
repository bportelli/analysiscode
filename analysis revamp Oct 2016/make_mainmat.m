%% Reconnect Mat files to their main MAT file

k = 1;
m = 1;
while m % Collect MAIN directories with MAT files
pn{k} = uigetdir();
k = k+1;
m = input('Input 1 to get another directory...\n');
end

% OR load pn from C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\Pilots
% organised (for meeting)\allmats.mat

for k = 1:length(pn)
for ff = 1:length(pn)
    mList = ls(pn{k});
    for mii = 3:size(mList,1)
    
    currFile = strtrim(mList(mii,:)); %remove leading or trailing whitespace
    
    if strfind(currFile,['.','mat']) > 0 %If it's a MAT file...
        mainName = currFile(1:regexp(currFile,'\.mat')-1);
    end
    
    end
clear mList
end
end

for k = 1:length(pn)

    incomingDir = [pn{k} '\Combined\'];
    
List = ls(incomingDir); % List all files in pn
inputFormat = 'mat';

for ii = 3:size(List,1)
    
    currFile = strtrim(List(ii,:)); %remove leading or trailing whitespace
    
    if strfind(currFile,['.',inputFormat]) > 0 %If it's a MAT file...
        disp(['Inserting into ',currFile])
        
        save([incomingDir currFile],'mainName','-append')
		
    end
    
end

disp('Appending complete')

end