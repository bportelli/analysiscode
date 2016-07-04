function [data, datacomb, mcuecomb, spdcomb, newpoints] = datafilesetup(imported, mcue, spd)
%Make the data files and combined data files from imported struct
%Also outputs the new mcue and spd lists for combi data files, and the
%newpoints
%NB: mcue and spd lists are a list of each mcue and spd, corresponding to
%each data file

%Make the data files from imported struct

impnames = fieldnames(imported);

for i = 1:length(impnames)
[x y] = regexp(impnames{i},'Sub[\w*]+ssion'); %identifies the text to cut out for the name
data.(impnames{i}([1:x-1,y+1:end])) = imported.(impnames{i});
end

%Make the combined data file (TIDIER code)

ct = fieldnames(data);
namechk = @(i) all(ct{i}(1:end-1) == ct{i+1}(1:end-1)); %checks if 2 consecutive files are from same expt

newpoints = 1;
for i=1:(length(ct)-1)
    if namechk(i)
        continue
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
    datacomb.(ct{d}(1:end-1)) = dce{d};
end

mcuecomb = mcue(newpoints); %make a list of the mcues of the combined datafiles
spdcomb = spd(newpoints);

end