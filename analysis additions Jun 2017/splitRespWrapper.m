%% "Wrapper" script/function for the Split Responses and Plot (to do all the pp files)

% % participant folder directory
% ppfolderDir = 'C:\Users\Benjamin Work\Google Drive\STUDIES\Slides\MID meeting Jun 2017\MID meeting Jun 2017\June 2017\Study 6 Analysis\Participants\';
%
% % get the list of participant folders
% d = dir(ppfolderDir);
% d = {d.name}.';
% d = d(cellfun('isempty',regexp(d,'\.'))); % removes anything that isn't a folder (things that aren't folders have a dot)
%
% % for pp = 1:length(d) % for every participant folder (in d)
%
%     currentPPdir = [ppfolderDir d{pp} '\'];
%
%     PPdatafiles = dir(currentPPdir);
%     PPdatafiles = {PPdatafiles.name}.';
%     PPdatafiles = PPdatafiles(~[cellfun('isempty',regexp(PPdatafiles,'Exp_000B6_'))]);
%
%     if length(PPdatafiles) > 1
%         warning(sprintf('Participant %s has more than one disparity file, first one will be used'))
%     end
%
%     PPdatafiles = PPdatafiles{1};
%
%
% end

% initialise pp manually
%
%
%     figure(2)
%     suha = subplot(9,1,pp);
%     hold on
%
%     copyobj([hands, shand, legHa],suha)
%
%     pp = pp+1;

function [a] = splitRespWrapper(a)

pl = 1; %Plotting? (switched on by default, otherwise this produces only MAT files)
FinalT = nan;

if nargin <1
    % [a] = gatherFile('datacomb','Exp000BJ','D:\Work\MATLAB\ParticipantsNOW'); % For use on LAPTOP
    [a] = gatherFile('datacomb','Exp000BJ',[]); %this looks in the default Particpants folder
    %[a] = gatherFile('datacomb','Exp000BJ','C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\Storage and Archive\Participants_v3 all with slow Full cue');
end

numOfFiles = length(a);
opts = 1; % to make it ask the first time

for k = 1:numOfFiles
    [opts, T31, thresholds, varAndPFOut] = doTheThing(a{k},opts);
    save(sprintf('%d.mat',k),'opts', 'T31', 'thresholds', 'varAndPFOut','FinalT');
    if pl
        saveas(gcf,sprintf('%d.fig',k))
        saveas(gcf,sprintf('%d.png',k))
        close gcf
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [opts, T31, thresholds, varAndPFOut] = doTheThing(aDTT,opts)
        
        [ T31, thresholds, hands, shand, legHa, varAndPFOut, opts ] = SplitResponsesAndPlotMORE(aDTT,opts,pl);
        
        if varAndPFOut(1).funcOpts{1}==3
            % Make a struct with the proportion Test responded nearer data...
            toStruct = {'opts', 'T31', 'thresholds', 'varAndPFOut'};
            for ka = 1:length(toStruct)
                pt.(toStruct{ka}) = eval(toStruct{ka});
            end
            
            % Get the proportion correct data...
            pc = getPC(aDTT);
            
            % Submit both of these to be compared, to get the final threshold
            [FinT] = staticDispthreshold(pc,pt);
            FinalT = FinT(2);
        end
        
        
        if pl
            legendWords = get(legHa,'String');
            legendWords(ismember(legendWords,'0')) = {'DisplacedAway'};
            legendWords(ismember(legendWords,'1')) = {'DisplacedTowards'};
            
            set(legHa,'String',legendWords)
            if varAndPFOut(1).funcOpts{1}==3
                xloc = FinalT+0.05;
                if xloc > 0.6
                    xloc = FinalT-7;
                end
                text(xloc,0.5,sprintf('Threshold: %.2f',FinalT))
            end
            
            axhan = findobj(gcf,'type','Axes');
            interv = max(1,abs(varAndPFOut(1).StimLevels(1)-varAndPFOut(1).StimLevels(2))); % interval floored at 1
            newlab = varAndPFOut(1).StimLevels(1):interv:varAndPFOut(1).StimLevels(length(varAndPFOut(1).StimLevels));
            set(axhan,'Xtick',newlab);            
        end
        %pos = [363 69 262 50];
        
        fileID = fopen([num2str(k) '.txt'],'w');
        fprintf(fileID,'Final Threshold: %.3f, Thresholds Together: %.3f , Away: %.3f , Towards: %.3f',...
            FinalT,thresholds(1),thresholds(2),thresholds(3));
        fclose(fileID);
        
    end


    function pc = getPC(apc)
        
        %get the threshold for PC, no plot needed here
        [T, T311pc, thresholds1pc, hands1pc, shand1pc, legHa1pc, varAndPFOut1pc, opts1pc ] =...
            evalc('SplitResponsesAndPlotMORE(apc,{[1] ''Proportion Correct'' ''isTowards''},0)'); % Run silently (with suppressed output) to get PC data
        
        toStruct = {'opts1pc', 'T311pc', 'thresholds1pc', 'varAndPFOut1pc'};
        for ka = 1:length(toStruct)
            pc.(toStruct{ka}(1:end-3)) = eval(toStruct{ka});
        end
        
        
    end

end


