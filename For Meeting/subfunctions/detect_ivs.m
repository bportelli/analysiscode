    function [indvars] = detect_ivs(line)
        mark = @(x)~isempty(strfind(line,x)); %Outputs 1 when the keyword exists in the line, 0 when it doesn't
        
        for iva = 1:setting.ivs
            % loop through iv settings to identify which iv level this expt has for
            % each iv
            % do the search-and-mark stuff below, repeated each time for each IV,
            % using the relevant ivtable from ivtables
            
            ivtable = setting.ivtables(iva); %current ivtable
            
            chk = itemIndex(); %returns a logical array corresponding to the position of the found item
            
            if sum(chk)>1
               fprintf('There appear to be %d levels of IV# %d in file # %d\n',sum(chk),num2str(iva),num2str(a))
               disp('You should probably write some code to handle this...')
               pause % WRITE SOME CODE TO DO SOMETHING ABOUT THIS
            end
            
            
            try
                indvars(iva).levels(a) = ivtable.list(chk); %The corresponding iv level (from list) to the found keywd is noted
            catch
                disp(['CANNAE FIND IV #',num2str(iva),' FOR FILE #',num2str(a)])
                if sum(chk) == 0 %None of the available options is detected
                    indvars(iva).levels(a) = 'UNK';
                else %More than one option detected?
                    %error('There was an error with the independent variable detection.')
                    indvars(iva).levels(a) = 'UNK2';
                end
            end
        end
        
        function chk = itemIndex()
            for k=1:length(ivtable.keywds)
                chk(k) = mark(ivtable.keywds{k}); %chk is a logical array, where the 1 appears in the ref corresponding to the level of iv, as listed in keywds
            end
        end
        
    end