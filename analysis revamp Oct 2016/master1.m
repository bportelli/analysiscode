[imported, pn, readID, varsetup, expName, expDateSess ] = read_in_tables_removeold();

[fn, pn] = uigetfile(pn);

clearvars -EXCEPT pn fn

load([pn fn])

analyse710_auto(data, expName, expDateSess, pn)