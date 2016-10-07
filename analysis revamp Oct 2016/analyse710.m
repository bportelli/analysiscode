%% Simple Analysis And Plot
% Just fit the function and generate the plots: keep it simple!
% NB: This is NOT compatible with tables from demo files

function outpt = analyse710()

sprintf('%0.0f',clock) %to give names

% Constants
whenRun = datetime;
runName = sprintf('%0.0f',clock);
tempSaveDir = 'C:\Users\bjp4\Documents\MATLAB\TEMP MAT FILES\';

currentTable = ?? %GET THIS


% Create TEMP SAVE MAT file and LOG
save([tempSaveDir runName '.mat'], 'whenRun');
diary([tempSaveDir runName 'log' '.txt']);

%to append use save([tempSaveDir runName '.mat'], 'VARNAME', '-append');

% Ask if bootstrapping on
[boots, ParOrNonPar]  = queryBoots(); %Currently OFF by default

% Choose the thresholded variable
thVar = getThVar(currentTable);  % Need to get the name of the current table

% Prep the variables
[StimLevels,NumPos,OutOfNum,ProportionCorrectObserved,StimLevelsFineGrain] = varPrep(currentTable,thVar);

% Evaluate Psychometric function
PsychFunOut = getPsychFun();

% Save what we've got so far
save([tempSaveDir runName '.mat'], 'StimLevels','NumPos','OutOfNum',...
    'ProportionCorrectObserved','StimLevelsFineGrain','PsychFunOut', '-append');


% Run bootstrap if requested
if boots == 1
    [bootsOut, GoFOut] = bootsfun(ParOrNonPar);
    save([tempSaveDir runName '.mat'], 'bootsOut', 'GoFOut', '-append');
end


% Make a simple plot
makePlot()


diary off


%% Sub-functions

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
        disp('Which of these is the thresholded variable?')
        thVar = input('');
        
        if ~any(ismember(fi,thVar)) %if it's not on the list, start again
            disp('INVALID RESPONSE')
            getThVar()
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
        
        %Threshold and Slope are free parameters, guess and lapse rate are fixed
        paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
        
        %Fit a function
        PF = @PAL_Weibull;  %Alternatives: PAL_Gumbel, PAL_Weibull,
        %PAL_CumulativeNormal, PAL_HyperbolicSecant,
        %PAL_Logistic
        
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

    function [] = makePlot()
        
        fhand = figure('name','Maximum Likelihood Psychometric Function Fitting');
        plot(StimLevels,ProportionCorrectObserved,'k.','markersize',40);
        set(gca, 'fontsize',16);
        set(gca, 'Xtick',StimLevels);
        axis([min(StimLevels) max(StimLevels) 0 1]);
        hold on;
        plot(StimLevelsFineGrain,PsychFunOut.ProportionCorrectModel,'g-','linewidth',4);
        xlabel(thVar);
        ylabel('Proportion Correct');
        
        % Make a title
        plottitle = [runName];
        title(plottitle,'interpreter','none');
        
        %Threshold marker
        tx = PF(PsychFunOut.paramsValues,0.75,'Inverse');
        plot(tx,0.75,'bx')
        text(tx,0.75,['  ',num2str(tx)])
    end

end

%% RESOURCES BELOW TO CANNIBALISE



%% 

for i = 1:length(ct)

    %% Naming Setups
    
    tablename = ct{i};
    
    for v = 1:length(ivlevels) %Set up a name for output files based on IV's of this file
        IVthisfile{v*2-1} = [setting.ivnames{v}];
        if isnumeric(ivlevels{v}(i))
        IVthisfile{v*2} = [num2str(ivlevels{v}(i)), '_'];     
        else
        IVthisfile{v*2} = [char(ivlevels{v}(i)), '_'];
        end
    end
    if ~isempty(sess) %i.e. if there are session numbers, because sep. files are being analysed
        IVthisfile(end+1) = {['S',sess.Session(i)]}; %NB: this only works because sess.Session is considered to be a list of STRINGS not numbers. If this changes, need to use num2str
    end
        
%% Start calculating    



