%%NB: LOOK AT NAMES IN ANALYSE SECTION BELOW

skip = false; %Put this in sections which I want to skip

if skip
    k = 1;
    m = 1;
    while m % Collect directories with files to use
        ampn{k} = uigetdir();
        k = k+1;
        m = input('Input 1 to get another directory...\n');
    end
    
    %Read tables in
    for k = 1:length(ampn)
        disp(ampn{k})
        read_in_tables_removeold();
        clearvars -EXCEPT k ampn
    end
    
    %read_in_tables_removeold();
    
    %[fn, pn] = uigetfile(pn);
    
    %clearvars -EXCEPT pn fn
    
    %load([pn fn])
end
%% Single runs
%Analyse and produce quick plots

% Add Palamedes to path
addpath(genpath('C:\Users\bjp4\Documents\MATLAB\Toolboxes'));

NAMES = {'BPPilot','IC2data','JG2data','JR2data','KS2data','RD2data','RJdata','VBdata','WL2data','YL2data'};

for k = 1:length(ampn)
[fn, pn] = uigetfile(ampn{k});
load([pn fn],'data', 'expName', 'expDateSess', 'readID', 'pn')
disp(ampn{k})
analyse710_auto(data, expName, expDateSess, readID, pn,NAMES{k}) % THIS ALSO DOES COLLECTING NOW
clearvars -EXCEPT k ampn NAMES
end

%% Demos
%Produce plots for the demo file results

whoHasDemos = [12,14,15]; %First, find out who has demos (numbered according to position in ampn)
for k = whoHasDemos;
disp(ampn{k})
demo_files(ampn{k})  
clearvars -EXCEPT k ampn
end

%% Combined
%Set up the combined data files
for k = 1:length(ampn)
[fn, pn] = uigetfile(ampn{k});
disp(ampn{k})
combisetup(pn, fn)
clearvars -EXCEPT k ampn
end

%For the Combined data files: Analyse and produce quick plots
for k = 1:length(ampn)
[fn, pn] = uigetfile(ampn{k});
load([pn fn],'datacomb', 'expName_comb', 'expDateSess_comb', 'readID', 'pn')
disp(ampn{k})
analyse710_auto(datacomb, expName_comb, expDateSess_comb, readID, pn)
clearvars -EXCEPT k ampn
end

%collect CURRRENTLY ADAPTED TO COMBI
collect(ampn(13:15))
