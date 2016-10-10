ct = fieldnames(data);

scores = nan(1,length(ct));

for k = 1:length(ct)
   scores(k) = data.(ct{k}).Scoring(end); 
end


x = [7,3,1.6];

odds92 = [1,3,5];
evens09 = [2,4,6];

y{1} = scores(1,3,5);
Tit{1} = ['JR Lateral c92'];

y{2} = scores(2,4,6);
Tit{2} = ['JR Lateral c09'];

y{3} = scores(7,9,11);
Tit{3} = ['JR Full c92'];

y{4} = scores(8,10,12);
Tit{4} = ['JR Full c09'];

y{5} = scores(13,15,17);
Tit{5} = ['JR Full c92'];

y{6} = scores(14,16,18);
Tit{6} = ['JR Full c09'];

y{7} = scores(19,21,23);
Tit{7} = ['JR Full c92'];

y{8} = scores(20,22,24);
Tit{8} = ['JR Full c09'];


odds92 = [1,3,5];
evens09 = [2,4,6];

bar(x,scores(odds92))
xlabel('Widths')
ylabel('Percent Correct')
title(['JR Lateral c92'],'interpreter','none')

%title(Tit{},'interpreter','none')

saveas(gcf,[pn 'Plots\Full92_E3F4D_1.fig'])