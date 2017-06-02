function [mi  ] = rivalryTable( )
%Makes a table out of the rivalry data (Multiple Inputs)
% currently not yet smart... it's not yet clear from the output what the pp
% was seeing, nor which eye they were looking through; that is to be added!

% Constants
DELIM = '\t';

% Setup values


%% For now, just get input from paste, maybe expand to use import?
disp('Copy Psykinematix Log file, then Press Enter to Continue');
pause
txt = clipboard('paste'); % pastes the clipboard into a char array


%% Extract the Multiple Inputs List (of participant actions)
mi_start = regexp(txt,'multipleInputs: ('); %Get places where multipleInputs: begins
for k = 1:length(mi_start)
mi_end_holder = regexp(txt(mi_start(k):end),'\)'); %look for the next close bracket(s)
mi_end(k) = mi_end_holder(1)+mi_start(k); % we only need the next ONE. The addition is to get its reference in the larger txt variable.    
end

mi = {};
for o = 1:k
mi(o) = {txt(mi_start(o):mi_end(o))};
end


%% Extract the numbers and button presses for the plot
for n = 1:k
times{n} = regexp(mi{n},'Time = \d+(\.)?\d*','match');
times{n} = cellfun(@str2num,cellfun(@(x)x(8:end),times{n},'UniformOutput',false)); %conversion to numbers from string is done here too
end

for n = 1:k
    buttons{n} = regexp(mi{n},'Input = "?\w+\s?\w*','match');
    buttons{n} = cellfun(@(x)x(9:end),buttons{n},'UniformOutput',false);
end

for outer = 1:k
for ii = 1:length(buttons{outer})
    buttons{outer}{ii}(ismember(buttons{outer}{ii},'",.:;!()%#_')) = []; %spaces are OK here, but quote marks are removed
end
end

%Sanity Check (make sure there are three options)
if ~(length(unique(buttons{1})) <= 3)
   warning('More than three inputs detected. Something may be wrong.')
   pause
end

% Conver Left Shift, Right Shift and None to numbers
for m = 1:k
buttonsAsNums{m}(ismember(buttons{m},'None')) = 0;
buttonsAsNums{m}(ismember(buttons{m},'Left Shift')) = -1;
buttonsAsNums{m}(ismember(buttons{m},'Right Shift')) = 1;
end

%% Make the Plot
figure(1)
axes
hold on
for p = 1:k
ha(p) = plot(times{p},buttonsAsNums{p});
end
legend(ha,{'Session1','Session2'},'Location','Best');

%% Sub-functions

end