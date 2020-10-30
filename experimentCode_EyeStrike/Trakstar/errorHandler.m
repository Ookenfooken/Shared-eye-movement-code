%  errorHandler: error handler takes the error code and passes it to the
%  GetErrorText() procedure along with a buffer to place an error message string.
%  This error message is displayed to the MATLAB command window

%  Ascension Technology Corporation 

function  errorHandler(temp)

    
tt        = blanks(1024);
pRecords  = libpointer('cstring', tt);

while(temp ~= 0)
    % Note: For this function to work MATLAB version must support
    %       MATLAB primitive type: "cstring"
   [temp pRecords1] =   calllib('ATC3DG', 'GetErrorText', int32(temp), pRecords , 1024, 1);
   fprintf(2,pRecords1)
   fprintf('\n')
   error('MATLAB Driver will terminate.')
end

end
