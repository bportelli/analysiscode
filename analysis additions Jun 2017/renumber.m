function [] =  renumber(varargin)
d = '.'; % root by default
foldername = 'Renumbered';

selected = getTheList(d,varargin);
if isempty(selected); return; end % return function if cancelled
disp(selected)
changeto = inputNew();

mkdir(foldername);
for n = 1:length(selected)
    movefile(selected{n},[foldername '\' num2str(changeto) selected{n}(end-3:end)])
end

carryOn = input('Input 1 to renumber more files...');
if carryOn
    renumber();
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function selected = getTheList(d,a)
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
        [s,~] = listdlg('PromptString','Select files to renumber:',...
            'SelectionMode','multiple',...
            'ListString',str);
        selected = str(s);
    end

    function changeto = inputNew()
        ch = inputdlg({'Change to which number:'});
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