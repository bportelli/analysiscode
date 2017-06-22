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

function [] = splitRespWrapper(a)

if nargin <1
    [a] = gatherFile('datacomb','Exp000BJ',[]); %this looks in the default Particpants folder
    %[a] = gatherFile('datacomb','Exp000BJ','C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\Storage and Archive\Participants_v3 all with slow Full cue');
end

numOfFiles = length(a);
opts = 1; % to make it ask the first time

for k = 1:numOfFiles
    opts = doTheThing(a{k},opts);
    saveas(gcf,sprintf('%d.fig',k))
    close gcf
end

    function [opts] = doTheThing(a,opts)
        
        [ T31, thresholds, hands, shand, legHa, opts ] = SplitResponsesAndPlotMORE(a,opts);
        legendWords = get(legHa,'String');
        legendWords(ismember(legendWords,'0')) = {'DisplacedAway'};
        legendWords(ismember(legendWords,'1')) = {'DisplacedTowards'};
        
        set(legHa,'String',legendWords)
        
        pos = [363 69 262 50];
        
        fileID = fopen([num2str(k) '.txt'],'w');
        fprintf(fileID,'THRESHOLDS Together: %d , Away: %d , Towards: %d', thresholds(1),thresholds(2),thresholds(3));
        fclose(fileID);
        
    end

end


