function [ imported, pn, readID, varsetup, expName, expDateSess ] = rivalryRead(fn, pn)
%Read the Psykinematix Output for rivalry

tic

% [fn, pn] = uigetfile('.txt','MultiSelect','On');

%copyfile('C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\Folder structure',pn)

%ppcode = input('Input ppcode\n','s'); %ADD THIS TO SAVE LIST IF USING IT

readID = [sprintf('%0.0f',clock) '_rivalry'];

fileID = fopen([pn readID '_Details.txt'],'w');

expName = {};
expDateSess = {};
varsetup = {}; %will become a struct

diary([pn 'readfilelog.txt']) %Make log file

% [fn] = gfcheck(fn,'cell'); %'cell' specifies that fn should be a cell array

% Waitbar setup
a=0;
w = waitbar(a/length(fn),'Reading...');
war = 0;

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
    
    %     if datenum(line2(5:12),'dd/mm/yy')< datenum('14/06/2016','dd/mm/yy')
    %         fclose('all')
    %         delete([pn fn{a}])
    %         continue
    %     end
    
    fprintf(fileID,'%s \r\n %s \r\n',line1,line2)
    
    % How many New Discrimination tables?
    [hmt, tStart] = howManyTables(blockFID,'New','Discrimination');
    fprintf(fileID,'%d New Discrimination table(s) in this output file \r\n',hmt)
    
    % How many Multiple Inputs tables?
    [hmtMI, tStartMI] = howManyTables(blockFID,'Multiple','Inputs');
    fprintf(fileID,'%d Multiple Inputs table(s) in this output file \r\n',hmt)
    
    % Error Check
    if length(hmt)~=length(hmtMI)
        error('There should be equal number of New Disc and MI tables??')
    end
    
    %Detect and show the IV's from each New Discrimination table's var settings
    for tables = 1:hmt
        expName{end+1} = line1; %Store it for saving later
        expDateSess{end+1} = line2; %Store it for saving later
        
        fseek(blockFID, tStart(tables)-19, -1);
        fgetl(blockFID);
        fgetl(blockFID);
        line = fgetl(blockFID);
        fprintf(fileID,'%s\r\n \r\n',line)
    end
    
    clear tables
    
    %     disp('paused')
    %     pause
    
    
    %Find and Process New Discrimination tables
    findTables('ND','New','Discrimination',tStart,hmt);
    
    %Find and Process Multiple Inputs tables (number of lines between table
    %name and table data is accounted for in the function)
    findTables('MI','Multiple','Inputs',tStartMI,hmtMI);
    
    
end %finished looping through files

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

%pause for a bit to make sure duplicate name isn't used for next file (this
% script must take at least 1 second to run)
pause(1-toc)

fclose(fileID);
diary off %stop saving to log file

% Update and delete waitbar
%set(get(findobj(w,'type','axes'),'title'), 'string', 'FINISHED!');

wbmsg = sprintf('FINISHED with %d Warnings!',war);
if war>0
    waitbar(1,w,wbmsg);
    disp(wbmsg)
    pauseTime = 1.5;
else
    waitbar(1,w,'FINISHED!');
    pauseTime = 0.5;
end

pause(pauseTime)
delete(w)



%% Sub-Functions

    function [] = findTables(initials,wd1,wd2,tStart,hmt)
        
        for tables = 1:hmt %Loops to find more New Discrimination tables until end of document
            switch hmt
                case 1
                    name = name1;
                case 0
                    warning('No Tables detected') %unnecessary here as for loop shoulnd't run if hmt=0?
                    war = war+1;
                    pause
                otherwise
                    name = [name1,num2str(tables),initials];
            end
            
            %% Skip through to start of table
            
            if isequal([wd1 wd2],'NewDiscrimination')
                offset = length('New Discrimination')+1;
            else
                offset = length('Multiple Inputs across trials')+1;
            end
            
            fseek(blockFID, tStart(tables)-offset, -1)
            line = fgetl(blockFID);
            [token, remain] = strtok(line);
            if isequal(token, wd1)                %Error Checking: Make sure it's the ND table
                [token, remain] = strtok(remain);
                if isequal(token, wd2)
                    %Go to just before the table headers line
                    if isequal([wd1 wd2],'NewDiscrimination') % if this is a New Disc table, this requires skipping. Collect variable values while you're here.
                        fgetl(blockFID);
                        line = fgetl(blockFID);
                        varsetup(a).(['table' num2str(tables) initials]) = line; %save the variable setup for this file
                    else
                        varsetup(a).(['table' num2str(tables) initials]) = 'na';
                    end
                else
                    warning('This should be the start of the New Discrimination Table... but isn''t.')
                    warning(['Table ',name])
                    war = war+1;
                    pause
                end
            else
                warning('This should be the start of the New Discrimination Table... but isn''t.')
                warning(['Table ',name])
                war = war+1;
                pause
            end
            
            %Extracting each cell of the table (adds new table to imported automatically)
            extractedCells2Table();
            
            %% Convert variables containing numbers from strings to numbers (make Matlab recognise the numbers)
            %convert str(numbers) to numbers (double)
            % Use this to identify if the 'potentialnumber' is a number (returns 1 if yes), and possibly apply it to each cell in an array:
            %     all(ismember(potentialnumber, '0123456789+-.eEdD'));
            %     cellfun(@(x) all(ismember(x, '0123456789+-.eEdD')),{'potentialnumber1','potentialnumber2'},'UniformOutput',0);
                       
            tvs = imported.(name).Properties.VariableNames;
            
            % If the table has a Response variable (usu. a New Discrimination table, except in cases of MI)...
            if ismember(tvs,'Response')
                % Detect if run was aborted and delete the incomplete table
                if any(strcmp('Aborted',imported.(name).Response))
                    %                imported = rmfield(imported,name);
                    warning('TABLE WITH ABORTED RUN HERE. DO NOT ANALYSE.')
                    war = war+1;
                end
                
                % Convert Hits and Misses to 1's and 0's, and Aborted's to 0
                imported.(name).Response(strcmp('Hit',imported.(name).Response))={'1'};
                imported.(name).Response(strcmp('Miss',imported.(name).Response))={'0'};
                imported.(name).Response(strcmp('Aborted',imported.(name).Response))={'0'};
                imported.(name).Response = str2double(imported.(name).Response);
            end
            
            % Make sure numbers are actually numbers (not strings)
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
        
        %% Sub-functions of findTables()
        %TIP: Use char(9) if you want to refer to TAB using strtok
        function [] = extractedCells2Table()
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
            
        end
        
    end


    function [hmt, tStart] = howManyTables(blockFID,wd1,wd2)
        %wd1 and wd2 can be, e.g. New & Discrimination, OR Multiple & Inputs
        hmt = 0;
        while ~feof(blockFID) %~feof means 'not end of file'
            line = fgetl(blockFID);
            [token, remain] = strtok(line);
            if isequal(token, wd1)
                [token, remain] = strtok(remain);
                if isequal(token, wd2)
                    hmt = plus(hmt,1); %increment hmt
                    tStart(hmt) = ftell(blockFID);
                end
            end
        end
        frewind(blockFID) %rewind after finding number of tables
    end

end



