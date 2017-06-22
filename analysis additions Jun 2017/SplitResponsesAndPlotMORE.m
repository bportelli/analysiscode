function [ T31, thresholds, hands, shand, legHa, optsout ] = SplitResponsesAndPlotMORE(a,optsin)
% Splits % correct for the two button presses and plots


% Mac problem (this code is on the Mac version to prevent error)
% if nargin == 0
%     msg = sprintf(['On the Mac THIS FUNCTION REQUIRES AN INPUT ARGUMENT.\n'...
%          'This should be a cell array containing the table to plot (''Paste Excel Data'').']);
%     error(msg)
% end


% Constants
DELIM = '\t';

%Bootstrapping (currently off)
BOOTS=0; ParOrNonPar = 1;

% Setup values
xhigh = 0;

%% Receive input: either paste in New Discrimination Table, extract it or take it as function argument

%if nargin == 1 %this won't work with the optsin
if ~isempty(a)
    if iscell(a)
        ButtonName = 'CellIn';
    else if istable(a)
            ButtonName = 'TableIn';
        end
    end
else
    ButtonName = questdlg('Paste in Table or extract from excel file?', ...
        'Input Source', ...
        'Paste Table', 'Excel File', 'Paste Table');
end

switch ButtonName,
    case 'Paste Table',
        disp('Copy Table, then Press Enter to Continue');
        pause
        txt = clipboard('paste'); % pastes the clipboard into a cell array
        
        % Get column names and format correctly
        colnames = textscan(txt,'%[^\n]',1,'HeaderLines',0,'Delimiter',DELIM,'EndOfLine','\n'); %gets the header line/column names (as a cell array within a cell array)
        cellColNames = textscan(colnames{1,1}{1,1},'%s','Delimiter',DELIM,...
            'Whitespace','','EndOfLine','\n'); %header is now in separate cells (in a cell), but oriented vertically
        colnames = cellColNames{1,1}';
        for i = 1:length(colnames)
            colnames{i}(ismember(colnames{i},' ,.:;!()%#_')) = [];
        end
        
        %this bit is adapted from importdata (in order to... import the data)
        cellData = textscan(txt,['%q' '%q' '%q' '%q' '%q' '%q' '%q' '%q' '%q'],'Delimiter','\t', ...
            'MultipleDelimsAsOne', 1, 'CommentStyle', '', ...
            'HeaderLines',1, 'CollectOutput', true,'EndOfLine','\n');
        cellData = cellData{1,1};
        
        %make the table
        T31 = cell2table(cellData,'VariableNames',colnames);
        T31 = convertNumbers(T31);
    case 'Excel File',
        disp('You chose to extract from Excel file')
        [imported, ~] = read_in_tables();
        ff = fieldnames(imported);
        T31 = imported.(ff{1});
    case 'CellIn'
        da = a(2:end,:);
        colhead = a(1,:);
        colhead = cellfun(@(x)x(~ismember(x,' ,.:;!()%#_')),colhead,'UniformOutput',false);
        
        T31 = cell2table(da,'VariableNames',colhead);
        
        % Convert Hits and Misses to 1's and 0's, and Aborted's to 0
        T31.Response(strcmp('Hit',T31.Response))={'1'};
        T31.Response(strcmp('Miss',T31.Response))={'0'};
        T31.Response(strcmp('Aborted',T31.Response))={'0'};
        T31.Response = str2double(T31.Response);
        
        for n = 1:length(colhead);
            if iscell(T31{:,n})
                if all(cell2mat(cellfun(@(x) all(ismember(x, '0123456789+-.eEdD')),T31{:,n},'UniformOutput',0)));
                    T31.(colhead{n}) = str2double(T31.(colhead{n}));
                else
                    disp(['Variable ',colhead{n},' was not recognised as a variable containing numbers.'])
                end
            end
        end
    case 'TableIn'
        T31 = a;
end % switch

%% Add the column that marks which trials had a 'towards' disparity (0 for those which had an 'away')

T31.isTowards = (T31.Stimulusclosedir == 1 & T31.StimulusonFixPlane == 1) | ...
    (T31.Stimulusclosedir == -1 & T31.StimulusonFixPlane == 0);

%% Split and plot

