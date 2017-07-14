function [ NAMES ] = analyseRivalryWrapper(  )
%Wrapper function for the Analyse Rivalry Function
%   Also appends the output variables to the rivalry MAT file

%Constant
StudyDir = 'C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\Participants';
%StudyDir = 'D:\Work\MATLAB\AllParticipants';

%Initial Setup (Semi-Constant)
NAMES = getNames(StudyDir);
if isempty(NAMES); return; end % If cancelled, exit gracefully
opI = oppositeInstructionCheck(NAMES); 
opI = ismember(NAMES,opI); % Create a logical index of where the reversed instruction pps are

for ppa = 1:length(NAMES)
    amPN{ppa} = [StudyDir '\' NAMES{ppa}];
end

[fnm, pnm] = getAddress(amPN,'_rivalry.mat');

for pp = 1:length(NAMES)
    
    diary(sprintf('%d.txt',pp))
  
    theThing(pnm{pp}, fnm{pp}, pp, opI(pp));
    
    % save figures to the MATLAB root, collect them from there
    %saveas(gcf,sprintf('%s.fig',fnm{pp}(1:end-4)))
    saveas(gcf,sprintf('%d.fig',pp))
    
    close gcf
    diary off
    
end

%% Sub-functions

    function [avg, tot, reversals, han] = theThing(pdir, fil, p, opI)
        disp([pdir fil])
        if opI; disp('Instructions Reversed.'); end % Were this pp's instructions reversed? If so, note in log
        a = load([pdir fil]);
        [avg, tot, reversals, han] = analyseRivalry(a.varsetup,a.data,a.expName,a.expDateSess,a.readID,'split',opI);
        save(sprintf('%d.mat',p),'avg', 'tot', 'reversals');
    end

    function opI = oppositeInstructionCheck(na)
        %         opI = input('Input 1 if opposite instructions');
        list = [na {'None'}];
        [s,~] = listdlg('PromptString','Reversed instructions:',...
            'SelectionMode','multiple',...
            'ListString',list,'InitialValue',length(list),'OKString','Select','CancelString','None');
        opI = list(s);
    end


%% Spare code
        % [avg, tot, reversals, han] =
        % analyseRivalry(varsetup,data,expName,expDateSess, readID, split); % The original function, copied from function definition
        % [avg, tot, reversals, han] = analyseRivalry(a.varsetup,a.data,a.expName,a.expDateSess,a.readID,[]);

end

