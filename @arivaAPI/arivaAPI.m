classdef arivaAPI
    % arivaAPI provides an API to the ariva website
    %   

    properties
        stockName;
        startDate;
        endDate;
    end
    
    methods
     function obj = set.stockName(obj,val)
         if ~iscellstr(val)
            val = cellstr(val);
         end
         obj.stockName = val;
      end 
    end
    
    methods
        histDate = getHistData(obj);
        constituents = getConstituents(obj);
    end

end

