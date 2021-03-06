function [imported, indvars, pn, ppcode] = readfilefunc2(exptnum, settings)
%% Function to read data files and extract New Discrimination table and list of motion cues (from Psykinematix Output)
% The inputs: settings contains the number of IV's and their respective
% keyword-IV level lookup table, exptnum is the experiment number (to refer
% to correct settings)
% pn and ppcode are also output for saving purposes (see datasetupmaster)

%TIP: Use char(9) if you want to refer to TAB using strtok

%Constants

setting = settings(exptnum);

[fn pn] = uigetfile('.txt','MultiSelect','On');

diary([pn 'readfilelog.txt']) %Make log file

%detect Cancel/Single entry
[fn] = gfcheck(fn,'cell'); %'cell' specifies that fn should be a cell array

for a = 1:length(fn)
    
    name1 = fn{a}(~ismember(fn{a},' ,.:;!()%#_'));
    name1 = name1(1:end-3); %Remove txt from end
    
    blockpath = [pn fn{a}];
    
    %frewind(blockFID) %USE THIS TO 'REWIND' THE NEXT-LINE-READER fgetl
    
    %% Open data file and get motion cue.
    blockFID  = fopen(blockpath, 'r');

    %Detecting the motion cue and speed from the Expt Name
    %         fgetl(blockFID); fgetl(blockFID); %Skip to the line with the expt name
    %     line = fgetl(blockFID);

    nameToCheck = fn{a}; %This would have been line before.
    
    mark = @(x)~isempty(strfind(nameToCheck,x)); %Outputs 1 when the keyword exists in the line, 0 when it doesn't

for iva = 1:setting.ivs
    % loop through iv settings to identify which iv level this expt has for each iv
    % do the search-and-mark stuff below, repeated each time for each IV,
    % using the relevant ivtable from ivtables
    
    ivtable = setting.ivtables(iva); %current ivtable
    
    for k=1:length(ivtable.keywds)
        chk(k) = mark(ivtable.keywds{k}); %chk is a logical array, where the 1 appears in the ref corresponding to the level of iv, as listed in keywds
    end
    
     try
        indvars(iva).levels(a) = ivtable.list(chk); %The corresponding iv level (from list) to the found keywd is noted
     catch
        disp(['CANNAE FIND IV #',num2str(iva),' FOR FILE #',num2str(a)])
        if sum(chk) == 0
            indvars(iva).levels(a) = 'UNK';
        else
            error('There was an error with the independent variable detection.')
        end
    end
        
    clear chk k
end
      
    %%
%     loopcount = 1;
%    while ~feof(blockFID) %Loops to find more New Discrimination tables until end of document
%         name = [name1,num2str(loopcount)];    %USE THIS IF EXPECTING MORE THAN ONE TABLE
                name = name1;
        %% Skip through to start of New Discrimination table
%         while ~feof(blockFID) %~feof means 'not end of file'
%             [token, remain] = strtok(line);
%             if isequal(token, 'New')
%                 [token, remain] = strtok(remain);
%                 if isequal(token, 'Discrimination')
%                     %Go to just before the table headers line
%                     fgetl(blockFID);
%                     line = fgetl(blockFID);
%                     varsetup(a).(['table' num2str(loopcount)]) = line;
%                     break
%                 end
%             end
%             line = fgetl(blockFID);
%         end
%         
%         if feof(blockFID) %If this is the end of the document, end this loop, start new document
%             break
%         end
        
        %Extracting each cell of the table
        %TIP: Use char(9) if you want to refer to TAB using strtok
        
        line = 'a';
        
        r=1;
        while and(~isequal(line,''), ~feof(blockFID)); %each row of table PLUS headers
            
            c=1;
            line = fgetl(blockFID); %start a new line
            [cellvalues{r,c}, remain] = strtok(line,char(9)); %fill the first cell
            c=2;
            
            while ~isequal(cellvalues{r,c-1},'') %do this until (and including) the end of the row (empty)
                [cellvalues{r,c}, remain] = strtok(remain,char(9));  %fill the rest of the row
                c=c+1;
            end
            
            r=r+1;
        end
        
        %make appropriate variable names
        varnames = cellvalues(1,[1:end-1]);
        for i = 1:length(varnames)
            varnames{i}(ismember(varnames{i},' ,.:;!()%#_')) = [];
        end
        
        imported.(name) = cell2table(cellvalues([2:end-1],[1:end-1]),'VariableNames',varnames); %'Chop off' the empty column and row, and make a table
        
        %convert str(numbers) to numbers (double)
        
        % Use this to identify if the 'potentialnumber' is a number (returns 1 if yes), and possibly apply it to each cell in an array:
        %     all(ismember(potentialnumber, '0123456789+-.eEdD'));
        %     cellfun(@(x) all(ismember(x, '0123456789+-.eEdD')),{'potentialnumber1','potentialnumber2'},'UniformOutput',0);
        
        
        %Convert variables containing numbers from strings to numbers 
        %(make Matlab recognise the numbers)
        
        tvs = imported.(name).Properties.VariableNames;
        
        % Convert Hits and Misses to 1's and 0's
        imported.(name).Response(strcmp('Hit',imported.(name).Response))={'1'};
        imported.(name).Response(strcmp('Miss',imported.(name).Response))={'0'};
        imported.(name).Response = str2double(imported.(name).Response);
                
        for n = 1:length(tvs);
            if iscell(imported.(name){:,n}) == 1
                if all(cell2mat(cellfun(@(x) all(ismember(x, '0123456789+-.eEdD')),imported.(name){:,n},'UniformOutput',0)));
                    imported.(name).(tvs{n}) = str2double(imported.(name).(tvs{n}));
                else
                    disp(['Variable ',tvs{n},' was not recognised as a variable containing numbers. (Table: ',name,')'])
                end
            end
        end
                      
        clearvars -EXCEPT imported fn pn a blockFID loopcount name1 spd varsetup setting settings indvars
%         loopcount = loopcount+1;
   % end
end


clear name1

ppcode = input('INPUT ppcode:\n','s');

% sa = input('Save mat file? y/n \n','s');
sa = questdlg('Save MAT file?','SAVE','Yes','No','Yes');
if strcmp(sa,'Yes')
    disp('Saving Mat file to expt file directory...')
    save([pn,ppcode,'.mat'],'blockFID','fn','imported','indvars','pn','ppcode')
    disp(['Saving Mat file to ', pn,ppcode,'.mat'])
end

diary off %stop saving to log file
end


%% RESOURCE SCRIPT USED TO MAKE THIS ONE (from A Mackenzie)
% % Open eye tracker data file.
%     eyeFID  = fopen(eyeFile, 'r');
%     line = fgetl(eyeFID);
%
%     % Skip through to start of recorded samples
%     while ~feof(eyeFID)
%         [token, remain] = strtok(line);
%         if isequal(token, 'MSG')
%             [token, remain] = strtok(remain);
%             synctime = str2double(token);
%             [token, remain] = strtok(remain);
%             if isequal(token, 'SYNCTIME')
%                 line = fgetl(eyeFID);
%                 break
%             end
%         end
%         line = fgetl(eyeFID);
%     end
%     [token, remain] = strtok(line)
%     while isnan(str2double(token))
%         line = fgetl(eyeFID);
%         [token, remain] = strtok(line);
%     end

