% Copyright 2014 Google, Inc.
% Check data against min/max/cap limits 
% Author: TaiWen Ko
% Date: 2014-12-09

% Change Log: 
function result = checkdata(data,min,max,cap,fileID)

    max_failure = 0;
    min_failure = 0; 

    for i = 1:length(data)
        
        if data(i) > max
            
            max_failure = max_failure + 1; 
            
        elseif data(i) < min
            
            min_failure = min_failure + 1; 
            
        end 
        
    end 
        
    if (max_failure + min_failure) > cap
        
        result = 'FAIL'; 
        fprintf (['Data went over max limit (', num2str(max), ') ', num2str(max_failure), ' times and went under min limit (', num2str(min), ') ', num2str(min_failure) ' times for ']);
        fprintf (fileID,['Data went over max limit (', num2str(max), ') ', num2str(max_failure), ' times and went under min limit (', num2str(min), ') ', num2str(min_failure) ' times for ']); 
    
    else 
        
        result = 'OK';
        fprintf (fileID,['Data went over max limit (', num2str(max), ') ', num2str(max_failure), ' times and went under min limit (', num2str(min), ') ', num2str(min_failure) ' times for ']); 
        
    end 
    
    
end 