%% Extracting the Widths and contrasts
%
%a={}; %Paste the Names here

%% Get list of ExpNames
% fp = 'C:\Users\bjp4\Desktop\TEST_BPPilot.xlsx';
% tata = readtable(fp);
% namelist = tata.ExpName;

%% 

b = regexp(a,'_c\d\d','match');
b = [b{:}];

c = cellfun(@(x)x(3:4),b,'Uniformoutput',0);
c = c';

d = cell2mat(c);

open d