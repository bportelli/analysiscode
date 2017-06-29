function [ NAMES ] = analyseRivalryWrapper(  )
%Wrapper function for the Analyse Rivalry Function
%   Also appends the output variables to the rivalry MAT file

StudyDir = 'C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\Participants';
NAMES = getNames(StudyDir);

for ppa = 1:length(NAMES)
amPN{ppa} = [StudyDir '\' NAMES{ppa}];
end

[fnm, pnm] = getAddress(amPN,'_rivalry.mat');

for pp = 1:length(NAMES)
    
    diary(sprintf('%d.txt',pp))
    
    theThing(pnm{pp}, fnm{pp}, pp);
    
    % save figures to the MATLAB root, collect them from there
    %saveas(gcf,sprintf('%s.fig',fnm{pp}(1:end-4)))
    saveas(gcf,sprintf('%d.fig',pp)) 
    
    close gcf
    diary off
    
end

%% Sub-functions

    function [avg, tot, reversals, han] = theThing(pdir, fil, p)
        disp([pdir fil])
        a = load([pdir fil]);
        % [avg, tot, reversals, han] = analyseRivalry(varsetup,data,expName,expDateSess, readID);
        [avg, tot, reversals, han] = analyseRivalry(a.varsetup,a.data,a.expName,a.expDateSess,a.readID);
        save(sprintf('%d.mat',p),'avg', 'tot', 'reversals');
    end


end

