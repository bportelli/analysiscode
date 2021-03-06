function [imported, indvars, pn, ppcode] = readfilefunc(exptnum, settings)
%% Function to read data files and extract New Discrimination table and list of motion cues (from Psykinematix Output)
% The inputs: settings contains the number of IV's and their respective
% keyword-IV level lookup table, exptnum is the experiment number (to refer
% to correct settings)
% pn and ppcode are also output for saving purposes (see datasetupmaster)

%TIP: Use char(9) if you want to refer to TAB using strtok

%Constants

setting = settings(exptnum);
expName = {}; %create new cell to receive expt names
expDateSess = {}; %create new cell to receive expt dates and session

[fn pn] = uigetfile('.txt','MultiSelect','On');

diary([pn 'readfilelog.txt']) %Make log file

%detect Cancel/Single entry
[fn] = gfcheck(fn,'cell'); %'cell' specifies that fn should be a cell array

for a = 1:length(fn)
    
    name1 = fn{a}(~ismember(fn{a},' ,.:;!()%#_'));
    name1 = name1(1:end-3); %Remove txt from end
    
    blockpath = [pn fn{a}];
    
    %% Open data file and get expt details.
    blockFID  = fopen(blockpath, 'r');
    %frewind(blockFID) %USE THIS TO 'REWIND' THE NEXT-LINE-READER fgetl
    
    fgetl(blockFID); fgetl(blockFID); %Skip to the line with the expt name
    line1 = fgetl(blockFID);
    expName{end+1} = line1; %Store it for saving later
    
    fgetl(blockFID); %Skip to the line with the session number and date
    line2 = fgetl(blockFID);
    expDateSess{end+1} = line2; %Store it for saving later
    
	% How many tables?
    [hmt, tStart] = howManyTables(blockFID);
        
	if hmt == 1
    %Detecting the IV's from the Expt Name
    indvars = detect_ivs(line1);
	else
	%Detect the IV's from each table's var settings
	
    end
    
    %Find and Process New Discrimination tables
    [imported, varsetup] = findDiscTables();
    
end

clear name1

ppcode = input('INPUT ppcode:\n','s');

% disp('Saving Mat file to expt file directory...')
sa = input('Save mat file? y/n \n','s');
if sa == 'y'
    save([pn,ppcode,'.mat'],'blockFID','fn','imported','indvars','pn','ppcode','varsetup','expName','exptDateSess')
    disp(['Saving Mat file to ', pn,ppcode,'.mat'])
end

diary off %stop saving to log file


%% Sub-Functions

    function [indvars] = detect_ivs(line)
        mark = @(x)~isempty(strfind(line,x)); %Outputs 1 when the keyword exists in the line, 0 when it doesn't
        
        for iva = 1:setting.ivs
            % loop through iv settings to identify which iv level this expt has for
            % each iv
            % do the search-and-mark stuff below, repeated each time for each IV,
            % using the relevant ivtable from ivtables
            
            ivtable = setting.ivtables(iva); %current ivtable
            
            chk = itemIndex(); %returns a logical array corresponding to the position of the found item
            
            if sum(chk)>1
               fprintf('There appear to be %d levels of IV# %d in file # %d\n',sum(chk),num2str(iva),num2str(a))
               disp('You should probably write some code to handle this...')
               pause % WRITE SOME CODE TO DO SOMETHING ABOUT THIS
            end
            
            
            try
                indvars(iva).levels(a) = ivtable.list(chk); %The corresponding iv level (from list) to the found keywd is noted
            catch
                disp(['CANNAE FIND IV #',num2str(iva),' FOR FILE #',num2str(a)])
                if sum(chk) == 0 %None of the available options is detected
                    indvars(iva).levels(a) = 'UNK';
                else %More than one option detected?
                    %error('There was an error with the independent variable detection.')
                    indvars(iva).levels(a) = 'UNK2';
                end
            end
        end
        
        function chk = itemIndex()
            for k=1:length(ivtable.keywds)
                chk(k) = mark(ivtable.keywds{k}); %chk is a logical array, where the 1 appears in the ref corresponding to the level of iv, as listed in keywds
            end
        end
        
    end


    function [imported, varsetup] = findDiscTables()
              
        for tables = 1:hmt %Loops to find more New Discrimination tables until end of document
            switch hmt
                case 1
                    name = name1;
                case 0
                    warning('No New Discrimination Tables detected')
                    pause
                otherwise
                    name = [name1,num2str(tables)];
            end
            
            %% Skip through to start of New Discrimination table
            
            fseek(blockFID, tStart(tables)-19, -1)
            line = fgetl(blockFID);
            [token, remain] = strtok(line);
            if isequal(token, 'New')                %Error Checking: Make sure it's the ND table
                [token, remain] = strtok(remain);
                if isequal(token, 'Discrimination')
                    %Go to just before the table headers line
                    fgetl(blockFID);
                    line = fgetl(blockFID);
                    varsetup(a).(['table' num2str(tables)]) = line; %save the variable setup for this file
                else
                    warning('This should be the start of the New Discrimination Table... but isn''t.')
                    pause
                end
            else
                warning('This should be the start of the New Discrimination Table... but isn''t.')
                pause
            end
            
            %Extracting each cell of the table
            %TIP: Use char(9) if you want to refer to TAB using strtok
            
            r=1;
            while and(~feof(blockFID),~isequal(line,'')); %each row of table PLUS headers
                
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
            %         clearvars -EXCEPT imported fn pn a blockFID loopcount name1 spd varsetup setting settings indvars
        end
    end    
        
        function [hmt, tStart] = howManyTables(blockFID)
            hmt = 0;
            while ~feof(blockFID) %~feof means 'not end of file'
                line = fgetl(blockFID);
                [token, remain] = strtok(line);
                if isequal(token, 'New')
                    [token, remain] = strtok(remain);
                    if isequal(token, 'Discrimination')
                        hmt = plus(hmt,1); %increment hmt
                        tStart(hmt) = ftell(blockFID);
                    end
                end
            end
            frewind(blockFID) %rewind after finding number of tables
        end
        



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

