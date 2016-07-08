%settings(2) is settings for expt 2
settings(2).ivs = 3; %there are 3 ivs (mcue, size and cont)
settings(2).ivnames = {'MC','Wid','Con'}; %the independent variable names
settings(2).thv = 'Duration (ms)'; %the 'thresholded variable'
settings(2).psykvn = 'Stimulusduration'; %the 'thresholded variable' reference (Psykinematix variable name)
%ivtables(1) is mcue
settings(2).ivtables(1).keywds = {' MiD ',' L ','CD_','IOVD_','full_'}; 
settings(2).ivtables(1).list = {'MID','LAT','CD','IOVD','FULL'};
%ivtables(2) is width
settings(2).ivtables(2).keywds = {'w1.5','w3','w5'}; 
settings(2).ivtables(2).list = [1.5,3,5];
%ivtables(3) is contrast
settings(2).ivtables(3).keywds = {'c3','c92'}; 
settings(2).ivtables(3).list = [3,92];

%NB: the following settings for EXPT 2 match with the CODED names of the expt
%files... 
%ivtables(2) is size
% settings(2).ivtables(2).keywds = {'15','03','05'}; 
% settings(2).ivtables(2).list = [1.5,3,5];
% %ivtables(3) is cont
% settings(2).ivtables(3).keywds = {'03','92'}; 
% settings(2).ivtables(3).list = [3,92];


%settings(3) is settings for expt 3
settings(3).ivs = 2; %there are 2 ivs (mcue and spd)
settings(3).ivnames = {'MC','Spd'}; %the independent variable names
settings(3).thv = 'Motion Coherence'; %mv is the 'thresholded variable'
settings(3).psykvn = 'Stimuluscoher'; %the Psykinematix variable name
%ivtables(1) is mcue
settings(3).ivtables(1).keywds = {' MiD ',' L ','CD_','IOVD_','full_'}; 
settings(3).ivtables(1).list = {'MID','LAT','CD','IOVD','FULL'};
%ivtables(2) is spd
settings(3).ivtables(2).keywds = {'spd0.3','spd0.9','spd2'}; 
settings(3).ivtables(2).list = [0.3,0.9,2];


%settings(4) is settings for expt 4
settings(4).ivs = 3; %there are 2 ivs (mcue and spd)
settings(4).ivnames = {'MC','Wi','Co'}; %the independent variable names
settings(4).thv = 'Duration (ms)'; %mv is the 'thresholded variable'
settings(4).psykvn = 'Stimulusdur'; %the Psykinematix variable name
%ivtables(1) is mcue %% FIX THE REST
settings(4).ivtables(1).keywds = {' MiD ',' L ','CD_','IOVD_','full_'}; 
settings(4).ivtables(1).list = {'MID','LAT','CD','IOVD','FULL'};
%ivtables(2) is spd
settings(4).ivtables(2).keywds = {'spd0.3','spd0.9','spd2'}; 
settings(4).ivtables(2).list = [0.3,0.9,2];