diary([pn,cofref,'Outputs\',IVthisfile{:},strrep(num2str(fix(clock)),'    ',[]),'.txt'])
disp(['Commencing Analysis of ',cofref,' data files...'])


%% BOOTSTRAPPING FOR STANDARD ERRORS



end
%%
%Create simple plot


 


diary off 

%Plot aesthetics


%Storage for Excel Table

% Condition{i,1} = latormid;
Threshold(i,1) = tx;
% Width(i,1) = str2num(widstr);
% Contrast(i,1) = str2num(contraststr);

AlphaEst(i,1) = paramsValues(1); %From function fit
SlopeEst(i,1) = paramsValues(2);

AlphaSE(i,1) = SD(1); %From bootstrapping for SE's
SlopeSE(i,1) = SD(2);

Deviance(i,1) = Dev; %From Goodness-of-fit
pvalue(i,1) = pDev;

%Details appear on axes
varns = {'AlphaEst','SlopeEst','AlphaSE','SlopeSE','Deviance','pvalue'};
dtab = [AlphaEst(i,1); SlopeEst(i,1); AlphaSE(i,1); SlopeSE(i,1);Deviance(i,1); pvalue(i,1)];
thand = uitable(fhand,'Data',dtab,'RowName',varns,'Position',[350 55 170 130]);

%Save
saveas(gcf,[pn,cofref,'Fitting\',IVthisfile{:},'_',strrep(num2str(fix(clock)),'    ',[]),'.png'])
saveas(gcf,[pn,cofref,'Fitting\',IVthisfile{:},'_',strrep(num2str(fix(clock)),'    ',[]),'.fig'])


close all

clear StimLevels NumPos OutOfNum IVthisfile
end

T1 = table(ivlevelst{:},'VariableNames',setting.ivnames);
T2 = table(Threshold,AlphaEst,SlopeEst,AlphaSE,SlopeSE,Deviance,pvalue);

writetable([T1 sess T2],[pn,ppcode,'.xlsx'],'Sheet',xlshnm) %Writes the Excel Table. Also includes Session numbers (if they exist)

% ratiotable = {[],'3 - LAT','3 - MID','92 - LAT','92 - MID';...
%     1.50000000000000,'=N12/MIN($N$12:$Q$14)','=O12/MIN($N$12:$Q$14)','=P12/MIN($N$12:$Q$14)','=Q12/MIN($N$12:$Q$14)';...
%     3,'=N13/MIN($N$12:$Q$14)','=O13/MIN($N$12:$Q$14)','=P13/MIN($N$12:$Q$14)','=Q13/MIN($N$12:$Q$14)';...
%     5,'=N14/MIN($N$12:$Q$14)','=O14/MIN($N$12:$Q$14)','=P14/MIN($N$12:$Q$14)','=Q14/MIN($N$12:$Q$14)'};
% 
% xlswrite([pn,ppcode,'.xlsx'],ratiotable,'fromfitcom','A15');

close all
clearvars -EXCEPT cmf Mats 
clc



















%% Proper Fit Plot
% Create a 'Plots' folder to receive!!

% NB: Mats file list (cell) will be made by the Master script

%function [] = analyse610(Mats)
%indvars contains the list of independent variable levels corresponding to
%each expt file. It's contained within Mats.
%settings contains the settings for the expt (e.g. name and number of IV's,
%etc)
%combset sets whether or not the combined or individual expt files are
%being analysed. Inputting 'comb' makes it combined.

%%
for cmf = 4%1:length(Mats)
    
    setting.psykvn = 'Stimulusdur';
    
    load(Mats{cmf}) % Load the Current Mat File
    % Constants for this PP
    
    ct = fieldnames(data);
    data2analyse = data;
    %         ivlevels = {indvars.levelscomb}.';
    cofref = []; %combined folder ref
    xlshnm = 'fromfitsep'; %Excel sheet name
    sess = table(cellfun(@(x)(x(end)),ct),'VariableNames',{'Session'});
    
    tic;
for i = 1:length(ct)
    telaps = toc;
    waitbar(i/length(ct),sprintf('Est. time: %0.2f',telaps * (length(ct)-i)))
    tic;
    
    %% Naming Setups
    
    tablename = ct{i};
        
%% Start calculating    

StimLevels = data2analyse.(tablename).(setting.psykvn)'; %get the Psykinematix variable name e.g. Stimulusduration
NumPos = data2analyse.(tablename).Response';                    
OutOfNum = ones(1,length(NumPos));     

[StimLevels NumPos OutOfNum] = PAL_PFML_GroupTrialsbyX(StimLevels, NumPos, OutOfNum);

ProportionCorrectObserved=NumPos./OutOfNum; 
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];

diary([pn,cofref,'Outputs\','table',num2str(i),'_',strrep(num2str(fix(clock)),'    ',[]),'.txt'])
disp(['Commencing Analysis of ',cofref,' data files...'])

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

%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = 0:.1:max(StimLevels);
searchGrid.beta = linspace(0,100,101);
%searchGrid.beta = logspace(1,3,100);
searchGrid.gamma = .5;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0.05;  %ditto
%searchGrid.lambda = 0:.001:.1;

%Threshold and Slope are free parameters, guess and lapse rate are fixed
paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
 
%Fit a Logistic function
PF = @PAL_Weibull;  %Alternatives: PAL_Gumbel, PAL_Weibull, 
                     %PAL_CumulativeNormal, PAL_HyperbolicSecant,
                     %PAL_Logistic

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

%%
%Create simple plot
ProportionCorrectObserved=NumPos./OutOfNum; 
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
 
fhand = figure('name','Maximum Likelihood Psychometric Function Fitting');
plot(StimLevels,ProportionCorrectObserved,'k.','markersize',10);
set(gca, 'fontsize',16);
set(gca, 'Xtick',StimLevels);
axis([min(StimLevels) max(StimLevels) 0 1]);
hold on;
plot(StimLevelsFineGrain,ProportionCorrectModel,'g-','linewidth',4);

xlabel(setting.psykvn);
ylabel('Proportion Correct');

% Make a title
plottitle = [ppcode,num2str(i)];
title(plottitle,'interpreter','none');

%Threshold marker
tx = PF(paramsValues,0.75,'Inverse');
if and(tx<(0.9*max(StimLevels)),tx>(min(StimLevels)))
    plot(tx,0.75,'bx')
    text(tx,0.75,['  ',num2str(tx)])
else
    plot(median(StimLevels),0.50,'bx')
    text(median(StimLevels),0.50,['  ',num2str(tx)])
end

diary off 

%Plot aesthetics
set(gca,'XTickLabelRotation', 90)
set(gca,'FontSize',10)

%Storage for Excel Table

% Condition{i,1} = latormid;
Threshold(i,1) = tx;

%Save
saveas(gcf,[pn,cofref,'Fitting\','table',num2str(i),'_',strrep(num2str(fix(clock)),'    ',[]),'.png'])
saveas(gcf,[pn,cofref,'Fitting\','table',num2str(i),'_',strrep(num2str(fix(clock)),'    ',[]),'.fig'])


close all force

clear StimLevels NumPos OutOfNum IVthisfile



end

close all
clearvars -EXCEPT cmf Mats 
clc

end

%end