function [avg, tot, reversals, han] = analyseRivalry(varsetup,data,expName,expDateSess, readID, split, oppIns)
%% Analyse Rivalry files

%% Make a wrapper function
%Include a diary for log file, and saving of plot

% Change lines for people with opposite instructions
%oppIns = 0;

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
EYES = {'Right Eye','No Button','Left Eye'};
EYENUMS = [1 0 -1];

%% Input setup
split = isequal(split,'split'); % If 'split' is specified, then separate the plots of total and average from the button-press timeline

%% Comprehension Check
%If they fail it just put a note on the plot and in the log file and carry
%on (with a warning for the log file)

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

if oppIns; btns = flip(btns); end % FOR PP WITH OPPOSITE INSTRUCTIONS
for sT = 1:2
    taNow = data.(sameTables{sT}); %table from the 'same' condition (Comprehension Check)
    [taNow] = makeVNamesGeneric(taNow); % make variable names just Input and Time
    taNow.TimeSpent = [diff(taNow.Time); CCCheckDUR-taNow.Time(end)];
    
    ix = ~cellfun('isempty',regexp(taNow.Input,btns{sT})); %Find out on which row(s) the correct button for this check is
    mstT = ismember(taNow.TimeSpent,max(taNow.TimeSpent)); %Find out on which rows most time was spent
    
    if any(mstT & ix) % if the time associated with the correct answer is the maximum time spent pressing a button...
        if sT == 2
            break %If passed again, no need to do this twice
        end
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
LR = getVal(rivTablesInfo,trial); %extract 1-3 digits to get the LR setup (see note above)
tableNow = data.(rivTables{trial});

%Make the variable names generic so that the table concatenation will work
tableNow = makeVNamesGeneric(tableNow);

%Change the Inputs to Eye References (1 is looking through right eye, -1 through left eye)
if oppIns; LR = ~LR; end %FOR USE WITH OPPOSITE INSTRUCTIONS
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

% Add last line to tableNow to show final button press (Hacky fix)
lastRow = tableNow(end,:);
lastRow.Time = (TRIALDUR*(trial))-0.0001;
tableNow(end+1,:) = lastRow;

rivTableAll = [rivTableAll; tableNow]; 
clear tableNow %make this into a function so these instructions can be deleted?
end

XandY = cell2mat((table2cell(rivTableAll)));
XandY(:,3) = [diff(XandY(:,2)); (TRIALDUR*2)-XandY(end,2)];
timePts = XandY(:,2);
buttons = XandY(:,1);

% Make fine grain data and gradual step on y axis
grain = 100;
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
% bFo = buttonsFine; %buttonsFine "old"
% tPFo = timePtsFine; %"old" 
stB = 1;
while stB < length(buttonsFine) %stepping buttonsFine (no jumping from -1 to 1 or vice versa) 
    if abs(buttonsFine(stB)-buttonsFine(stB+1))>1 %if the jump is greater than 1 
        buttonsFine = [buttonsFine(1:stB) 0 buttonsFine(stB+1:end)]; %insert a 0 step... 
        timePtsFine = [timePtsFine(1:stB) timePtsFine(stB) timePtsFine(stB+1:end)]; %...at the same time point as the previous 
        stB = stB+1; % skip 1 because it's the inserted one
    end
    stB = stB+1;
end 

%% Output Values
%Mean and Total
mn = @(x) (mean(XandY(XandY(:,1)==x,3)));
to = @(x) (sum(XandY(XandY(:,1)==x,3)));
[avg, tot] = genOutputs(mn,to);

%Reversals
reversals = 0;
rr = 0; rr2 = 0; %counters
while rr2<length(XandY) %rr2 is always ahead of rr
    rr=rr+1;
    if XandY(rr,1) == 0 %If no button is pressed here, jump to the next one (does this until a button press is reached)
        continue;    end
    val1 = XandY(rr); %Current button being pressed, to compare with next
    rr2 = rr+1;
    val2 = XandY(rr2); % Button to compare against, but it might be zero (no button pressed), so...
    
    while and(val2==0,rr2<length(XandY)) % Keep looking until it isn't
        rr2=rr2+1;
        val2 = XandY(rr2); 
    end
        
    if val1 ~= val2 % If the two subsequent button-presses are not the same, this is a reversal. If they are the same, it isn't. Carry on comparing later buttons.
        reversals = reversals+1;
        rr=rr2-1; %skip to where rr2 was (the minus 1 is to account for the incrementing at the top)
    else
        continue
    end
