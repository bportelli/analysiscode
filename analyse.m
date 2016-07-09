%% Proper Fit Plot
% Create a 'Plots' folder to receive!!

% NB: Mats file list (cell) will be made by the Master script

function [] = analyse(Mats, settings, combset)
%indvars contains the list of indipendent variable levels corresponding to
%each expt file. It's contained within Mats.
%settings contains the settings for the expt (e.g. name and number of IV's,
%etc)
%combset sets whether or not the combined or individual expt files are
%being analysed. Inputting 'comb' makes it combined.

%%
for cmf = 1:length(Mats)
    
    load(Mats{cmf}) % Load the Current Mat File
    % Constants for this PP
    
    setting = settings(exptnum);

    if strcmp(combset,'comb') %check if combined expt files are being analysed, or individual runs
        ct = fieldnames(datacomb);
        data2analyse = datacomb;
        ivlevels = {indvars.levelscomb}.';
        cofref = 'Combined\'; %combined folder ref
        xlshnm = 'fromfitcom'; %Excel sheet name
        sess = []; %session numbers n/a with combined files
    else %if not nombined, then individual/'separate' runs
        ct = fieldnames(data);
        data2analyse = data;
        ivlevels = {indvars.levels}.';
        cofref = [];
        xlshnm = 'fromfitsep';
        sess = table(cellfun(@(x)(x(end)),ct),'VariableNames',{'Session'}); %Make the 'table' of session numbers, ready to be put in the final table. Note that this returns a table of numbers formatted as STRINGS, which is helpful when making IVthisfile.
    end
    
    for tt = 1:length(ivlevels) %set up a transposed version of ivlevels for Excel Table
        ivlevelst{1,tt} = ivlevels{tt}';
    end
    
%     for ii = 1:length(ivlev)
%     ivlevels{ii,1} = cellfun(@char,ivlev{ii,1},'UniformOutput',false);
%     end
%     
    
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

StimLevels = data2analyse.(tablename).(setting.psykvn)'; %get the Psykinematix variable name e.g. Stimulusduration
NumPos = data2analyse.(tablename).Response';                    
OutOfNum = ones(1,length(NumPos));     

[StimLevels NumPos OutOfNum] = PAL_PFML_GroupTrialsbyX(StimLevels, NumPos, OutOfNum);

ProportionCorrectObserved=NumPos./OutOfNum; 
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];

diary([pn,cofref,'Outputs\',IVthisfile{:},strrep(num2str(fix(clock)),'    ',[]),'.txt'])
disp(['Commencing Analysis of ',cofref,' data files...'])

message = 'Bootstrapping on?';
boots = 1; %input(message);

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

%% BOOTSTRAPPING FOR STANDARD ERRORS
%Number of simulations to perform to determine standard error

if boots==1

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


end
%%
%Create simple plot
ProportionCorrectObserved=NumPos./OutOfNum; 
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
 
fhand = figure('name','Maximum Likelihood Psychometric Function Fitting');
plot(StimLevels,ProportionCorrectObserved,'k.','markersize',40);
set(gca, 'fontsize',16);
set(gca, 'Xtick',StimLevels);
axis([0 max(StimLevels) 0 1]);
hold on;
plot(StimLevelsFineGrain,ProportionCorrectModel,'g-','linewidth',4);
xlabel(setting.thv);
ylabel('Proportion Correct');

% Make a title
plottitle = [ppcode,' ',IVthisfile{:}];
title(plottitle);

%Threshold marker
tx = PF(paramsValues,0.75,'Inverse');
plot(tx,0.75,'bx')
text(tx,0.75,['  ',num2str(tx)])

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

clear StimLevels NumPos OutOfNum 
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

end

end