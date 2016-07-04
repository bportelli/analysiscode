%% Proper Fit Plot FOR COMBINED (NO DIVIDING BY SESSION)
% Create a 'Plots' folder to receive!!

% NB: Mats file list (cell) will be made by the Master script

function [] = analyse(sizecvt, contcvt, Mats)
%sizecvt and contcvt are the conversion tables for sizes and contrasts,
%from the values that were written on the expt filename (as a string), to the values of
%the actual variables. They are now in the Master.

%%
for cmf = 1:length(Mats)

    load(Mats{cmf}) % Load the Current Mat File

    ct = fieldnames(datacomb);
    
for i = 1:length(ct)

    tablename = ct{i};
    
% Get the deets from the name... CHANGE THESE TO BE MORE GENERAL... AND TO
% BE OBTAINED FROM THE LIST FILES??

wi = vlookup(sizecvt,tablename(4:5));
width = wi{2};

co = vlookup(contcvt,tablename(6:7));
contrast = co{2};

latormid = mcuecomb{i};

widstr = num2str(width);
contraststr = num2str(contrast);
    
% Start calculating    

StimLevels = datacomb.(tablename).Stimulusduration'; 
NumPos = datacomb.(tablename).Response';                    
OutOfNum = ones(1,length(NumPos));     

[StimLevels NumPos OutOfNum] = PAL_PFML_GroupTrialsbyX(StimLevels, NumPos, OutOfNum);

ProportionCorrectObserved=NumPos./OutOfNum; 
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];



diary([pn,'Combined\','Outputs\','W',widstr,'C',contraststr,'_',strrep(num2str(fix(clock)),'    ',[]),'.txt'])



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
xlabel('Duration (ms)');
ylabel('Proportion Correct');

% Make a title
plottitle = [ppcode,' Width: ',widstr,' Contrast: ', contraststr];
title(plottitle);

%Threshold marker
tx = PF(paramsValues,0.75,'Inverse');
plot(tx,0.75,'bx')
text(tx,0.75,['  ',num2str(tx)])

diary off 

%Plot aesthetics


%Storage for Excel Table

% Condition{i,1} = latormid;
DurationThreshold(i,1) = tx;
Width(i,1) = str2num(widstr);
Contrast(i,1) = str2num(contraststr);

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
saveas(gcf,[pn,'Combined\','Fitting\',latormid,'W',widstr,'C',contraststr,'_',strrep(num2str(fix(clock)),'    ',[]),'.png'])
saveas(gcf,[pn,'Combined\','Fitting\',latormid,'W',widstr,'C',contraststr,'_',strrep(num2str(fix(clock)),'    ',[]),'.fig'])


close all

clear StimLevels NumPos OutOfNum latormid
end

Condition = mcuecomb';

T = table(Condition,Width,Contrast,DurationThreshold,AlphaEst,SlopeEst,AlphaSE,SlopeSE,Deviance,pvalue);
writetable(T,[pn,ppcode,'.xlsx'],'Sheet','fromfitcom')

% ratiotable = {[],'3 - LAT','3 - MID','92 - LAT','92 - MID';...
%     1.50000000000000,'=N12/MIN($N$12:$Q$14)','=O12/MIN($N$12:$Q$14)','=P12/MIN($N$12:$Q$14)','=Q12/MIN($N$12:$Q$14)';...
%     3,'=N13/MIN($N$12:$Q$14)','=O13/MIN($N$12:$Q$14)','=P13/MIN($N$12:$Q$14)','=Q13/MIN($N$12:$Q$14)';...
%     5,'=N14/MIN($N$12:$Q$14)','=O14/MIN($N$12:$Q$14)','=P14/MIN($N$12:$Q$14)','=Q14/MIN($N$12:$Q$14)'};
% 
% xlswrite([pn,ppcode,'.xlsx'],ratiotable,'fromfitcom','A15');

close all
clearvars -EXCEPT cmf Mats sizecvt contcvt
clc

end

end