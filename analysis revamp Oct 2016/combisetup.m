function [] = combisetup(ipn, ifn)

load([ipn ifn],'data','expName','expDateSess','readID','pn');

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
    datacomb.(ct{d}(1:end-1)) = dce{d};
end

expName_comb = expName(newpoints);
expDateSess_comb = expDateSess(newpoints);

save([pn readID '.mat'],'datacomb','expName_comb','expDateSess_comb','-append')

end
