function [] = combisetup(ipn, ifn, combiMethod)
%% Set up the datafiles for anakysis (combine the datafiles perftaining to the same condition).
% combiMethod  value of 1 is "combine by EXperiment ID", 0 is "combine by identical IVs"

load([ipn ifn],'data','expName','expDateSess','readID','pn'); % load MAT file

ct = fieldnames(data);

if combiMethod % if combining by identical Experiment ID...
    namechk = @(i) all(ct{i}(1:end-1) == ct{i+1}(1:end-1)); %checks if 2 consecutive files are from same expt per Psykinematix numbering (i.e. "_short" files are not combined)
    
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
    
else %if Combining by Identical IV's
    
    % if there is only one XLSX file, use it, otherwsise prompt
    d1=dir(ipn);
    xlsxIx = regexp({d1.name},'.xlsx'); %where's the XLSX?
    xlsxIx = ~[cellfun(@isempty,xlsxIx)];
    
    if sum(xlsxIx)==1 %If there's only one, use it
        pnm = ipn; fnm = d1(xlsxIx).name;
    else
        [fnm, pnm] = uigetfile(ipn,'Find the XLSX Single Runs file');
    end
    
    %Read the table
    ta = readtable([pnm fnm]);
    
    % Get its details
    variables = ta.Properties.VariableNames(4:end-3);
    [r, c] = size(ta);
    
    %% Identify related rows (same condition)
    %variable setup
    toCheck = [1:r];
    related = {};
    
    while ~isempty(toCheck)
        
        currRow = toCheck(1); %the Current Row is toCheck(1)
        
        if length(toCheck)==1 %if there is only one value in toCheck, record this as a single and end the loop
            related = [related, currRow];
            break
        end
        
        same = [];
        for  rowComp = toCheck; %The Row that's being compared against (NB: self comparison is also done to make the saving and removing stage easier)
            for iVa = 1:length(variables) %For all the IV's, check for identical and build a list
                same(rowComp,iVa) = isequal(ta.(variables{iVa})(currRow), ta.(variables{iVa})(rowComp));
            end
        end
        
        %record the rows which have the same condition (or record that
        %a row has no other partners)
        
        rowsWithSameCond = find(all(same'));
        
        related = [related, rowsWithSameCond]; %saves the indexes of rows that are for the same condition
        
        %remove them from from toCheck
        indexesOfRWSC = ismember(toCheck, rowsWithSameCond); %Where to find these rows in toCheck
        toCheck(indexesOfRWSC) = [];
    end
    
    
    %dce = struct2cell(data); %data in a cell
    
    dce = {}; %placeholder for data in a cell
    
    for relCell = 1:length(related) %for all cells in related
        nce = {}; %placeholder newcell
        for inCell = 1:length(related{relCell})
            tableName = ct{related{relCell}(inCell)};
            nce = [nce; (data.(tableName))];
        end
        dce{related{relCell}(1)} = [nce];
    end
    
    newpoints = find(~cellfun(@isempty,dce));
    
end

for d = newpoints %make the datacomb struct
    datacomb.(ct{d}(1:end-1)) = dce{d};
end

expName_comb = expName(newpoints);
expDateSess_comb = expDateSess(newpoints);

%% Saving and Final


save([pn readID '.mat'],'datacomb','expName_comb','expDateSess_comb','-append')


%% Sub-functions

end
