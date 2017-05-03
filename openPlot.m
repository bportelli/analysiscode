function [ fig_handle ] = openPlot( )
%Opens the fig file relating to a particular run

StudyDir = 'C:\Users\bjp4\Documents\MATLAB\Study 5 Analysis\COMPLETED';

message = 'Get the table of thresholds, etc. for a participant';
disp(message)

NAME = whichParticipant();

% lo = load([StudyDir '\' NAME '\' 'Incoming' '\' 'collectedTable.mat']);
lo = load([StudyDir '\' NAME '\' 'Combined' '\' 'collectedTable.mat']);
Tcoll = lo.Tcoll;

row = whichFile(Tcoll); %get the row of the results table for the desired plot

anaID = Tcoll.AnaID{row}; %get its name

%Open the figure file!
fig_handle = openfig([StudyDir '\' NAME '\' 'Combined' '\' anaID '.fig']);



%% Sub-functions

    function [NAME] = whichParticipant()
        d=dir(StudyDir);
        str = {d.name};
        
        %for aesthetics, locate and remove fullstop options
        fstpIx = cellfun(@(x)all(x == '.'),str);
        str = str(~fstpIx);
        
        %list and offer selection
        [s,~] = listdlg('PromptString','Select a participant:',...
            'SelectionMode','single',...
            'ListString',str);
        
        NAME = str{s};
        
    end

    function [row] = whichFile(T)
        msg = 'SELECT THE ROW OF THE FIGURE TO OPEN, THEN RETURN TO COMMAND  WINDOW AND PRESS ENTER';
        f = figure('Name',msg);
        %mtable = uitable(gcf, 'Data', table2cell(T), 'unit', 'normalized','Position',[0 0 1 1], 'ColumnName',T.Properties.VariableNames);
        mtable = uitable(gcf, table2cell(T), T.Properties.VariableNames);
        jtable = mtable.getTable;
        
        %make table more accessible (visible)
        pos = get(f,'Position');
        set(mtable,'Position',[0 0 pos(3:4)])
        
        %Prompt for selection and wait for response
        disp(msg)
        pause
               
        row = jtable.getSelectedRow + 1; % Java indexes start at 0
                
        ok = input(['Row ',num2str(row),' selected. Is this correct? 1/0']);
        ok = (isempty(ok) || ok==1); %just hitting enter will work too
        close(gcf)
        
        if ~ok
            [row] = whichFile(T);
            return
        end
        
    end


end

