%% Delete older files

da = cellfun(@(x)(datenum(x(5:12),'dd/mm/yy'))>=datenum('10/06/2016','dd/mm/yy'),expDateSess_all);



