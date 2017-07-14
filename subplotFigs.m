function [] = subplotFigs()
%% UNFINISHED FUNCTION: FINISH DEPENDING ON WHAT YOU WANT TO USE IT TO COMBINE

%subplotFigs Combines existing fig files into subplots, as the first step
%to presentation-ready figs
% 2 figs are formatted as a 1x2 subplot, 3-4 inputs are 2x2, and 5-6 are 2x3.

% %Constant
% StudyDir = 'C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\Participants';
% %StudyDir = 'D:\Work\MATLAB\AllParticipants';
% 
% %Initial Setup (Semi-Constant)
% NAMES = getNames(StudyDir);
% if isempty(NAMES); return; end % If cancelled, exit gracefully

StudyDir = 'C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\For Julie\MiD Psychometric functions and log files';
folderN = whichFolder();

% for ppa = 1:length(NAMES)
%     amPN{ppa} = [StudyDir '\' NAMES{ppa} '\' folderN];
% end

for pp = 1:length(NAMES)
    fM = 0; %figs Made for this participant is zero here
    
    diary(sprintf('%d.txt',pp))
  
    % Get into each NAME\folder and list the figs to be input into the
    % function. Split them into groups of 6.
    
    
    
    % save figures to the MATLAB root, collect them from there
    %saveas(gcf,sprintf('%s.fig',fnm{pp}(1:end-4)))
    saveas(gcf,sprintf('%d.fig',pp))
    
    close gcf
    diary off
    
end



%% Sub-function
    function folderN = whichFolder()
        str = {'Separated','Combined'};
        [s,~] = listdlg('PromptString','Select Folder:',...
            'SelectionMode','single',...
            'ListString',str);
        folderN = str(s);
    end


function [  ] = subplotFigs_main(figs )
%subplotFigs Combines existing fig files into subplots, as the first step
%to presentation-ready figs
% The input should be paths to the figs (each one in a cell). 2 inputs are
% formatted as a 1x2 subplot, 3-4 inputs are 2x2, and 5-6 are 2x3.

% Function Setup
len = length(figs);
switch len
    case num2cell(1,2); r = 1; c = 2;
    case num2cell(3,4); r = 2; c = 2;
    case num2cell(5,6); r = 2; c = 3;
    otherwise
        warning('subplotFigs can''t handle this many figures yet')
        pause
        return
end

% Catch mistakes? (This could be on purpose)
if len == 1
   disp('Heads up: There''s only 1 file here.') 
end

%% Open the figures and get handles
h = gobjects(1,len); % Preallocate space
ax = gobjects(1,len);
for fi = 1:len
    h(fi) = openfig(figs{fi},'reuse'); % open figure
    ax(fi) = gca;
end

%% Let the Fun (Combining) Begin
fh = figure; %create new figure

sh = gobjects(1,len); % Preallocate space
for sp = 1:len
    sh(sp) = subplot(r,c,sp); %create and get handle to the subplot axes
end

for ff = 1:len
    fig(ff) = get(ax(ff),'children'); %get handle to all the children in the figure
end

for cc = 1:len
    copyobj(fig(cc),sh(cc)); %copy children to new parent axes i.e. the subplot axes
end




%%%%%%%%%%%%%%%%%%%%%
h1 = openfig('test1.fig','reuse'); % open figure
ax1 = gca; % get handle to axes of figure
h2 = openfig('test2.fig','reuse');
ax2 = gca;
% test1.fig and test2.fig are the names of the figure files which you would % like to copy into multiple subplots
h3 = figure; %create new figure
s1 = subplot(2,1,1); %create and get handle to the subplot axes
s2 = subplot(2,1,2);
fig1 = get(ax1,'children'); %get handle to all the children in the figure
fig2 = get(ax2,'children');
copyobj(fig1,s1); %copy children to new parent axes i.e. the subplot axes
copyobj(fig2,s2);

end

end
