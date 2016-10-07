        function [hmt, tStart] = howManyTables(blockFID)
            hmt = 0;
            while ~feof(blockFID) %~feof means 'not end of file'
                line = fgetl(blockFID);
                [token, remain] = strtok(line);
                if isequal(token, 'New')
                    [token, remain] = strtok(remain);
                    if isequal(token, 'Discrimination')
                        hmt = plus(hmt,1); %increment hmt
                        tStart(hmt) = ftell(blockFID);
                    end
                end
            end
            frewind(blockFID) %rewind after finding number of tables
        end