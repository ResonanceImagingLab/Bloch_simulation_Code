% function parsave(stem,i,vars)
%         save(sprintf([stem '%d.mat'],i),'-struct','vars')
%     end

function  parsave(stem,ii, varargin)
%-----------inputs-----------:
%file_name; name of .matfile to be saved
%varargin{}:  variables needed to be  saved to the matfile named in file_name. 
ct ={}; %to be converted to structure as struct(field1,value1,...,fieldN,valueN)
fi=1; % initial field index
vi=2; %  =   value index
for i=1:numel(varargin)
    
    ct{fi} = inputname(i+2);%+1 since the 1st input is filename
    
    ct{vi} =varargin{i};
    fi=fi+2;
    vi=vi+2;
end
s = struct(ct{:}) ;% put inputs in a structure with fields that has same name as the inputs
%save(file_name,'-v7.3', '-struct','s','-nocompression')
save(sprintf([stem '%d.mat'],ii),'-struct','s')
end


% function parsave(fname, data)
%    var_name=inputname(2);
%    eval([var_name '=data'])
%    save(fname,var_name);
% end




 




% function parsave (savefile,varargin)
% % parsave v1.0.0 (June 2016).
% % parsave allows to save variables to a .mat-file while in a parfor loop.
% % This is not possible using the regular 'save' command.
% %
% % SYNTAX:   parsave(FileName,Variable1,Variable2,...)
% %
% % NOTE: Unlike 'save', do NOT pass the variable names to this function
% % (e.g. 'Variable') but instead the variable itself, so without using the
% % quotes. An example of correct usage is:
% % CORRECT: parsave('file.mat',x,y,z);
% %
% % This would be INCORRECT: parsave('file.mat','x','y','z'); %Incorrect!
% %
% %Copyright (c) 2016 Joost H. Weijs
% %ENS Lyon, France
% %<jhweijs@gmail.com>
% 
% for i=1:nargin-1
%     %Get name of variable
%     name{i}=inputname(i+1);
%     
%      %Create variable in function scope
%     eval([name{i} '=varargin{' num2str(i) '};']); 
% end
% 
% %Save all the variables, do this by constructing the appropriate command
% %and then use eval to run it.
% comstring=['save(''' savefile ''''];
% for i=1:nargin-1
%     comstring=[comstring ',''' name{i} ''''];
% end
% comstring=[comstring ');'];
% eval(comstring);
% 
% 
% end

% function parsave(fname, x)
% 
%   save(fname, x)
% end