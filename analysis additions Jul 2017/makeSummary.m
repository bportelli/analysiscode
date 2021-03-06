function [NsToCopy, shtNames] = makeSummary(  )
%Make the SUMMARY Excel Sheet
%   Copy sheets and make the tables. Output NsToCopy which, in the end, is
%   actually the copied pp's

%% Constants
STUDYDIR = 'C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\Participants';
XLNAMES = {'SUMMARY.xlsx', 'SUMMARY_Combined.xlsx'};
SR2 = {'_SingleRuns',[]};

%% Initial Setup
Names = getNames(STUDYDIR);

for SinCom = 1:2 %Single Runs or Combined
    clear shtNames toCopy NsToCopy
    
    sr = SR2{SinCom}; if ~isempty(sr); disp(sr(2:end)); else disp('Combined Runs'); end
    theName = XLNAMES{SinCom};
    thePath = [STUDYDIR '\' theName]; %the full path to the Summary file
    
% Make sure a SUMMARY file exists to use (or create one)
newfile = 0;
if ~exist(thePath, 'file') % If it doesn't exist, create it, with a single digit in Sheet 1
    warning('SUMMARY file not found. Creating a new one.')
    pause(1)
    xlswrite(thePath,[1]);
    newfile = 1;
end

% Get the names of the worksheets in it (to skip copying of existing ones)
shtNames = listSheets(thePath,theName);
toCopy = ~ismember(Names,shtNames); %index (of NAMES) of participants that DO need copying over
NsToCopy = Names(toCopy); %These pps need copying over

%% The Process

% Setup individual pages? Or only do this on summary? (LATTER)

% Copy the identified pps

for pp = 1:length(NsToCopy)
    clear sht1
    disp(NsToCopy{pp})
    %Read the pp excel sheet
    ppXLdir = [STUDYDIR '\' NsToCopy{pp} '\' NsToCopy{pp} sr '.xlsx']; % Single or Combi just gets inserted in sr
    [nu, tx, sht1] = xlsread(ppXLdir,'Sheet1');
   
    % Paste the wsheet over in Summary
    xlswrite(thePath,sht1,NsToCopy{pp})
    
end

%...then setup each individual page in Summary?

if newfile
    % delete Sheet 1 from the Summary, if newly created
    [Excel, ExcelWorkbook] = openXLbgr(thePath);
    hsheet=Excel.Sheets.Item('Sheet1');
    hsheet.Delete
    % Close the Summary Sheet when finished
    Excel.WorkBooks.Item(theName).Close;
end

end % end of single/combi loop

%% Sub-functions

    function [Excel, ExcelWorkbook] = openXLbgr(wbdir) % Open Excel in the background, return handles
        Excel = actxserver('Excel.Application');
        set(Excel, 'Visible', 0);
        ExcelWorkbook = Excel.workbooks.Open(wbdir);
    end

    function shtNames = listSheets(wbdir,wbname)
        [Excel, ExcelWorkbook] = openXLbgr(wbdir);
        %WorkSheets = Excel.sheets
        %aa=WorkSheets.Item('Sheet1')
        
        for i=1 : Excel.Sheets.Count
            shtNames{i} = Excel.Sheets.Item(i).Name;
        end
        
        % Close the Summary Sheet when finished listing
        Excel.WorkBooks.Item(wbname).Close;
    end

end

