%% Fixes (and Converts) the X axis on FIG files (to a range of min-max Xtick) and saves them...
%... in the listed directories in the cell pn
% new files are saved to a new folder (fixed)

k = 1;
m = 1;
while m % Collect directories with files to convert
pn{k} = uigetdir();
k = k+1;
m = input('Input 1 to get another directory...\n');
end

for k = 1:length(pn)
    
savedir = [pn{k} '\fixed\'];
mkdir(savedir) % Create the folderto receive the converted files

List = ls(pn{k}); % List all files in pn
inputFormat = 'fig';
outputFormat = 'png';

for ii = 3:size(List,1)
    
    currFile = strtrim(List(ii,:)); %remove leading or trailing whitespace
    
    if strfind(currFile,['.',inputFormat]) > 0 %If it's a FIG file...
        disp(['Fixing ',currFile])
        h=openfig([pn{k} '\' currFile],'new','invisible');
        ha = findobj(h,'Type','Axes');
        set(ha,'Xlim',[min(get(ha,'Xtick')) max(get(ha,'Xtick'))]);
        outputName = currFile(1:end-length(inputFormat)-1);
        saveas(h,[savedir outputName],outputFormat) %... save it as a PNG
        close(h);
    end
    
end

disp('Fixing complete')

end