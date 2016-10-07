%% Simple Analysis And Plot
% Just fit the function and generate the plots: keep it simple!
% NB: This is NOT compatible with tables from demo files

function [] = analyse710(data)

%sprintf('%0.0f',clock) %to give names

% Constants
currentTable = input('INPUT TABLE NAME','s'); %GET THIS
currentTable = data.(currentTable);


        PF = @PAL_Weibull;  %Alternatives: PAL_Gumbel, PAL_Weibull,
        %PAL_CumulativeNormal, PAL_HyperbolicSecant,
        %PAL_Logistic
        

whenRun = datetime;
anaID = sprintf('%0.0f',clock);
tempSaveDir = 'C:\Users\bjp4\Documents\MATLAB\TEMP MAT FILES\';


% Create TEMP SAVE MAT file and LOG
save([tempSaveDir anaID '.mat'], 'whenRun');
diary([tempSaveDir anaID 'log' '.txt']);

%to append use save([tempSaveDir anaID '.mat'], 'VARNAME', '-append');

% Ask if bootstrapping on
[boots, ParOrNonPar]  = queryBoots(); %Currently OFF by default

% Choose the thresholded variable
thVar = getThVar(currentTable);  % Need to get the name of the current table

% Prep the variables
[StimLevels,NumPos,OutOfNum,ProportionCorrectObserved,StimLevelsFineGrain] = varPrep(currentTable,thVar);

% Evaluate Psychometric function
PsychFunOut = getPsychFun();

% Save what we've got so far
save([tempSaveDir anaID '.mat'], 'StimLevels','NumPos','OutOfNum',...
    'ProportionCorrectObserved','StimLevelsFineGrain','PsychFunOut', '-append');


% Run bootstrap if requested
if boots == 1
    [bootsOut, GoFOut] = bootsfun(ParOrNonPar);
    save([tempSaveDir anaID '.mat'], 'bootsOut', 'GoFOut', '-append');
end


% Make a simple plot
[fhand, tx] = makePlot();

try
T1 = outputSaveFitDetails(fhand) %This must be before closing and saving the figure
if exist('T1','var') %append the table row to the MAT file and output it
	%Table is output
	writetable(T1,[tempSaveDir, anaID,'.csv']) %Writes the Table. Maybe better to make it a CSV or tab? 
	%writetable(T1,[tempSaveDir, anaID,'.xlsx'],'Sheet','Sheet1') %Writes the Table. Maybe better to make it a CSV or tab? 
	save([tempSaveDir anaID '.mat'], 'T1', '-append');
end
catch
warning('There was an error with generating the figure table output. Threshold-AlphaEst-SlopeEst-etc. table will not be saved')
end

saveas(fhand,[tempSaveDir anaID '.fig'])

%close(fhand)

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
        thVar = input('','s');
        
        if ~any(ismember(fi,thVar)) %if it's not on the list, start again
            disp('INVALID RESPONSE')
            error() % PUT this here to deal with the fact that it doesn't take the corrected response. Fix this.
            getThVar(currenttable)
            return
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

    function [fhand, tx] = makePlot()
        
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
        plottitle = [anaID];
        title(plottitle,'interpreter','none');
        
        %Threshold marker
		tx = PF(PsychFunOut.paramsValues,0.75,'Inverse');
		if and(tx<(0.9*max(StimLevels)),tx>(min(StimLevels)))
		plot(tx,0.75,'bx')
		text(tx,0.75,['  ',num2str(tx)])
		else
		plot(median(StimLevels),0.50,'bx')
		text(median(StimLevels),0.50,['  ',num2str(tx)])
		end

		%Plot aesthetics
		set(gca,'XTickLabelRotation', 90)
		set(gca,'FontSize',10)
		
    end

	function T1 = outputSaveFitDetails()
		%Storage for Excel Table
		Threshold = tx;
		AlphaEst = PsychFunOut.paramsValues(1); %From function fit
		SlopeEst = PsychFunOut.paramsValues(2);

		if boots == 1
		AlphaSE = bootsOut.SD(1); %From bootstrapping for SE's
		SlopeSE = bootsOut.SD(2);
		Deviance = GoFOut.Dev; %From Goodness-of-fit
		pvalue = GoFOut.pDev;
		end

		%Details appear on axes and stored in table as a row
		if boots == 1
		% Boots and GoF appear on axes...
		varns = {'AlphaEst','SlopeEst','AlphaSE','SlopeSE','Deviance','pvalue'};
		dtab = [AlphaEst; SlopeEst; AlphaSE; SlopeSE; Deviance; pvalue];
		thand = uitable(fhand,'Data',dtab,'RowName',varns,'Position',[350 55 170 130]);
		%... and stored in table alongside the anaID
		T1 = table(anaID, Threshold,AlphaEst,SlopeEst,AlphaSE,SlopeSE,Deviance,pvalue);
		else
		varns = {'AlphaEst','SlopeEst'};
		dtab = [AlphaEst; SlopeEst];
		thand = uitable(fhand,'Data',dtab,'RowName',varns,'Position',[350 55 170 130]);
		T1 = table(anaID, Threshold, AlphaEst, SlopeEst);
		end	
	end
	
	
end