
matID = [sprintf('%0.0f',clock) '_allTogether'];

k = 1;
m = 1;
while m % Collect directories with files to combine
pn{k} = uigetdir();
k = k+1;
m = input('Input 1 to get another directory...\n');
end

for k = 1:length(pn)
    
savedir = [pn{k} '\COMBINED\'];
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





%%

data = imported; %Much more straightforward for now...

%Make the combined data file (TIDIER code)

ct = fieldnames(data);
namechk = @(i) all(ct{i}(1:end-1) == ct{i+1}(1:end-1)); %checks if 2 consecutive files are from same expt

newpoints = 1;
for i=1:(length(ct)-1)
    if length(ct{i}) == length(ct{i+1})
        if namechk(i)
            continue
        end
    end
        newpoints = [newpoints,i+1];
end

dce = struct2cell(data); %data in a cell

for c = 1:length(newpoints) %loop counter
    n = newpoints(c); %current newpoint
    j=1; %to make sure to stop adding tables before the next newpoint/end
    if n == newpoints(end) %do this for the last batch of files (from last newpoint to end)
        while j+n<=length(dce)
            dce{n} = [dce{n};dce{n+j}];
            j=j+1;
        end
    else %do this for all the other expt files belonging together (from one newpoint, to file just before the next one)
        while j+n<newpoints(c+1)
            dce{n} = [dce{n};dce{n+j}];
            j=j+1;
        end
    end
end

for d = newpoints %make the datacomb struct
    datacomb.(ct{d}(1:end-2)) = dce{d};
end

for iv = 1:length(indvars) 
    indvars(iv).levelscomb = indvars(iv).levels(newpoints); %make a list of the levels of iv's of the combined datafiles
end

end