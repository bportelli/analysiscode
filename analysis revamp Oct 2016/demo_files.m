% ct = fieldnames(data);
% 
% scores = nan(1,length(ct));
% 
% for k = 1:length(ct)
%    scores(k) = data.(ct{k}).Scoring(end); 
% end
% 
% 
% x = [7,3,1.6];
% 
% odds92 = [1,3,5];
% evens09 = [2,4,6];
% 
% y{1} = scores(1,3,5);
% Tit{1} = ['JR Lateral c92'];
% 
% y{2} = scores(2,4,6);
% Tit{2} = ['JR Lateral c09'];
% 
% y{3} = scores(7,9,11);
% Tit{3} = ['JR Full c92'];
% 
% y{4} = scores(8,10,12);
% Tit{4} = ['JR Full c09'];
% 
% y{5} = scores(13,15,17);
% Tit{5} = ['JR Full c92'];
% 
% y{6} = scores(14,16,18);
% Tit{6} = ['JR Full c09'];
% 
% y{7} = scores(19,21,23);
% Tit{7} = ['JR Full c92'];
% 
% y{8} = scores(20,22,24);
% Tit{8} = ['JR Full c09'];
% 
% 
% odds92 = [1,3,5];
% evens09 = [2,4,6];
% 
% bar(x,scores(odds92))
% xlabel('Widths')
% ylabel('Percent Correct')
% title(['JR Lateral c92'],'interpreter','none')
% 
% %title(Tit{},'interpreter','none')
% 
% saveas(gcf,[pn 'Plots\Full92_E3F4D_1.fig'])
% 


%%

%To find demo files
%demoIX = find(cellfun(@(x)~isempty(x),(regexp(expName,'demo'))));

demoIX = cellfun(@(x)~isempty(x),(regexp(expName,'demo')));

pname = input('ENTER NAME FOR PLOT\n','s');

% for k = 1:15
% [fn, pn] = uigetfile();
% load([pn fn],'expName')
% demoIX{k} = any(cellfun(@(x)~isempty(x),(regexp(expName,'demo'))));
% clear expName
% end

%To find the ones pertaining to THIS experiment
% da = cellfun(@(x)(datenum(x(5:12),'dd/mm/yy'))>=datenum('10/06/2016','dd/mm/yy'),expDateSess_all);
%736491

logID = sprintf('%0.0f',clock);

diary([pn logID '_makebars_log.txt'])

ct = fieldnames(data);
ct = ct(demoIX);%limit to demo files only
expName = expName(demoIX);
expDateSess = expDateSess(demoIX);

scores = nan(1,length(ct));

for k = 1:length(ct)
   scores(k) = data.(ct{k}).Scoring(end); 
end

x = [7,3,1.6];

odds92 = [1,3,5];
evens09 = [2,4,6];

messages = {'ODD NUMBERS C92', 'EVEN NUMBERS C09'};
msgTitle = {'c92', 'c09'};

for l = 1:2
    
    triplet = [1,3,5] + (l-1);
    
    fprintf('Now doing %s\n',messages{l})
    
    while max(triplet)<=length(scores)
        
        disp(['datafiles:' num2str(triplet)])
        
        axis([0 8 0 100])
        hold on
        b=bar(x,scores(triplet));
        
        xlabel('Stimulus Width')
        ylabel('Percent Correct')
        
        %makeTitle = input('Write Title as NAME - MCUE - CONT\n','s');
        
        title([expName{min(triplet)} pname ' ' msgTitle{l} ' ' expDateSess{min(triplet)}],'interpreter','none')
        
        %pause
        
        saveas(gcf,[pn 'Plots\' logID ct{min(triplet)}(1:end-1) '_' msgTitle{l} '.fig'])
        delete(b)
        
        triplet = plus(triplet,6); %increment
        
    end
    
end
close all
diary off