function [] = analyseRivalry(varsetup,data,expName,expDateSess, readID)
%% Analyse Rivalry files

%% Note on LR: winopen('C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\LRsetup.bmp')
% When LR is 0, 135 deg is in Left eye, and 45 deg is in right eye
% When LR is 1, 45 deg is in Left eye and 135 deg is in right eye



%% REMEMBER TO STICK IN A FEW LINES FOR THE COMPREHENSION CHECK AT THE BEGINNING

%If they fail it just put a note on the plot and in the log file and carry
%on (or make a window pop up? and carry on)

% Also needs adding: Statistics. Extract from Psyk outputs and/or calculate
% my own?

%% Constants
TRIALDUR = 30; %Duration of each rivalry "trial" in seconds
rivTables = {'ExpDL8JI13MI','ExpDL8JI14MI'};
rivTablesInfo = {'table3ND','table4ND'};
rivTablesVnames = {'Trial1Input','Trial2Input'};
genericNames = {'Input','Time'};
rivTableAll = [];

%% Loop through the 'Trials'
for trial = 1:2
LR = str2double(cell2mat(regexp(varsetup.(rivTablesInfo{trial}),'\d{1,3}','match'))); %extract 1-3 digits to get the LR setup (see note above)
tableNow = data.(rivTables{trial});

%Make the variable names generic so that the table concatenation will work
refs = cellfun('isempty',regexp(tableNow.Properties.VariableNames,'Input'))+1;
tableNow.Properties.VariableNames = genericNames(refs);

%Change the Inputs to Eye References (1 is looking through right eye, -1 through left eye)
if LR %IF LR IS 1
    % Here, 'Left Shift' is looking through right eye
    tableNow = changeToEye(tableNow,[0,-1,1]); %second input in: 'None','Right Shift','Left Shift'
else %IF LR IS 0
    % Here, 'Right Shift' is looking through right eye
    tableNow = changeToEye(tableNow,[0,1,-1]);
end

% Put in the correct timings (if trial 2, then push forward by 30 sec
if trial==2
    tableNow.Time = tableNow.Time + TRIALDUR;
end

rivTableAll = [rivTableAll; tableNow]; 
clear tableNow holder %make this into a function so these instructions can be deleted
end

XandY = cell2mat((table2cell(rivTableAll)));
timePts = XandY(:,2);
buttons = XandY(:,1);

%create the line
newC = 0; %counter variable
ptsForLine = zeros(length(XandY)*2-1,2); %pre-allocation
for k = 1:length(XandY)
    newC = newC + 1;
    ptsForLine(newC,1:2)=XandY(k,1:2);
    if k == length(XandY) %if this is the end...
        newC = newC + 1;
        ptsForLine(newC,1:2)=[XandY(k,1), 60];
        break
    end  
    
%     if abs(XandY(k+1,1)-ptsForLine(newC,1))>1 %This needs to be done twice, to make sure there are no missing steps, but can it be made more elegant?
%         newC = newC + 1;
%         ptsForLine(newC,1:2)=[0, XandY(k,2)];
%     end
    
    newC = newC + 1;
    ptsForLine(newC,1:2)=[XandY(k,1), XandY(k+1,2)];
    
%     if abs(XandY(k+1,1)-ptsForLine(newC,1))>1
%         newC = newC + 1;
%         ptsForLine(newC,1:2)=[0, XandY(k,2)];
%     end

end
timePtsLine = ptsForLine(:,2);
buttonsLine = ptsForLine(:,1);

colours(buttons == 1) = 1;
colours(buttons == 0) = 2;
colours(buttons == -1) = 3;

% buttons == 1;
% colours(find(buttons == 1),1:3) = [1 0 0];
% colours(find(buttons == 0),1:3) = [0 1 0];
% colours(find(buttons == -1),1:3) = [0 0 1];

if nargin>2
plotTitle = [expName{1},expDateSess{1},' ',readID];
else
plotTitle = [];
end

figure
axis([0 max(timePtsLine) -2 2])
hold on
title(plotTitle,'interpreter','none')
scatter(timePts,buttons,30,colours,'filled')

%[bottomLine, topLine] = plotColours(buttonsLine);
%plot(timePtsLine,bottomLine,'r',timePtsLine,topLine,'g');

plot(timePtsLine,buttonsLine);

ylabel('Right Eye (1), Left Eye (-1), or No Button (0)')
xlabel('Time in sec')

%% Sub-functions
    function [ta] = changeToEye(ta,in) %in: 'None','Right Shift','Left Shift'
        inInput = @(x)((ismember(ta.Input,x)));
        holder = {};
        holder(inInput('None')) = {in(1)};
        holder(inInput('Right Shift')) = {in(2)};
        holder(inInput('Left Shift')) = {in(3)}; %looking through right eye
        ta.Input = holder';
    end

    function [bottomLine, topLine] = plotColours(y)
        % Data is function input
        
        % Level for Color Change
        lev = 0;
        % Find points above the level
        aboveLine = (y>=lev);
        % Create 2 copies of y
        bottomLine = y;
        topLine = y;
        % Set the values you don't want to get drawn to nan
        bottomLine(aboveLine) = NaN;
        topLine(~aboveLine) = NaN;
    end


end
