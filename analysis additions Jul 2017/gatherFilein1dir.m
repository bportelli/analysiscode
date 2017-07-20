function [out, selected] = gatherFilein1dir(datastore,STUDYDIR)
%% Gather a specific datafile from selected participant
% [out] = gatherFile('datacomb','Exp000BJ',[])    %Use this to gather (combined) static disparity files from Study 6 Analysis\Participants

% datastore is a char with the name of the struct holding the needed file (usu. data or datcomb)
% out is a cell containing the gathered item (usu. tables)

% tablename is the name of the table to be collected (from datastore, from
% each pp). Exp000BJ is the tablename for the disparity condition

if isempty(STUDYDIR)
STUDYDIR = 'C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\Participants';
end
[selected] = getTheList(STUDYDIR,[]);

for k = 1:length(selected)
it = collectOne(STUDYDIR,selected{k});
out{k} = it;
clear it
end


%% sub-function

function [selected] = getTheList(d,a)       
        if ~isempty(a)
            a = num2str(a{1}); % use this to limit the window display further
            pattern = ['^' a '\.(fig|mat|txt|png)'];
            [selected] = listbx(0); % Takes all matches without displaying listbox
            return;
        else
            pattern = '^\d(\d)?\.(fig|mat|txt|png)';
        end
        
        [selected] = listbx(1);
        
        %%%%%% Sub %%%%%%
        function [selected] = listbx(in)
            %Selection listbox
            d=dir(d);
            str = {d.name};
            str = str(~cellfun('isempty',regexp(str,pattern))); % displays files with digits in name
            if in
            if isempty(str); warning('No files available'); selected = []; return; end
            [s,~] = listdlg('PromptString','Select files to gather from:',...
                'SelectionMode','multiple',...
                'ListString',str);
            selected = str(s);
            else selected = str;
            end
        end
    end

    function it = collectOne(S,name)
        %S is directory where pp's are stored, name is the name of the current pp
        inc = load([S '\' name],datastore);
        it = inc.(datastore);
    end

end