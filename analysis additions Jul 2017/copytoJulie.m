% This is just a code scrapbook/collection. Not for running all at once.

%%%%%%%%%%%%%%%%%%%%%%%%%

%Reminder: this requires NAMES
for mm = 1:20
copyfile([pn{mm} '\fixed'],...
    ['C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\For Julie\MiD Psychometric functions and log files\Separated\' NAMES{mm}])
end

for mm = 21:40
copyfile([pn{mm} '\fixed'],...
    ['C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\For Julie\MiD Psychometric functions and log files\Combined\' NAMES{mm-20}])
end


%%%%%%%%%%%%%%%%%%%%%%%%%

dd = 'C:\Users\bjp4\Documents\MATLAB\Study 6 Analysis\For Julie\MiD Psychometric functions and log files\Combined';
a = dir(dd);
na = {a.name};
na = na(3:end);

for k = 1:length(na)
   pnn{k} = [dd '\' na{k}];   
end


for ka = 1:length(pnn)
    cont = dir(pnn{ka});
    cont = {cont.name};
    cont = cont(3:end);
    for fi = 1:length(cont)
        copyfile([pnn{ka} '\' cont{fi}],[dd '\' na{ka} cont{fi}])
    end
end