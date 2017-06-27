function [] = analyseRivalry(varsetup,data,expName,expDateSess, readID)
%% Analyse Rivalry files

%% Make a wrapper function
%Include a diary for log file, and saving of plotbj


% Also needs adding: Statistics. Extract from Psyk outputs and/or calculate
% my own?

%% Note on LR: winopen('C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\LRsetup.bmp')
% When LR is 0, 135 deg is in Left eye, and 45 deg is in right eye
% When LR is 1, 45 deg is in Left eye and 135 deg is in right eye

%% Constants
TRIALDUR = 30; %Duration of each rivalry "trial" in seconds=
CCCheckDUR = 15; %Duration of each rivalry "trial" in seconds
rivTables = {'ExpDL8JI13MI','ExpDL8JI14MI'};
sameTables = {'ExpDL8JI11MI','ExpDL8JI12MI'};
rivTablesInfo = {'table3ND','table4ND'};
sameTablesInfo = {'table1ND','table2ND'};
rivTablesVnames = {'Trial1Input','Trial2Input'};
genericNames = {'Input','Time'};
rivTableAll = [];
ShiftKeys = {'Left Shift', 'Right Shift'};
getVal = @(x,y)(str2double(cell2mat(regexp(varsetup.(x{y}),'\d{1,3}','match'))));

%% Comprehension Check
%If they fail it just put a note on the plot and in the log file and carry
%on (or make a window pop up? and carry on)

%Check in what order comprehension check was done, flip button order (or not) accordingly
ori = getVal(sameTablesInfo,1); %extract 1-3 digits to get the orientation of the first 'same' condition

switch ori
    case 135
        btns = ShiftKeys;
    case 45
        btns = flip(ShiftKeys);
    otherwise
        warning('Orientation not correctly obtained. ERROR IMMINENT.')
end

for sT = 1:2
    taNow = data.(sameTables{sT}); %table from the 'same' condition (Comprehension Check)
    [taNow] = makeVNamesGeneric(taNow); % make variable names just Input and Time
    
    ix = ~cellfun('isempty',regexp(taNow.Input,btns{sT})); %Find out on which row the correct button for this check is
    
    if max(taNow.Time) == taNow.Time(ix) % if the time associated with the correct answer is the maximum time...
        compCheck = '';
        disp('Comprehension check passed')
    else
        compCheck = 'Comprehension check failed';
        warning(compCheck) % and do something else? Mark the plot maybe?
        break % break the loop to make sure this message is written to the plot
    end
end


%% Loop through the 'Trials'
for trial = 1:2
LR = getVal(sameTablesInfo,trial); %extract 1-3 digits to get the LR setup (see note above)
tableNow = data.(rivTables{trial});

%Make the variable names generic so that the table concatenation will work
tableNow = makeVNamesGeneric(tableNow);

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

% Make fine grain data and gradual step on y axis
grain = 500;
for fgT = 1:length(timePts) 
    timePtsFine((grain*(fgT-1))+1) = timePts(fgT);
    if fgT~=length(timePts)
    timePtsFine((grain*(fgT-1))+1:(grain*(fgT-1))+(grain+1)) = linspace(timePts(fgT),timePts(fgT+1),grain+1);
    end
end
for fgB = 1:length(buttons) 
    buttonsFine((grain*(fgB-1))+1) = buttons(fgB);
    if fgB~=length(buttons)
    buttonsFine((grain*(fgB-1))+1:(grain*(fgB-1))+grain) = deal(buttons(fgB));
    end
end
for stB = 1:length(buttonsFine) %stepping buttonsFine (no jumping from -1 to 1 or vice versa)
    if abs(buttonsFine(stB)-buttonsFine(stB+1))>1 %if the jump is greater than 1
        buttonsFine = [buttonsFine(1:stB) 0 buttonsFine(stB:end)]; %insert a 0 step...
        timePtsFine = [timePtsFine(1:stB) timePtsFine(stB) timePtsFine(stB:end)]; %...at the same time point as the previous
    end
end


% Scatter Plot Colours - Doesn't actually seem to be having any effect
colours = [];
fRow = @(x) find(buttons == x);
colours(fRow(1),1) = deal(1); % Red
colours(fRow(1),2) = deal(0); % Green
colours(fRow(1),3) = deal(0); % Blue

