function [out] = gatherFile(datastore,tablename,STUDYDIR)
%% Gather a specific datafile from selected participant
% [out] = gatherFile('datacomb','Exp000BJ',[])    %Use this to gather (combined) static disparity files from Study 6 Analysis\Participants

% datastore is a char with the name of the struct holding the needed file (usu. data or datcomb)
% out is a cell containing the gathered item (usu. tables)

% tablename is the name of the table to be collected (from datastore, from
% each pp). Exp000BJ is the tablename for the disparity condition

if isempty(STUDYDIR)
STUDYDIR = 'C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\Participants';
end
NAMES = getNames(STUDYDIR);

for k = 1:length(NAMES)
it = collectOne(STUDYDIR,NAMES{k});
out{k} = it;
clear it
end


%% sub-function

    function NAMES = getNames(S)
        d=dir(S);
        str = {d.name};
        str = str(cellfun('isempty',regexp(str,'\.'))); % removes anything that isn't a folder (things that aren't folders have a dot)
        [s,~] = listdlg('PromptString','Select a participant:',...
            'SelectionMode','multiple',...
            'ListString',str);
        NAMES = str(s);
    end

    function it = collectOne(S,name)
        %S is directory where pp's are stored, name is the name of the current pp
        fn = uigetfile([S '\' name]);
        inc = load([S '\' name '\' fn],datastore);
        it = inc.(datastore).(tablename);
    end

end