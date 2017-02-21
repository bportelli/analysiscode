%% Extracting the Widths, contrasts and Sizes
% Takes in the tata (incoming table) and outputs the table with new columns
%a={}; %Paste the Names here

function [tataO] = extractWCS(tata)

%% Get list of ExpNames
%(Demo: C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\COMPLETED\BPpilot\BPpilot.xlsx )
%fp = 'C:\Users\bjp4\Desktop\TEST_BPPilot.xlsx';
%tata = readtable(fp);
A = tata.ExpName;

%% For motioncue
%Lateral index
LatIx = regexp(A,'Lateral_w');
LatIx = ~[cellfun(@isempty,LatIx)];
%full index
fullIx = regexp(A,'full_w');
fullIx = ~[cellfun(@isempty,fullIx)];
%cd index
cdIx = regexp(A,'cd_w');
cdIx = ~[cellfun(@isempty,cdIx)];
%iovd index
iovdIx = regexp(A,'iovd_w');
iovdIx = ~[cellfun(@isempty,iovdIx)];

MotionCues = {};
MotionCues(LatIx)= {'Lateral'};
MotionCues(fullIx)= {'Full'};
MotionCues(cdIx)= {'CD'};
MotionCues(iovdIx)= {'IOVD'};

%% Other IV's (comment out the unwanted ones)
numpat = '\d(\.?\d)?'; %Keeping it separate in the function just in case it ever changes, but for now they're all the same (hence numpat variable)
va.Contrast = getNumerical('_c',numpat);
va.Width = getNumerical('_w',numpat);
va.Speed = getNumerical('_spd',numpat);

varNmes = ['MotionCue'; fieldnames(va)];
%{'MotionCues','Contrasts','Widths','Speeds'};

%% Produce the output (NB: MODIFY THE insT VARIABLE IF CHANGING VARS)
%insT = table(MotionCues',Contrasts,Widths,Speeds,'VariableNames',...
%varNmes); %table to insert

insC = [{MotionCues'} struct2cell(va)'];
insT = table(insC{:},'VariableNames',...
    varNmes); %table to insert

tataO = [tata(:,1:3) insT tata(:,4:6)];


%% Sub-functions

    function cond = getNumerical(pattern1,pattern2)
        % Takes in pattern1, the identifying word, and pattern 2, the
        % number identifier
        
        %% For widths
        bv = regexp(A,[pattern1 pattern2],'match');
        bv(~cellfun(@isempty, bv)) = [bv{:}];
        %bv(~cellfun(@isempty, bv)) = bv{~cellfun(@isempty, bv)};
        %bv = [bv{:}];
        
        st= length(pattern1)+1;%work out where the actual number starts
        
        c1 = cellfun(@(x)x(st:end),bv,'Uniformoutput',0);
        %c1 = c1';
        
        condi=[];
        for k = 1:length(c1)
            if isempty(c1{k,1})
                continue
            else
                condi(k,1) = str2double(c1{k,1}); %List Complete!
            end
        end
        
        cond = condi;
        
    end

end

%% Old Code

% %% For widths
% b1 = regexp(A,'_w\d(\.\d)?','match');
% b1(~cellfun(@isempty, b1)) = b1{~cellfun(@isempty, b1)};
% %b1 = [b1{:}];
%
% c1 = cellfun(@(x)x(3:end),b1,'Uniformoutput',0);
% %c1 = c1';
%
% Widths=[];
% for k = 1:length(c1)
%     if isempty(c1{k,1})
%         continue
%     else
%         Widths(k,1) = str2double(c1{k,1}); % Widths List Complete!
%     end
% end
%
% %% For contrasts
% b = regexp(a,'_c\d\d','match');
% b(~cellfun(@isempty, b)) = b{~cellfun(@isempty, b)};
% %b = [b{:}];
%
% c = cellfun(@(x)x(3:end),b,'Uniformoutput',0);
% %c = c';
%
% Contrasts=[];
% for k = 1:length(c)
%     if isempty(c{k,1})
%        continue
%     else
%     Contrasts(k,1) = str2double(c{k,1}); % Contrast List Complete!
%     end
% end

% co = table(contrasts,'VariableNames',{'Contrasts'});
% tata2 = [tata(:,[1,2]), co, tata(:,3:end)];