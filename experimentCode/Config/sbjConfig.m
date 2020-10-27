function [sbj] = sbjConfig(const)
% Type in the subject information and store in sbj:
%   PK, 21 / 03 / 2019

if const.startExp
   sbj.name   = input(sprintf('\n\tID: '),'s');
   sbj.task   = input(sprintf('\n\tTask: '));
%    if sbj.block == 1
      sbj.age    = input(sprintf('\n\tAge: '));
      sbj.sex    = input(sprintf('\n\tSex: '),'s');
      sbj.hand   = input(sprintf('\n\tHandedness: '),'s');
%    end
else
   sbj.name   = 'Anon';
   sbj.age    = 0;
   sbj.sex    = 'Anon';
   sbj.hand   = 'Anon';
   sbj.task   = 1; 
end

% create a folder in data: e.g. data/PK
sbj.sbjFolder = ['data/',sbj.name, '_', num2str(sbj.task)];
if ~exist(sbj.sbjFolder)
    mkdir(sbj.sbjFolder);
end

end