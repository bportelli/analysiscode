function [thresholds] = staticDispthreshold(varargin)
% By default (no arguments), the function will work on the files listed in the "directories and files" section
% Otherwise, there are 2 options:
%1. The first argument is where the MAT files for
% Proportion Correct are/is stored, the second should be where Prop Test
% nearer is stored, and the optional third should be the names of the mat
% files (if not provided, all MAT files in Prop Correct dir will be used)
% OR
%2. The first argument is the contents of the Prop Corr mat file,as a struct, and the
%second is the contents of the Prop Test MAT file, as a struct
% The output is an array with 2 columns, where the first column is the pp numbers
% (taken from the matnames, so it might just be empty), and the second is the threshold

%% Constants
UPLIMIT = 12.5; % This defines the 'bounds' to work out which thresholds are "Out of Bounds"
LOWLIMIT = 0;

%directories and files setup
sctructIn = 0;
if nargin < 1
    propCorrd = 'C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\Making the Threshold getter\Proportion correct';
    propTestd = 'C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\Making the Threshold getter\Proportion Test';
    matnames = getMATfiles(propCorrd);
else
    if ~isstruct(varargin{1}) 
        propCorrd = varargin{1};
        propTestd = varargin{2};
        if length(varargin)>2
            matnames = varargin{3};
        else
            matnames = getMATfiles(propCorrd);
        end
    else % Get the variables straight from the structs, if they've been input directly
        propCorrd = '.'; propTestd = '.'; matnames = '.'; %they won't be used anyway, this is just to keep the functions running smoothly
        sctructIn = 1;
    end
end

%% from propCorrd

[OOBa, OOBt] = getOOB(propCorrd,matnames); % Out of Bounnds for Away and Towards

%% from propTestd
%This function will ignore any files that exist in propTestd folder, that don't in the other

thresholds = calcThresh(propTestd,matnames,OOBa);

%'Naming' the thresholds
if ~isequal(matnames,'.')
numlist = str2double(cellfun(@(x)x{1},regexp(matnames,'^\d(\d)?','match'),...
    'UniformOutput',false)); %converting the matnames to numbers
else
   numlist = nan(length(thresholds),1); 
end
thresholds= [numlist' ; thresholds(1,:)]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Sub functions
    function matnames = getMATfiles(dire)
        s = ':'; % return all by default
        d=dir(dire);
        str = {d.name};
        str = str(~(cellfun('isempty',regexp(str,'^\d(\d)?\.mat')))); % removes anything that isn't a mat file with a number name
        %         [s,~] = listdlg('PromptString','Select a txt file:',...
        %             'SelectionMode','multiple',...
        %             'ListString',str);
        matnames = str(s);
    end

    function  [OOBa, OOBt] = getOOB(dire,matnms)
        
        for mn = 1:length(matnms)
            
            [~, ~, t] = varLoad(dire,matnms(mn),'PC'); %  Proportion Correct
            t1 = t(1); t2 = t(2);
            
            OOBa(mn)= or(t1 < LOWLIMIT, t1 > UPLIMIT); %records "Out Of Bounds" thresholds (less than 0 or higher than 12.5) for away
            
            % for sanity/error check, make sure pp isnt OK with Away and bad at Tow
            OOBt(mn)= or(t2 < LOWLIMIT, t2 > UPLIMIT); %records "Out Of Bounds" thresholds (less than 0 or higher than 12.5) for Towards
            
            if and(OOBt(mn),~OOBa(mn))
                if length(matnms(1)) == 1
                    warning('Take a closer look at this participant')
                else
                    warning('Take a closer look at the participant %s',matnms{mn})
                end
            end
        end
    end


    function thresholds = calcThresh(dire,matn1,OOBa)
        matnms = matn1;
        
        for mn2 = 1:length(matnms)

            [a, values, ~] = varLoad(dire,matnms(mn2),'PT'); %Proportion Test
            
            if OOBa(mn2) % if away is out of bounds, get 75-50 threshold for towards
                disp('No threshold for Away - Collecting From Towards')
                paramsValues = a.varAndPFOut(find(values == 1)+1).PsychFunOut.paramsValues;
                PF = a.varAndPFOut(1).PF;
                t75 = PF(paramsValues,0.75,'Inverse'); t50 = PF(paramsValues,0.5,'Inverse');
                thresholds(mn2) = t75-t50;
            else % if away isn't out of bounds, get ((75-50) + (50-25))/2 threshold from Both
                paramsValues = a.varAndPFOut(1).PsychFunOut.paramsValues;
                PF = a.varAndPFOut(1).PF;
                t75 = PF(paramsValues,0.75,'Inverse'); t50 = PF(paramsValues,0.5,'Inverse'); t25 = PF(paramsValues,0.25,'Inverse');
                thresholds(mn2) = ((t75-t50)+(t50-t25))/2;
            end
            
        end
        
    end


    function [a, values, t] = varLoad(dire,mnms,pcpt)
        if ~sctructIn
            if iscell(mnms); mnms = mnms{1}; end
            a = load([dire '\' mnms]);
            
            values = a.varAndPFOut(1).values;
            values = str2num(cell2mat(values));
            
            t(1) = a.thresholds(find(values == 0)+1); %threshold for Away
            t(2) = a.thresholds(find(values == 1)+1); %threshold for Towards
        else
            if isequal(pcpt,'PC')
                a = varargin{1};
            else % if Proportion Test
                a = varargin{2};
            end
            values = a.varAndPFOut(1).values;
            values = str2num(cell2mat(values));
            
            t(1) = a.thresholds(find(values == 0)+1); %threshold for Away
            t(2) = a.thresholds(find(values == 1)+1); %threshold for Towards
        end
    end

end


