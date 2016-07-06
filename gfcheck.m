function [fn] = gfcheck(fn,setting)
% Checks for unusual scenarios with the use of uigetfile
% (getfilecheck)
% Specifying a setting of 'cell' (as a string), converts a single file ref
% (output by matlab as a char) into a cell. Multi-file refs are already
% cells.

if ischar(fn)
    if strcmp(setting,'cell')
        fn = {fn};
    end
else if iscell(fn)
        if strcmp(setting,'char')
            warning('You have multiple files selected, and are trying to treat them as one. Mistake here?')
            pause
        end     
        return
    else if fn == 0
            warning('No file selected. Press Ctrl + C to terminate.')
            pause
            return
        end
    end
end

end