end

disp('****************');
for m = 1:length(avg)
    fprintf('Average (s) %s: %0.2f \n',EYES{m},avg(m));
end
disp('****************');
for m2 = 1:length(tot)
    fprintf('Total (s) %s: %0.2f \n',EYES{m2},tot(m2));
end
disp('****************');
fprintf('Number of Reversals: %d \n',reversals);
disp('****************');

%% Figure Plotting
% Setup for the Plots
%Symbols
AS = 'x'; %Average Symbol
TS = 'o'; %Total Symbol
axisSet = [0 TRIALDUR*2 -2 2]; %X axis is as long as 2 rivalry trials

% Scatter Plot Colour Settings
colours = getSomeColours();

% Make the title out of the 3rd+ inputs (if they exist)
if nargin>2
plotTitle = [expName{1},expDateSess{1},' ',readID];
else
plotTitle = [];
end

% Craete the figure
han.f = figure(1);
spm = subplot(1,1,1);

% Set up the (first) axes and begin plotting
if split
   sp1 = subplot(2,1,1);
end
axis(axisSet); %X axis is as long as 2 rivalry trials
hold on

%Shading for the plot
han.ar(1) = area(timePtsFine(buttonsFine>=0),buttonsFine(buttonsFine>=0),'EdgeColor','none','FaceColor',[0.8 0.88 0.97]);
han.ar(2) = area(timePtsFine(buttonsFine<=0),buttonsFine(buttonsFine<=0),'EdgeColor','none','FaceColor',[0.8 0.98 0.8]);
% [bottomLine, topLine] = plotColours(buttonsFine);
% plot(timePtsFine,bottomLine,'r',timePtsFine,topLine,'g');

% The data points
han.sc = scatter(timePts(buttons==0),buttons(buttons==0),30,colours(buttons==0,:),'filled');
if split % if split, then the below is on the bottom half
    sp2 = subplot(2,1,2);
    axis(axisSet) %X axis is as long as 2 rivalry trials
    hold on
end
han.avsc = scatter(avg,[1 0 -1],50,[1 0 0; 0 1 0; 0 0 1],AS);
han.tosc = scatter(tot,[1 0 -1],50,[1 0 0; 0 1 0; 0 0 1],TS);

%% Plot Annotations and Title
if split % if split, then the below is in the top half
    subplot(sp1); end
text(30,-1.5,compCheck,'color','r') % Prints in red if they've failed the comprehension check
text(30,1.5,sprintf('Reversals: %d',reversals),'color','k') % Shows the number of reversals

% Legend Stuff for Averages and Totals
if split % if split, then the below is in the bottom half
    subplot(sp2); end
han.legAX = scatter(0,0,1,['k' AS],'Visible','off');
han.legTX = scatter(0,0,1,['k' TS],'Visible','off');
han.Leg = legend([han.legAX han.legTX],{'Averages', 'Totals'});

%Average and Total
for avN = 1:length(avg)
text(avg(avN)+2,2-(avN)+0.2,sprintf('Average: %.2f',avg(avN)))
text(avg(avN)+2,2-(avN)-0.2,sprintf('Total: %.2f',tot(avN)))
end

% Make the axis labels
if exist('sp1','var')
    p1=get(sp1,'position');
    p2=get(sp2,'position');
    height=p1(2)+p1(4)-p2(2);
    spm=axes('position',[p2(1) p2(2) p2(3) height],'visible','off'); %change the value of spm to be the 'main' axes
end
title(spm, plotTitle,'interpreter','none','Visible','on')
ylabel(spm,'Right Eye (1), Left Eye (-1), or No Button (0)','Visible','on')
xlabel(spm,'Time in seconds','Visible','on')


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

    function colours = getSomeColours()
        colours = nan(length(buttons),3);
        cols = eye(3);
        fRow = @(x) find(buttons == x);
        for ey = 1:3
            eyN = EYENUMS(ey);
            for cc = 1:3
                colours(fRow(eyN),cc) = deal(cols(ey,cc));
            end
        end
    end

    function [avg, tot] = genOutputs(fAv,fTo)
        avg = nan(1,3); tot = nan(1,3);
        for eyn = 1:3
            eyN = EYENUMS(eyn);
            avg(eyn) = fAv(eyN);
            tot(eyn) = fTo(eyN);
        end
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
