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