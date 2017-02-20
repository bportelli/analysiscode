%% Extracting the Widths, contrasts and Sizes
%
%a={}; %Paste the Names here

%function [contrasts, ] = extractWCS()

%% Get list of ExpNames
fp = 'C:\Users\bjp4\Desktop\TEST_BPPilot.xlsx';
tata = readtable(fp);
a = tata.ExpName;

%% For contrasts
b = regexp(a,'_c\d\d','match');

%baa(ix)= b{ix}(:,:); %Trying to fix the handling of empty cells!


b = [b{:}];

c = cellfun(@(x)x(3:end),b,'Uniformoutput',0);
c = c';

Contrasts=[];
for k = 1:length(c)
    Contrasts(k,1) = str2double(c{k,1}); % Contrast List Complete!
end

% co = table(contrasts,'VariableNames',{'Contrasts'});
% tata2 = [tata(:,[1,2]), co, tata(:,3:end)];

%% For motioncue

%Lateral index
LatIx = regexp(a,'Lateral_w');
LatIx = ~[cellfun(@isempty,LatIx)];
%full index
fullIx = regexp(a,'full_w');
fullIx = ~[cellfun(@isempty,fullIx)];
%cd index
cdIx = regexp(a,'cd_w');
cdIx = ~[cellfun(@isempty,cdIx)];
%iovd index
iovdIx = regexp(a,'iovd_w');
iovdIx = ~[cellfun(@isempty,iovdIx)];

MotionCues = {};
MotionCues(LatIx)= {'Lateral'};
MotionCues(fullIx)= {'Full'};
MotionCues(cdIx)= {'CD'};
MotionCues(iovdIx)= {'IOVD'};

%% For widths
b1 = regexp(a,'_w\d(\.\d)?','match');
b1 = [b1{:}];

c1 = cellfun(@(x)x(3:end),b1,'Uniformoutput',0);
c1 = c1';

Widths=[];
for k = 1:length(c1)
    Widths(k,1) = str2double(c1{k,1}); % Contrast List Complete!
end

%end