Tables.Ta1 = T31; %Ta1 is the overall table (no split)

% GET OPTIONS
if iscell(optsin)
    s1 = optsin{1};
    yVar = optsin{2};
    splitVar = optsin{3};
    optsout = optsin;
else
    % Y axis measure (% Correct, or % Responded Top/Bottom)
    m1tip = sprintf('Y axis values:');
    str1 = {'Proportion Correct','Proportion Responded Top Nearer'};
    [s1,~] = listdlg('PromptString',m1tip,...
        'SelectionMode','single',...
        'ListString',str1,'InitialValue',find(ismember(str1,'Percent Correct')));
    yVar = str1{s1};
    
    % Split based on which variable?
    m2tip = sprintf('Split series based on...');
    str = T31.Properties.VariableNames;
    [s,~] = listdlg('PromptString',m2tip,...
        'SelectionMode','single',...
        'ListString',str,'InitialValue',find(ismember(str,'isTowards')));
    splitVar = str{s};
    
    optsout = 0;
    
    if optsin
        %Keep options?
        opQ = questdlg('Keep these options for all subsequent plots?','KEEP OPTIONS?','Yes','No','No & Stop Asking','No');
        if isequal(opQ,'Yes')
            optsout = [{s1} {yVar} {splitVar}];
        else if isequal(opQ,'No & Stop Asking')
                optsout = 0;
            else
                optsout = 1;
            end
        end
    end
    
end

values = unique(T31.(splitVar)); %what are the different values of the variable that table is splitting by

makeTheNumbersStrings = 0;
if ~iscell(values) % Change values to a cell so later references will work
    values = num2cell(values);
    makeTheNumbersStrings = 1;
end

for kk = 2:length(values)+1
    %     if isstr(values{1})
    %         f1 = @strcmp;
    %     else
    %         f1 = @isequal;
    %     end
    Tables.(['Ta' num2str(kk)]) = T31(ismember(T31.(splitVar),values{kk-1}),:);
end

if makeTheNumbersStrings % now make the numbers strings, so they can be labels
    values = cellfun(@(x){num2str(x)},values);
end

hands = gobjects(); % prepare to receive handles of plots for legend

for series = 1:length(fieldnames(Tables))
    
    clear StimLevels NumPos OutOfNum ProportionCorrectObserved StimLevelsFineGrain...
        PsychFunOut searchGrid paramsFree options bootsOut GoFOut tx
    
    T312 = Tables.(['Ta' num2str(series)]);
    
    %% Choose the thresholded variable
    thVar = getThVar(T312);  % Need to get the name of the current table
    
    
    %% The Analysis Process
    % Prep the variables
    if s1 == 1
        tbAdd = [];
        [StimLevels,NumPos,OutOfNum,ProportionCorrectObserved,StimLevelsFineGrain] = varPrepNormal(T312,thVar);
        % Evaluate Psychometric function for 'normal' cases (i.e. guess rate 50%, lapse rate 5%...)
        PF = @PAL_Weibull;
        [PsychFunOut, searchGrid, paramsFree, options] = getPsychFunNormal();
    else
        tbAdd = [' Top is near'];
        [StimLevels,NumPos,OutOfNum,ProportionCorrectObserved,StimLevelsFineGrain] = varPrepTB(T312,thVar);
        % Evaluate Psychometric function for proportion T/B plot
        PF = @PAL_CumulativeNormal;
        [PsychFunOut, searchGrid, paramsFree, options] = getPsychFunPercTB();
    end
    
    % Run bootstrap if requested
    if BOOTS == 1
        [bootsOut, GoFOut] = bootsfun(ParOrNonPar);
    end
    
    
    % Make a simple plot and collect thresholds
    LineColour = {'g','b','y','k','c'};
    [fhand, hands, tx, shand] = makePlot(LineColour{series}, series, hands);
    thresholds(series) = tx; %collect the thresholds for output
    
end

