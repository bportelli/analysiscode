%% Extracting the Widths, contrasts and Sizes
%
%a={}; %Paste the Names here

function [contrasts, ] = extractWCS()

%% Get list of ExpNames
fp = 'C:\Users\bjp4\Desktop\TEST_BPPilot.xlsx';
tata = readtable(fp);
a = tata.ExpName;

%% For contrasts
b = regexp(a,'_c\d\d','match');
b = [b{:}];

c = cellfun(@(x)x(3:4),b,'Uniformoutput',0);
c = c';

contrasts=[];
for k = 1:length(c)
    contrasts(k,1) = str2double(c{k,1}); % Contrast List Complete!
end

%% For motioncue

for k = 1:length(a) %This is terrible. Use regexp
    if sum(ismember(a{k,1},'cd')) >=2
        b{k,1} = 'cd';
    end
    if sum(ismember(a{k,1},'Lateral')) >=7
        b{k,1} = 'Lateral';
    end
    if sum(ismember(a{k,1},'full')) >=4
        b{k,1} = 'full';
    end
    if sum(ismember(a{k,1},'iovd')) >=4
        b{k,1} = 'iovd';
    end
end


b = regexp(a,'_c\d\d','match');
b = [b{:}];

c = cellfun(@(x)x(3:4),b,'Uniformoutput',0);
c = c';

contrasts=[];
for k = 1:length(c)
    contrasts(k,1) = str2double(c{k,1}); % Contrast List Complete!
end



end