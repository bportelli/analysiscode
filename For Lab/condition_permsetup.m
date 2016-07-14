condi = 32; %number of conditions
reps = 4; %Number of repetitions to generate permutations for (TIP: make more than you need)
pps = 20; %Number of participants (TIP: make more than you think you'll need)

saveloc = uigetdir([],'Where do you want to save the sheet?');

hw = waitbar(0,'Running...');

rng('shuffle')

n = @num2str;

for pp = 1:pps

    for re = 1:reps
        T(re,:) = randperm(condi);
    end

    xlswrite([saveloc '\conditionperms.xlsx'],T,'Sheet1',['A' n(((pp-1)*(reps+1))+1)])
    
    waitbar(pp/pps)
    if pp/pps>0.5
        waitbar(pp/pps,hw,'Patience you must have...')
    end
    
end

    waitbar(1,hw,'Finished!')