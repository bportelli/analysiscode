%function [data] = datafilesetup610(imported)
%Make the data files and combined data files from imported struct
%Also outputs the new mcue and spd lists for combi data files, and the
%newpoints
%NB: mcue and spd lists are a list of each mcue and spd, corresponding to
%each data file

%Make the data files from imported struct

impnames = fieldnames(imported);

for i = 1:length(impnames)
[x, y] = regexp(impnames{i},'Sub[\w*]+ssion'); %identifies the text to cut out for the name
data.(impnames{i}([1:x-1,y+1:end])) = imported.(impnames{i});
end

save([pn ppcode '.mat'],'data','-append') %save the new outputs

%end