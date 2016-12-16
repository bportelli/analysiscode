function [infoLi] = quick_combi()

tableref(1) = input('Paste in ref number 1');
tableref(2) = input('Paste in ref number 2');

%Variable Setup
inTaPl = {};%Info Tables placeholder
infoLi = [];
StiLeCo = [];
NuPoCo = [];
OutOfNco = [];
PF = @PAL_Weibull; 

for j = 1:2
load(['C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\COMPLETED\VBdata\Incoming\', num2str(tableref(j)), '.mat'],...
    'T1','StimLevels','NumPos','OutOfNum')
inTaPl{j} = T1;
   
%combined Table
infoLi = [infoLi; inTaPl{j}];

%combined StimLevels, NumPos and OutOfNum
StiLeCo = [StiLeCo, StimLevels];
NuPoCo = [NuPoCo, NumPos];
OutOfNco = [OutOfNco, OutOfNum];

end

% MUST RUN GROUPTRIALSBYX AGAIN BECAUSE THERE MAY NOW BE REPEATS
clear StimLevels NumPos OutOfNum

[StimLevels, NumPos, OutOfNum] = PAL_PFML_GroupTrialsbyX(StiLeCo,NuPoCo,OutOfNco);

%% Make the plot
ProportionCorrectObserved=NumPos./OutOfNum;
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];

PsychFunOut = getPsychFun();

plotting()


%% Sub functions

% Plotting
function [] = plotting()

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
%xlabel(thVar);
ylabel('Proportion Correct');

% Make a title
%name = inputdlg('Name the plot?')
%name = {name};
%plottitle = [AnaID ' ' name{1} ' ' expName{cTix}];
%title(plottitle,'interpreter','none');

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


% Getting the psychometric function details
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

end %final end