colours(fRow(0),1) = deal(0);
colours(fRow(0),2) = deal(1);
colours(fRow(0),3) = deal(0);


colours(fRow(-1),1) = deal(0);
colours(fRow(-1),1) = deal(0);
colours(fRow(-1),1) = deal(1);


% buttons == 1;
% colours(find(buttons == 1),1:3) = [1 0 0];
% colours(find(buttons == 0),1:3) = [0 1 0];
% colours(find(buttons == -1),1:3) = [0 0 1];

if nargin>2
plotTitle = [expName{1},expDateSess{1},' ',readID];
else
plotTitle = [];
end

%% Output Values
mn = @(x) (mean(XandY(XandY(:,1)==x,2)));
avg(1) = mn(1); %mean time looking through right eye - NO IT ISN'T, BUT IT'S THE FIRST STEP TO DOING IT
avg(2) = mn(0); 
avg(3) = mn(-1);


%%
figure(1)
axis([0 TRIALDUR*2 -2 2]) %X axis is as long as 2 rivalry trials
hold on
scatter(timePts(buttons==0),buttons(buttons==0),30,colours(buttons==0),'filled')
sh = stairs(timePts,buttons,'Color','k','LineWidth',1);
% patch(timePtsFine(buttonsFine>=0),buttonsFine(buttonsFine>=0),'r');
area(timePtsFine,buttonsFine,'EdgeColor','none','FaceColor',[0.8 0.88 0.97])

% area(timePtsFine(buttonsFine>=0),buttonsFine(buttonsFine>=0),'EdgeColor','none','FaceColor',[0.8 0.88 0.97])

% [bottomLine, topLine] = plotColours(buttonsFine);
% plot(timePtsFine,bottomLine,'r',timePtsFine,topLine,'g');

title(plotTitle,'interpreter','none')
text(30,-1.5,compCheck,'color','r') % Prints in red if they've failed the comprehension check

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


    function [ta] = makeVNamesGeneric(ta)
        refs = cellfun('isempty',regexp(ta.Properties.VariableNames,'Input'))+1;
        ta.Properties.VariableNames = genericNames(refs);
    end

end

%% Spare Code for old/other versions of stairs 
% 
% %create the line (stairs)
% newC = 0; %counter variable
% ptsForLine = zeros(length(XandY)*2-1,2); %pre-allocation
% for k = 1:length(XandY)
%     newC = newC + 1;
%     ptsForLine(newC,1:2)=XandY(k,1:2);
%     if k == length(XandY) %if this is the end...
%         newC = newC + 1;
%         ptsForLine(newC,1:2)=[XandY(k,1), 60];
%         break
%     end  
%     
% %     if abs(XandY(k+1,1)-ptsForLine(newC,1))>1 %This needs to be done twice, to make sure there are no missing steps, but can it be made more elegant?
% %         newC = newC + 1;
% %         ptsForLine(newC,1:2)=[0, XandY(k,2)];
% %     end
%     
%     newC = newC + 1;
%     ptsForLine(newC,1:2)=[XandY(k,1), XandY(k+1,2)];
%     
% %     if abs(XandY(k+1,1)-ptsForLine(newC,1))>1
% %         newC = newC + 1;
% %         ptsForLine(newC,1:2)=[0, XandY(k,2)];
% %     end
% 
% end
% timePtsLine = ptsForLine(:,2);
% buttonsLine = ptsForLine(:,1);
% 
% 
% plot(timePtsLine,buttonsLine);
% 
% % Different ways to get the fill colour. This top method should also make
% % the stairs-creation loop redundant if it works
%    X = [timePtsLine(2:end); timePtsLine(2:end)]; X = X(:);
%    Y = [buttonsLine(1:end-1); buttonsLine(2:end)]; Y = Y(:);
%    fill(X,Y,'c')
% 
%    
% %[bottomLine, topLine] = plotColours(buttonsLine);
% %plot(timePtsLine,bottomLine,'r',timePtsLine,topLine,'g');
%    
% %area(timePtsLine,buttonsLine);
% 
% %      sh=stairs(x,y);
% %      xd=get(sh,'xdata');
% %      yd=get(sh,'ydata');
% %      patch(xd,yd,'r');


