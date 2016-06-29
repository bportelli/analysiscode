function [] = datafilesetup()

%Make the data files from imported struct

impnames = fieldnames(imported);

for i = 1:length(impnames)
[x y] = regexp(impnames{i},'Sub[\w*]+ssion'); %identifies the text to cut out for the name
data.(impnames{i}([1:x-1,y+1:end])) = imported.(impnames{i});
end


%Make the combined data file
% This can combine up to 7 consecutive files relating to the one block 

ct = fieldnames(data);

newpoints = [];
i=1;
while i < length(ct)
    newpoints = [newpoints,i];
    if all(ct{i}(1:end-1) == ct{i+1}(1:end-1))
        datacomb.(ct{i}(1:end-1)) = [data.(ct{i}); data.(ct{i+1})];
        if all(ct{i+1}(1:end-1) == ct{i+2}(1:end-1))
            datacomb.(ct{i}(1:end-1)) = [datacomb.(ct{i}(1:end-1)); data.(ct{i+2})];
            if all(ct{i+2}(1:end-1) == ct{i+3}(1:end-1))
                datacomb.(ct{i}(1:end-1)) = [datacomb.(ct{i}(1:end-1)); data.(ct{i+3})];
                if all(ct{i+3}(1:end-1) == ct{i+4}(1:end-1))
                    datacomb.(ct{i}(1:end-1)) = [datacomb.(ct{i}(1:end-1)); data.(ct{i+4})];
                    if all(ct{i+4}(1:end-1) == ct{i+5}(1:end-1))
                        datacomb.(ct{i}(1:end-1)) = [datacomb.(ct{i}(1:end-1)); data.(ct{i+5})];
                        if all(ct{i+5}(1:end-1) == ct{i+6}(1:end-1))
                            datacomb.(ct{i}(1:end-1)) = [datacomb.(ct{i}(1:end-1)); data.(ct{i+6})];
                            if all(ct{i+6}(1:end-1) == ct{i+7}(1:end-1))
                                datacomb.(ct{i}(1:end-1)) = [datacomb.(ct{i}(1:end-1)); data.(ct{i+7})];
                            else
                                i=i+7;
                            end
                        else
                            i=i+6;
                        end
                    else
                        i=i+5;
                    end
                else
                    i=i+4;
                end
            else
                i=i+3;
            end
        else
            i=i+2;
        end
    else
        warning(['no match was found for ',ct{i}])
        i=i+1;
    end
end

mcuecomb = mcue(newpoints);
spdcomb = spd(newpoints);


%Make the combined data file TIDIER
% This can combine up to 7 consecutive files relating to the one block 

ct = fieldnames(data);

newpoints = [];
i=1;

namechk = @(i) all(ct{i}(1:end-1) == ct{i+1}(1:end-1));%checks if 2 consecutive files are from same expt

while i < length(ct)
    newpoints = [newpoints,i];
    
    data.(ct{i}(1:end-1)) = []; %Create the file to start receiving... is this correct?? will this clear things?
    
    while namechk(i) %The combination is wrong here... check it.
        datacomb.(ct{i}(1:end-1)) = [data.(ct{i}); data.(ct{i+1})];
        i=i+1
    end
        
        
    end

% function [dout] = newfunc(dfilen,dfilen1)
% 
%     ct{i}(1:end-1) == ct{i+1}(1:end-1)
%     
%     
% end

while i < length(ct)
    newpoints = [newpoints,i];
    if all(ct{i}(1:end-1) == ct{i+1}(1:end-1))
        datacomb.(ct{i}(1:end-1)) = [data.(ct{i}); data.(ct{i+1})];
        if all(ct{i+1}(1:end-1) == ct{i+2}(1:end-1))
            datacomb.(ct{i}(1:end-1)) = [datacomb.(ct{i}(1:end-1)); data.(ct{i+2})];
            if all(ct{i+2}(1:end-1) == ct{i+3}(1:end-1))
                datacomb.(ct{i}(1:end-1)) = [datacomb.(ct{i}(1:end-1)); data.(ct{i+3})];
                if all(ct{i+3}(1:end-1) == ct{i+4}(1:end-1))
                    datacomb.(ct{i}(1:end-1)) = [datacomb.(ct{i}(1:end-1)); data.(ct{i+4})];
                    if all(ct{i+4}(1:end-1) == ct{i+5}(1:end-1))
                        datacomb.(ct{i}(1:end-1)) = [datacomb.(ct{i}(1:end-1)); data.(ct{i+5})];
                        if all(ct{i+5}(1:end-1) == ct{i+6}(1:end-1))
                            datacomb.(ct{i}(1:end-1)) = [datacomb.(ct{i}(1:end-1)); data.(ct{i+6})];
                            if all(ct{i+6}(1:end-1) == ct{i+7}(1:end-1))
                                datacomb.(ct{i}(1:end-1)) = [datacomb.(ct{i}(1:end-1)); data.(ct{i+7})];
                            else
                                i=i+7;
                            end
                        else
                            i=i+6;
                        end
                    else
                        i=i+5;
                    end
                else
                    i=i+4;
                end
            else
                i=i+3;
            end
        else
            i=i+2;
        end
    else
        warning(['no match was found for ',ct{i}])
        i=i+1;
    end
end

mcuecomb = mcue(newpoints);
spdcomb = spd(newpoints);

end