function [imported, indvars, pn, readID, varsetup, expName, expDateSess ] = read_in_tables_removeold()
%% Function to read data files and extract New Discrimination tables
% Tables are not necessarily from same experiment or participant. 
% This just creates a mat file that holds a bunch of tables, and a txt file to tell you what's in there. That's it.

[fn pn] = uigetfile('.txt','MultiSelect','On');

%ppcode = input('Input ppcode\n','s'); %ADD THIS TO SAVE LIST IF USING IT

readID = sprintf('%0.0f',clock);

fileID = fopen([pn readID '_Details.txt'],'w');

expName = {};
expDateSess = {};
varsetup = {}; %will become a struct

diary([pn 'readfilelog.txt']) %Make log file

[fn] = gfcheck(fn,'cell'); %'cell' specifies that fn should be a cell array

% Waitbar setup
a=0;
w = waitbar(a/length(fn),'Reading...');

for a = 1:length(fn)
    
    waitbar(a/length(fn),w); % update waitbar
    
    name1 = fn{a}(~ismember(fn{a},' ,.:;!()%#_'));
    name1 = name1(1:end-3); %Remove txt from end
    
    blockpath = [pn fn{a}];
    
    %% Open data file and get expt details.
    blockFID  = fopen(blockpath, 'r');
    %frewind(blockFID) %USE THIS TO 'REWIND' THE NEXT-LINE-READER fgetl
    
    fgetl(blockFID); fgetl(blockFID); %Skip to the line with the expt name
    line1 = fgetl(blockFID);
    
    fgetl(blockFID); %Skip to the line with the session number and date
    line2 = fgetl(blockFID);
    
    if datenum(line2(5:12),'dd/mm/yy')< datenum('14/06/2016','dd/mm/yy')
        fclose('all')
        delete([pn fn{a}])
        continue
    end
    
    fprintf(fileID,'%s \r\n %s \r\n',line1,line2)
    
	% How many tables?
    [hmt, tStart] = howManyTables(blockFID);
    fprintf(fileID,'%d table(s) in this output file \r\n',hmt)
        
    %Detect and show the IV's from each table's var settings
    for tables = 1:hmt
	    expName{end+1} = line1; %Store it for saving later
		expDateSess{end+1} = line2; %Store it for saving later
			
        fseek(blockFID, tStart(tables)-19, -1);
        fgetl(blockFID);
        fgetl(blockFID);
        line = fgetl(blockFID);
        fprintf(fileID,'%s\r\n \r\n',line)
        varsetup(a).(['table' num2str(tables)]) = line; %save the variable setup for this file
    end
        
    clear tables
    
%     disp('paused')
%     pause

    
    %Find and Process New Discrimination tables
    [varsetup] = findDiscTables();
    
end

clear name1

%Make data struct
impnames = fieldnames(imported);
for j = 1:length(impnames)
[x, y] = regexp(impnames{j},'Sub[\w*]+ssion'); %identifies the text to cut out for the name
data.(impnames{j}([1:x-1,y+1:end])) = imported.(impnames{j});
end


%  disp('Saving Mat file to expt file directory...')
% sa = input('Save mat file? y/n \n','s');
% if sa == 'y'
    save([pn,readID,'.mat'],'blockFID','fn','imported','pn','readID','varsetup','expName','expDateSess','data')
    disp(['Saving Mat file to ', pn,readID,'.mat'])
% end

fclose(fileID);
diary off %stop saving to log file


%% Sub-Functions


    function [varsetup] = findDiscTables()
              
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


% Update and delete waitbar
%set(get(findobj(w,'type','axes'),'title'), 'string', 'FINISHED!');
waitbar(1,w,'FINISHED!');
pause(0.5)
delete(w)

end
