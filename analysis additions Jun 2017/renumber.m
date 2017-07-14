function [] =  renumber(varargin)
% Takes an input to restrict listed numbers only to input

d = '.'; % root by default
foldername = 'Renumbered';

[selected] = getTheList(d,varargin);
if isempty(selected); return; end % return function if cancelled or no files available to renumber
disp(selected)

if nargin > 1; changeto = inputNew(varargin{2});
else           changeto = inputNew();
end

mkdir(foldername);
for n = 1:length(selected)
    movefile(selected{n},[foldername '\' num2str(changeto) selected{n}(end-3:end)])
end

carryOn = 1;%input('Input 1 to renumber more files...');
if carryOn
    renumber();
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [selected, q] = getTheList(d,a)
        if ~isempty(a)
            a = num2str(a{1}); % use this to limit the window display further
            pattern = ['^' a '\.(fig|mat|txt|png)'];
        else
            pattern = '^\d(\d)?\.(fig|mat|txt|png)';
        end
        %Selection listbox
        d=dir(d);
        str = {d.name};
        str = str(~cellfun('isempty',regexp(str,pattern))); % displays files with digits in name
        if isempty(str); disp('No (more) files eligible for renumbering'); selected = []; return; end
        [s,~] = listdlg('PromptString','Select files to renumber:',...
            'SelectionMode','multiple',...
            'ListString',str);
        selected = str(s);
    end

    function changeto = inputNew(varargin)
        if nargin>=1
            b = {num2str(varargin{1})};
            %            b = {cellfun(@(x)(num2str(x)),varargin,'UniformOutput',false)};
        else
            b = {'Type a number'};
        end
        
        ch = inputdlg({'Change to which number:'},'New Number',1,b);
        ch = str2num(ch{1});
        if and(isnumeric(ch),~isempty(ch))
            changeto = ch;
        else
            disp('Input must be numeric')
            changeto = inputNew();
            return
        end
    end



end