% Finish off the plot aesthetics and display the thresholds
xhigh = max(xhigh,max(StimLevels));
leg_labels = [{'All'} values'];
legHa = legend(hands,'String',leg_labels); % Make a legend for the plot
if s1 == 1
    axis([0 xhigh*1.1 0 1]);
else
    axis([xhigh*-1.1 xhigh*1.1 0 1]);
    plot([0 0],[-1 1],'Color',[0.1 0.1 0.1],'LineStyle','--');
    %plot([xhigh*-1.1 xhigh*1.1],[0 0],'Color',[0.1 0.1 0.1],'LineStyle','--');
end


% Reminder - Button 1 is A, 2 is B, 3 is X, 4 is Y
disp(' BUTTON  LAYOUT ');
disp('----------------');
disp('       4        '); %Away/Far
disp('  3         2   '); %Left and Right
disp('       1        '); %Towards/Near
disp('----------------');

disp('****************');
for m = 1:length(thresholds)
    fprintf('Threshold %s: %0.2f \n',leg_labels{m},thresholds(m));
end
disp('****************');

% try
%     T1 = outputSaveFitDetails(fhand); %This must be before closing and saving the figure
% catch
%     warning('There was an error with generating the figure table output.')
% end
%


%% Analysis Sub-functions


    function [boots, ParOrNonPar]  = queryBoots() %Currently OFF by default
        message = 'Bootstrapping on?';
        boots = 0; %input(message);
        
        message = 'Parametric Bootstrap (1) or Non-Parametric Bootstrap? (2): ';
        ParOrNonPar = 1; %input(message);
        
        if boots == 1
            if ParOrNonPar == 1
                disp('Parametric Bootstrap Selected');
            else if ParOrNonPar == 2
                    disp('Non-Parametric Bootstrap Selected');
                end
            end
        end
        
    end


    function thVar = getThVar(currenttable)
        fi = fieldnames(currenttable);
        disp(fi)
        thVar = 'Stimulusdisparity';
        fprintf('%s is the thresholded variable.',thVar)
        thQ = []; %input('','s');
        if ~isempty(thQ)
            thVar = thQ;
        end
        
        if ~any(ismember(fi,thVar)) %if it's not on the list, start again
            disp('INVALID THRESHOLDED VARIABLE. PLEASE TYPE ANOTHER ONE')
            %error('') % PUT this here to deal with the fact that it doesn't take the corrected response. Fix this.
            thVar = input('','s');
        end
        if ~any(ismember(fi,thVar)) %if it's not on the list, start again
            disp('INVALID THRESHOLDED VARIABLE')
            %error('') % PUT this here to deal with the fact that it doesn't take the corrected response. Fix this.
            thVar = getThVar(currenttable);
            return
        end
        
    end


    function [StimLevels,NumPos,OutOfNum,ProportionCorrectObserved,StimLevelsFineGrain] = varPrepNormal(currentTable,thVar) %Prep the variables
        StimLevels = currentTable.(thVar)'; %get the Psykinematix variable name e.g. Stimulusduration
        NumPos = currentTable.Response';
        OutOfNum = ones(1,length(NumPos));
        
        [StimLevels NumPos OutOfNum] = PAL_PFML_GroupTrialsbyX(StimLevels, NumPos, OutOfNum);
        
        ProportionCorrectObserved=NumPos./OutOfNum;
        StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
    end

    function [StimLevels,NumPos,OutOfNum,ProportionCorrectObserved,StimLevelsFineGrain] = varPrepTB(currentTable,thVar) %Prep the variables
        
%         Reminders:
%         closedir = 1, TOP is close (because TOP D is negative)
%         closedir = -1, BOTTOM is close (because BOTTOM D is negative)
%
%         onFixPlane = 0 TOP is on Fixation plane
%         onFixPlane = 1 BOTTOM is on Fixation plane
% 
%         closedir & onFixPlane = isTowards
%         1  & 0 = 0
%         -1 & 1 = 0
%         1  & 1 = 1
%         -1 & 0 = 1
        
        %Make the disparity positive when top is nearer
        StimLevels = currentTable.Stimulusdisparity'.*currentTable.Stimulusclosedir';
        
        %Change choices from 1s and 2s to 0s and 1s
        NumPos = currentTable.ChoiceIndex'-1;
%         NumPos = -NumPos;
%         NumPos(NumPos == -2) = 1;
        
        OutOfNum = ones(1,length(NumPos));
        
        [StimLevels NumPos OutOfNum] = PAL_PFML_GroupTrialsbyX(StimLevels, NumPos, OutOfNum);
        
        ProportionCorrectObserved=NumPos./OutOfNum;
        StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
    end


    function [PsychFunOut, searchGrid, paramsFree, options] = getPsychFunNormal()
        %Parameter grid defining parameter space through which to perform a
        %brute-force search for values to be used as initial guesses in iterative
        %parameter search.
        searchGrid.alpha = 0:.1:max(StimLevels);
        searchGrid.beta = linspace(0,100,101);
        %searchGrid.beta = logspace(1,3,100);
        searchGrid.gamma = .5;  %scalar here (since fixed) but may be vector
        searchGrid.lambda = 0.05;  %ditto
        %searchGrid.lambda = 0:.001:.1;
        
        %Fit a function
        %Threshold and Slope are free parameters, guess and lapse rate are fixed
        paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
        
        %Optional:
        options = PAL_minimize('options');   %type PAL_minimize('options','help') for help
        options.TolFun = 1e-09;     %increase required precision on LL
        options.MaxIter = 100;
        options.Display = 'off';    %suppress fminsearch messages
        
        %Perform fit
        disp('Fitting function.....');
        [paramsValues LL exitflag output] = PAL_PFML_Fit(StimLevels,NumPos, ...
            OutOfNum,searchGrid,paramsFree,PF,'searchOptions',options);
        
        disp('done:')
        message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
        disp(message);
        message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
        disp(message);
        
        ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
        
        PsychFunOut =  cell2struct({paramsValues, LL, exitflag, output,ProportionCorrectModel},{'paramsValues', 'LL', 'exitflag', 'output','ProportionCorrectModel'},2);
        
    end

%Psychometric function for % Top/Bottom
    function [PsychFunOut, searchGrid, paramsFree, options] = getPsychFunPercTB()
        %Parameter grid defining parameter space through which to perform a
        %brute-force search for values to be used as initial guesses in iterative
        %parameter search.
        searchGrid.alpha = min(StimLevels):.1:max(StimLevels);
        searchGrid.beta = linspace(0,100,101);
        %searchGrid.beta = logspace(1,3,100);
        searchGrid.gamma = 0;  %scalar here (since fixed) but may be vector
        searchGrid.lambda = 0;  %ditto
        %searchGrid.lambda = 0:.001:.1;
        
        %Fit a function
        %Threshold and Slope are free parameters, guess and lapse rate are fixed
        paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
        
        %Optional:
        options = PAL_minimize('options');   %type PAL_minimize('options','help') for help
        options.TolFun = 1e-09;     %increase required precision on LL
        options.MaxIter = 100;
        options.Display = 'off';    %suppress fminsearch messages
        
        %Perform fit
        disp('Fitting function.....');
        [paramsValues LL exitflag output] = PAL_PFML_Fit(StimLevels,NumPos, ...
            OutOfNum,searchGrid,paramsFree,PF,'searchOptions',options);
        
        disp('done:')
        message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
        disp(message);
        message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
        disp(message);
        
        ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
        
        PsychFunOut =  cell2struct({paramsValues, LL, exitflag, output,ProportionCorrectModel},{'paramsValues', 'LL', 'exitflag', 'output','ProportionCorrectModel'},2);
        
    end



    function [bootsOut, GoFOut] = bootsfun(ParOrNonPar)
        
        %Number of simulations to perform to determine standard error
        B=400;
        
        disp('Determining standard errors.....');
        
        if ParOrNonPar == 1
            [SD paramsSim LLSim converged] = PAL_PFML_BootstrapParametric(...
                StimLevels, OutOfNum, PsychFunOut.paramsValues, paramsFree, B, PF, ...
                'searchOptions',options,'searchGrid', searchGrid);
        else
            [SD paramsSim LLSim converged] = PAL_PFML_BootstrapNonParametric(...
                StimLevels, NumPos, OutOfNum, [], paramsFree, B, PF,...
                'searchOptions',options,'searchGrid',searchGrid);
        end
        
        disp('done:');
        message = sprintf('Standard error of Threshold: %6.4f',SD(1));
        disp(message);
        message = sprintf('Standard error of Slope: %6.4f\r',SD(2));
        disp(message);
        
        %Number of simulations to perform to determine Goodness-of-Fit
        B=400;
        
        disp('Determining Goodness-of-fit.....');
        
        [Dev pDev] = PAL_PFML_GoodnessOfFit(StimLevels, NumPos, OutOfNum, ...
            PsychFunOut.paramsValues, paramsFree, B, PF,'searchOptions',options, ...
            'searchGrid', searchGrid);
        
        disp('done:');
        
        %Put summary of results on screen
        message = sprintf('Deviance: %6.4f',Dev);
        disp(message);
        message = sprintf('p-value: %6.4f',pDev);
        disp(message);
        
        bootsOut = cell2struct({SD, paramsSim, LLSim, converged},{'SD', 'paramsSim', 'LLSim', 'converged'},2);
        GoFOut = cell2struct({Dev, pDev},{'Dev', 'pDev'},2);
        
    end

    function [fhand, phand, tx, shand] = makePlot(LineCol, seriesNum, phand)
        
        fhand = figure(1);
        
        %if combi
        shand = scatter(StimLevels,ProportionCorrectObserved,...
            'ko','MarkerFaceColor',LineCol,'SizeData',OutOfNum*5); %shand is scatter handle
        %else
        %    plot(StimLevels,ProportionCorrectObserved,'k.','markersize',30);
        %end
        hold on
        set(gca, 'fontsize',16);
        set(gca, 'Xtick',StimLevels);
        axis([0 1 0 1]);
        hold on;
        phand(seriesNum) = plot(StimLevelsFineGrain,PsychFunOut.ProportionCorrectModel,[LineCol '-'],'linewidth',4);
        xlabel([thVar tbAdd]);
        ylabel(yVar);
        
        %Threshold marker
        tx = PF(PsychFunOut.paramsValues,0.75,'Inverse');
        
        %Plot aesthetics
        set(gca,'XTickLabelRotation', 90)
        set(gca,'FontSize',10)
        
    end

    function T1 = outputSaveFitDetails(fhand)
        %Storage for Excel Table
        Threshold = tx;
        AlphaEst = PsychFunOut.paramsValues(1); %From function fit
        SlopeEst = PsychFunOut.paramsValues(2);
        
        %Details appear on axes and stored in table as a row
        if BOOTS == 1
            % Get the results from the boostrap
            AlphaSE = bootsOut.SD(1); %From bootstrapping for SE's
            SlopeSE = bootsOut.SD(2);
            Deviance = GoFOut.Dev; %From Goodness-of-fit
            pvalue = GoFOut.pDev;
            
            % Boots and GoF appear on axes...
            varns = {'Threshold','AlphaEst','SlopeEst','AlphaSE','SlopeSE','Deviance','pvalue'};
            dtab = [Threshold; AlphaEst; SlopeEst; AlphaSE; SlopeSE; Deviance; pvalue];
            thand = uitable(fhand,'Data',dtab,'RowName',varns,'Position',[350 55 170 130]);
            %... and stored in table alongside the AnaID
            Tc = {AnaID,expName{cTix},expDateSess{cTix},Threshold,AlphaEst,SlopeEst,AlphaSE,SlopeSE,Deviance,pvalue};
            T1 = cell2table(Tc,'VariableNames',...
                {'AnaID','ExpName','SessDate','Threshold','AlphaEst','SlopeEst','AlphaSE','SlopeSE','Deviance','pvalue'});
        else
            % Only Threshold, Alpha and Slope appear on axes...
            varns = {'Threshold','AlphaEst','SlopeEst'};
            dtab = [Threshold; AlphaEst; SlopeEst];
            thand = uitable(fhand,'Data',dtab,'RowName',varns,'Position',[350 55 170 100]);
            Tc = {AnaID,expName{cTix},expDateSess{cTix},Threshold,AlphaEst,SlopeEst};
            T1 = cell2table(Tc,'VariableNames',{'AnaID','ExpName','SessDate','Threshold','AlphaEst','SlopeEst'});
        end
    end


















%% Receiving Input Sub-functions

    function [inputT] = convertNumbers(inputT)
        tvs = inputT.Properties.VariableNames;
        
        % Convert Hits and Misses to 1's and 0's, and Aborted's to 0
        inputT.Response(strcmp('Hit',inputT.Response))={'1'};
        inputT.Response(strcmp('Miss',inputT.Response))={'0'};
        inputT.Response(strcmp('Aborted',inputT.Response))={'0'};
        inputT.Response = str2double(inputT.Response);
        
        for n = 1:length(tvs);
            if iscell(inputT{:,n}) == 1
                if all(cell2mat(cellfun(@(x) all(ismember(x, '0123456789+-.eEdD')),inputT{:,n},'UniformOutput',0)));
                    inputT.(tvs{n}) = str2double(inputT.(tvs{n}));
                end
            end
        end
        
    end


    function [imported, pn] = read_in_tables()
        %% Function to read data files and extract New Discrimination tables
        % Tables are not necessarily from same experiment or participant.
        % This just creates a mat file that holds a bunch of tables, and a txt file to tell you what's in there. That's it.
        % This normally deletes files before a certain date... however this feature is
        % currently commented out
        
        [fn pn] = uigetfile('.txt','MultiSelect','Off');
        
        [fn] = gfcheck(fn,'cell'); %'cell' specifies that fn should be a cell array
        
        % Waitbar setup
        war = 0;
        
        name1 = fn{1}(~ismember(fn{1},' ,.:;!()%#_'));
        name1 = name1(1:end-3); %Remove txt from end
        
        blockpath = [pn fn{1}];
        
        %% Open data file and get expt details.
        blockFID  = fopen(blockpath, 'r');
        %frewind(blockFID) %USE THIS TO 'REWIND' THE NEXT-LINE-READER fgetl
        
        fgetl(blockFID); fgetl(blockFID); %Skip to the line with the expt name
        line1 = fgetl(blockFID);
        
        fgetl(blockFID); %Skip to the line with the session number and date
        line2 = fgetl(blockFID);
        
        % How many tables?
        [hmt, tStart] = howManyTables(blockFID);
        
        if hmt ~= 1
            error('There should be 1 New Discrimination table')
        end
        
        %Detect and show the IV's from each table's var settings
        for tables = 1:hmt
            
            fseek(blockFID, tStart(tables)-19, -1);
            fgetl(blockFID);
            fgetl(blockFID);
            line = fgetl(blockFID);
        end
        
        %Find and Process New Discrimination tables
        findDiscTables();
        
        %Make data struct
        impnames = fieldnames(imported);
        for j = 1:length(impnames)
            [x, y] = regexp(impnames{j},'Sub[\w*]+ssion'); %identifies the text to cut out for the name
            data.(impnames{j}([1:x-1,y+1:end])) = imported.(impnames{j});
        end
        
        
        
        %% Sub-Functions
        
        function [fn] = gfcheck(fn,setting)
            % Checks for unusual scenarios with the use of uigetfile
            % (getfilecheck)
            % Specifying a setting of 'cell' (as a string), converts a single file ref
            % (output by matlab as a char) into a cell. Multi-file refs are already
            % cells.
            
            if ischar(fn)
                if strcmp(setting,'cell')
                    fn = {fn};
                end
            else if iscell(fn)
                    if strcmp(setting,'char')
                        warning('You have multiple files selected, and are trying to treat them as one. Mistake here?')
                        pause
                    end
                    return
                else if fn == 0
                        warning('No file selected. Press Ctrl + C to terminate script, or any key to carry on.')
                        pause
                        return
                    end
                end
            end
            
        end
        
        function [hmt, tStart] = howManyTables(blockFID)
            hmt = 0;
            while ~feof(blockFID) %~feof means 'not end of file'
                line = fgetl(blockFID);
                [token, remain] = strtok(line);
                if isequal(token, 'New')
                    [token, ~] = strtok(remain);
                    if isequal(token, 'Discrimination')
                        hmt = plus(hmt,1); %increment hmt
                        tStart(hmt) = ftell(blockFID);
                    end
                end
            end
            frewind(blockFID) %rewind after finding number of tables
        end
        
        
        
        function [] = findDiscTables()
            
            for tables = 1:hmt %Loops to find more New Discrimination tables until end of document
                switch hmt
                    case 1
                        name = name1;
                    case 0
                        warning('No New Discrimination Tables detected') %unnecessary here as for loop shoulnd't run if hmt=0?
                        war = war+1;
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
        
        
    end



end

