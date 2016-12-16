%% Simple Analysis And Plot
% Just fit the function and generate the plots: keep it simple!
% NB: This is NOT compatible with tables from demo files - it automatically skips them!
% The Temporary Save directory is TempSaveDir = 'C:\Users\bjp4\Documents\MATLAB\TEMP FILES\';
% NB: Remember that the inputs and inputdlg's are currently automated (some replaced by disp)

function [] = analyse710_auto(data, expName, expDateSess, readID, pn, name)

% NAME VARIABLE ADDED - REMOVE IF MAKING MANUAL

%sprintf('%0.0f',clock) %to give names

% notDemos = find(cellfun(@(x)isempty(x),(regexp(expName,'demo')))); %find the indices of files that are not demo files

% Add Palamedes to path
%addpath(genpath('C:\Users\bjp4\Documents\MATLAB\Toolboxes'));

%name = input('INPUT NAME FOR PLOT\n','s');
combi = []; %input('Is this a single (Enter) or combi (1) file?');

if combi
    %TempSaveDir = 'C:\Users\bjp4\Documents\MATLAB\TEMP FILES\';
    TempSaveDir = [pn '\Combined\'];
else
    TempSaveDir = [pn '\Incoming\'];
end

Tcoll = [];

k=1;
        while k <= length(fieldnames(data)) 
            
%% Constants
WHENRUN = datetime;
mainMAT = readID;
AnaID = sprintf('%0.0f',clock);

PF = @PAL_Weibull;  %Alternatives: PAL_Gumbel, PAL_Weibull,
%PAL_CumulativeNormal, PAL_HyperbolicSecant,
%PAL_Logistic

% Create TEMP SAVE MAT file and LOG
save([TempSaveDir AnaID '.mat'], 'WHENRUN','mainMAT');
diary([TempSaveDir AnaID 'log' '.txt']);

%to append use save([TempSaveDir AnaID '.mat'], 'VARNAME', '-append');

%% Get Inputs
[currentTable, cTix] = getCurrentTable();

% Ask if bootstrapping on
[boots, ParOrNonPar]  = queryBoots(); %Currently OFF by default

% Choose the thresholded variable
thVar = getThVar(currentTable);  % Need to get the name of the current table

%% The Analysis Process
% Prep the variables
[StimLevels,NumPos,OutOfNum,ProportionCorrectObserved,StimLevelsFineGrain] = varPrep(currentTable,thVar);

% Evaluate Psychometric function
PsychFunOut = getPsychFun();

% Save what we've got so far
save([TempSaveDir AnaID '.mat'], 'StimLevels','NumPos','OutOfNum',...
    'ProportionCorrectObserved','StimLevelsFineGrain','PsychFunOut', '-append');


% Run bootstrap if requested
if boots == 1
    [bootsOut, GoFOut] = bootsfun(ParOrNonPar);
    save([TempSaveDir AnaID '.mat'], 'bootsOut', 'GoFOut', '-append');
end

% Make a simple plot
[fhand, tx] = makePlot(name);

try
    T1 = outputSaveFitDetails(fhand); %This must be before closing and saving the figure
    if exist('T1','var') %append the table row to the MAT file and output it
        %Table is output
        %writetable(T1,[TempSaveDir, AnaID,'.csv'],'Delimiter','\t') %Writes the Table. Maybe better to make it a CSV or tab?
        
        %writetable(T1,[TempSaveDir, AnaID,'.xlsx'],'Sheet','Sheet1') %Writes the Table. Maybe better to make it a CSV or tab?
        ENameDate = {expName{cTix},expDateSess{cTix}};
        save([TempSaveDir AnaID '.mat'], 'T1','ENameDate', '-append');
        Tcoll = [Tcoll; T1]; 
    end
catch
    warning('There was an error with generating the figure table output.')
    warning('Threshold-AlphaEst-SlopeEst-etc. table will not be saved (also other parts of the MAT file).')
end

saveas(fhand,[TempSaveDir AnaID '.fig'])

%close(fhand)

diary off

k = plus(k,1); %increment k AND...

while k <= length(fieldnames(data)) && ~isempty(regexp(expName{k},'demo','ONCE'))
    %...check if this is a demo file, increment again if so (PRESERVE THE ABOVE ORDER for the short-circuit AND)
    k = plus(k,1);
end
    
        end
        
        save([TempSaveDir 'collectedTable'],'Tcoll') %save MAT
        writetable(Tcoll,[TempSaveDir 'collectedTable.csv'])
        writetable(Tcoll,[TempSaveDir 'collectedTable.xls'])

%% Sub-functions

    function [currentTable, cTix] = getCurrentTable()
        fnD = fieldnames(data);
        disp([fnD, expName'])
        disp('TABLE NAME');
        currentTable = fnD{k};
        disp(currentTable)
        cTix = ismember(fnD,currentTable);
        fprintf('Chosen Table: %s run on %s\n',expName{cTix},expDateSess{cTix});
        ctn = 1; %input('Continue (1) or select another(0)?\n');
        if ~isempty(ctn)
        switch ctn
            case 0 %select other
                currentTable = input('INPUT TABLE NAME\n','s');
                cTix = ismember(fnD,currentTable);
                fprintf('Chosen Table: %s run on %s\n',expName{cTix},expDateSess{cTix});
                k = find(cTix);
            case 1
                %just carry on
            otherwise
                disp('INVALID INPUT')
                [currentTable, cTix] = getCurrentTable();
                return
        end
        end
        currentTable = data.(currentTable);
    end


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
        thVar = 'Stimulusdur';
        fprintf('%s is the thresholded variable. Enter to confirm, or Type another one.',thVar)
        thQ = [];%input('','s');
        if ~isempty(thQ)
            thVar = thQ;
        end
        
        if ~any(ismember(fi,thVar)) %if it's not on the list, start again
            disp('INVALID THRESHOLDED VARIABLE')
            %error('') % PUT this here to deal with the fact that it doesn't take the corrected response. Fix this.
            pause
            thVar = getThVar(currenttable);
        end
    end


    function [StimLevels,NumPos,OutOfNum,ProportionCorrectObserved,StimLevelsFineGrain] = varPrep(currentTable,thVar) %Prep the variables
        StimLevels = currentTable.(thVar)'; %get the Psykinematix variable name e.g. Stimulusduration
        NumPos = currentTable.Response';
        OutOfNum = ones(1,length(NumPos));
        
        [StimLevels NumPos OutOfNum] = PAL_PFML_GroupTrialsbyX(StimLevels, NumPos, OutOfNum);
        
        ProportionCorrectObserved=NumPos./OutOfNum;
        StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
    end


    function PsychFunOut = getPsychFun()
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


    function [bootsOut, GoFOut] = bootsfun(ParOrNonPar)
        
        %Number of simulations to perform to determine standard error
        B=400;
        
        disp('Determining standard errors.....');
        
        if ParOrNonPar == 1
            [SD paramsSim LLSim converged] = PAL_PFML_BootstrapParametric(...
                StimLevels, OutOfNum, paramsValues, paramsFree, B, PF, ...
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
            paramsValues, paramsFree, B, PF,'searchOptions',options, ...
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

    function [fhand, tx] = makePlot(name)
        
        close gcf
        
        fhand = figure('name','Maximum Likelihood Psychometric Function Fitting');
        
        %if combi
            scatter(StimLevels,ProportionCorrectObserved,...
                'ko','MarkerFaceColor',[0.5 0.5 0.5],'SizeData',OutOfNum*5);
        %else
        %    plot(StimLevels,ProportionCorrectObserved,'k.','markersize',30);
        %end
        hold on
        set(gca, 'fontsize',16);
        set(gca, 'Xtick',StimLevels);
        %axis([min(StimLevels) max(StimLevels) 0 1]);
        axis([20 600 0 1]);
        hold on;
        plot(StimLevelsFineGrain,PsychFunOut.ProportionCorrectModel,'g-','linewidth',4);
        xlabel(thVar);
        ylabel('Proportion Correct');
        
        % Make a title
        %name = inputdlg('Name the plot?')
        name = {name};
        plottitle = [AnaID ' ' name{1} ' ' expName{cTix}];
        title(plottitle,'interpreter','none');
        
        %Threshold marker
        tx = PF(PsychFunOut.paramsValues,0.75,'Inverse');
        if and(tx<(0.9*max(StimLevels)),tx>(min(StimLevels)))
            plot(tx,0.75,'bx')
            text(tx,0.75,['  ',num2str(tx)])
        else
            plot(median(StimLevels),0.40,'bx')
            te = text(median(StimLevels),0.40,['  ',num2str(tx)]);
            set(te, 'FontAngle','italic')
        end
        
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
        if boots == 1
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


end