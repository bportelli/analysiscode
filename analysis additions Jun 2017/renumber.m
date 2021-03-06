function [] =  renumber(varargin)
% Takes an input to restrict listed numbers only to input

%Setup up for renumber (if there are a lot of files)
%listOrder is a cell containing a list of the pp IDs of files to be renumbered, in the order in which they were processed (and are currently numbered)
%ppnlist is a cell with a list of the participant IDs, alongside their numbers
%    listOrder{ka,2} = find(cellfun(@(x)~(isempty(x)),strfind(ppnlist(:,2),listOrder{ka,1})));

d = '.'; % check root by default
foldername = 'Renumbered';

[selected] = getTheList(d,varargin);
if isempty(selected); return; end % return function if cancelled or no files available to renumber
disp(selected)

if nargin > 1; changeto = inputNew(varargin{2});
else           changeto = inputNew();
end

if ~exist(foldername,'dir')
mkdir(foldername); end
for n = 1:length(selected)
    movefile(selected{n},[foldername '\' num2str(changeto) selected{n}(end-3:end)])
end

carryOn = 1;%input('Input 1 to renumber more files...');
if carryOn
    renumber('autocancel');
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [selected] = getTheList(d,a)
        if ~isempty(varargin) && isequal(varargin{1},'autocancel')
            selected = [];
            return
        end
        
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
            if isempty(str); disp('No (more) files eligible for renumbering'); selected = []; return; end
            [s,~] = listdlg('PromptString','Select files to renumber:',...
                'SelectionMode','multiple',...
                'ListString',str);
            selected = str(s);
            else selected = str;
            end
        end
    end

    function changeto = inputNew(varargin)
        if nargin>=1   
            % b = {num2str(varargin{1})}; % USE THIS IF YOU WANT CONFIRMATION OF THE NUMBER CHANGE BEFORE IT HAPPENS
            %            b = {cellfun(@(x)(num2str(x)),varargin,'UniformOutput',false)   % Not needed?
            changeto = varargin{1};
            return
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