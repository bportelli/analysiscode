function [fnm, pnm] = getAddress(ampn,fSuff)
    %ampn = list of dir addresses, fSuff = file suffix (include extension)
        for k1 = 1:length(ampn)
            % if there is only one file with that suffix, use it, otherwsise prompt
            d1=dir(ampn{k1});
            matIx = regexp({d1.name},fSuff); %where's the (MAT) file
            matIx = ~[cellfun(@isempty,matIx)];
            
            if sum(matIx)==1 %If there's only one, use it
                pnm{k1} = [ampn{k1} '\']; fnm{k1} = d1(matIx).name;
            else
                [fnm{k1}, pnm{k1}] = uigetfile(ampn{k1});
            end
        end
    end