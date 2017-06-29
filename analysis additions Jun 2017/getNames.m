    function NAMES = getNames(StudyDir)
    %Participants to Run Selection listbox
        d=dir(StudyDir);
        str = {d.name};
        str = str(cellfun('isempty',regexp(str,'\.'))); % removes anything that isn't a folder (things that aren't folders have a dot)
        [s,~] = listdlg('PromptString','Select a participant:',...
            'SelectionMode','multiple',...
            'ListString',str);
        NAMES = str(s);
    end