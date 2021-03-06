%% Extracting the Widths, contrasts and Sizes
% Takes in the tata (incoming table) and outputs the table with new columns
%a={}; %Paste the Names here

function [tataO] = extractWCS(tata)

%% Hacky prevention to catch irregular variables going into table
% a=load('C:\Users\bjp4\Documents\MATLAB\Git\analysiscode\analysis_redone_Dec_2016\extractwcs_breakpoints.mat');
% dbstop(a.s)

%% Get list of ExpNames
%(Demo: C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\COMPLETED\BPpilot\BPpilot.xlsx )
%fp = 'C:\Users\bjp4\Desktop\TEST_BPPilot.xlsx';
%tata = readtable(fp);
A = tata.ExpName;
BAYESIANS = {'DL8ET - Lateral_w7_c92_spd02_fullfield_coher50';'DL8EU - Lateral_w7_c09_spd02_fullfield_coher50';'DL8EV - Lateral_w5_c92_spd02_fullfield_coher50';'DL8EW - Lateral_w5_c09_spd02_fullfield_coher50';'DL8EX - Lateral_w3_c92_spd02_fullfield_coher50';'DL8EY - Lateral_w3_c09_spd02_fullfield_coher50';'DL8EZ - Lateral_w1.5_c92_spd02_fullfield_coher50';'DL8F0 - Lateral_w1.5_c09_spd02_fullfield_coher50';'DL8F1 - full_w7_c92_spd02_fullfield_coher50';'DL8F2 - full_w7_c09_spd02_fullfield_coher50';'DL8F3 - full_w5_c92_spd02_fullfield_coher50';'DL8F4 - full_w5_c09_spd02_fullfield_coher50';'DL8F5 - full_w3_c92_spd02_fullfield_coher50';'DL8F6 - full_w3_c09_spd02_fullfield_coher50';'DL8F7 - full_w1.5_c92_spd02_fullfield_coher50';'DL8F8 - full_w1.5_c09_spd02_fullfield_coher50';'DL8FH - cd_w7_c92_spd0.3_fullfield_coher50';'DL8FI - cd_w7_c09_spd0.3_fullfield_coher50';'DL8FJ - cd_w5_c92_spd0.3_fullfield_coher50';'DL8FK - cd_w5_c09_spd0.3_fullfield_coher50';'DL8FL - cd_w3_c92_spd0.3_fullfield_coher50';'DL8FM - cd_w3_c09_spd0.3_fullfield_coher50';'DL8FN - cd_w1.5_c92_spd0.3_fullfield_coher50';'DL8FO - cd_w1.5_c09_spd0.3_fullfield_coher50';'DL8FP - iovd_w7_c92_spd02_fullfield_coher50';'DL8FQ - iovd_w7_c09_spd02_fullfield_coher50';'DL8FR - iovd_w5_c92_spd02_fullfield_coher50';'DL8FS - iovd_w5_c09_spd02_fullfield_coher50';'DL8FT - iovd_w3_c92_spd02_fullfield_coher50';'DL8FU - iovd_w3_c09_spd02_fullfield_coher50';'DL8FV - iovd_w1.5_c92_spd02_fullfield_coher50';'DL8FW - iovd_w1.5_c09_spd02_fullfield_coher50'};

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
%disparity index
dispIx = regexp(A,'disparity_w');
dispIx = ~[cellfun(@isempty,dispIx)];

MotionCues = {};
MotionCues(LatIx)= {'Lateral'};
MotionCues(fullIx)= {'Full'};
MotionCues(cdIx)= {'CD'};
MotionCues(iovdIx)= {'IOVD'};
MotionCues(dispIx)= {'StaticDisp'};

%% For Bayesians
BayIx = cellfun(@(x)(any(ismember(BAYESIANS,x))),A);

%% Other IV's (comment out the unwanted ones)
numpat = '\d(\.?\d)?0?'; %Keeping it separate in the function just in case it ever changes, but for now they're all the same (hence numpat variable)
va.Contrast = getNumerical('_c',numpat);
va.Width = getNumerical('_w',numpat);
va.Speed = getNumerical('_spd',numpat);
va.Coher = getNumerical('_coher',numpat);

va.Bayesian = BayIx*1; %Notice this one is different!

varNmes = ['MotionCue'; fieldnames(va)];
%{'MotionCues','Contrasts','Widths','Speeds'};

%% Produce the output (NB: MODIFY THE insT VARIABLE IF CHANGING VARS)
%insT = table(MotionCues',Contrasts,Widths,Speeds,'VariableNames',...
%varNmes); %table to insert

insC = [{MotionCues'} struct2cell(va)'];

% error-prevention - remove empty variables
if any(cellfun('isempty',insC))
    empties = find(cellfun('isempty',insC));
    insC(empties) = [];
    varNmes(empties) = [];
end

% temporary error correction for the irregular length of cell 3
for col = 1:length(insC)
while length(insC{1}) > length(insC{col})
    warning(sprintf('Zeroes inserted to fill in missing values in table col %d',col+3))
    insC{col}(end+1) = 0;
end
end

insT = table(insC{:},'VariableNames',...
    varNmes); %table to insert

tataO = [tata(:,1:3) insT tata(:,4:end)];


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