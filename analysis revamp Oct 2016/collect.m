%% COLLECT RESULTS INTO ONE TABLE FOR 1 EXPT AND PP

function [k] = collect(ampn)

matID = [sprintf('%0.0f',clock) '_allTogether'];

% k = 1;
% m = 1;
% while m % Collect directories with files to combine
% ampn{k} = uigetdir();
% k = k+1;
% m = input('Input 1 to get another directory...\n');
% end

% load('C:\Users\bjp4\Documents\MATLAB\Study 4 Analysis\Pilots organised (for meeting)\allmats.mat','ampn')


for k = 1:length(ampn)
    disp(['Starting ' ampn{k}])
    collectionProcess()
    disp('Done.')
end


    function collectionProcess()
%         savedir = [ampn{k} 'COLLECTED\'];
        savedir = [ampn{k} 'COLLECTED\Combi'];
        mkdir(savedir) % Create the folder to receive the converted files
        
%         incDir = [ampn{k} 'Incoming\'];
        incDir = [ampn{k} 'Combined\'];
        
        List = ls(incDir); % List all files in the Incoming folder
        inputFormat = 'mat';
        
        % Set up EMPTY TABLE
        Tcoll = [];
        
        for ii = 3:size(List,1)
            
            currFile = strtrim(List(ii,:)); %remove leading or trailing whitespace
            
            if strfind(currFile,['.',inputFormat]) > 0 %If it's a MAT file...
                disp(['Collecting ',currFile])
                load([incDir currFile],'T1')
                Tcoll = [Tcoll; T1]; %Add table to collection
            end
            
        end
        
        % sort table by ExpName
        Tcoll = sortrows(Tcoll,2);
        
        save([savedir '\' matID],'Tcoll') %save MAT
        writetable(Tcoll,[savedir '\' matID,'.csv'])
        writetable(Tcoll,[savedir '\' matID,'.xls'])
        
        disp('Collection complete')
        
    end
end