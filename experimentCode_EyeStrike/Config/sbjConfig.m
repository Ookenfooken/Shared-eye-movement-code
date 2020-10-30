function [sbj] = sbjConfig(const)
% Type in the subject information and store in sbj:
%   PK, 21 / 03 / 2019

if const.startExp
   sbj.name = input(sprintf('\n\tInitials: '),'s');
   sbj.age  = input(sprintf('\n\tAge: '));
   sbj.sex  = input(sprintf('\n\tSex: '),'s');
   sbj.hand = input(sprintf('\n\tHandedness: '),'s');
    
else
   sbj.name = 'Anon';
   sbj.age  = 0;
   sbj.sex  = 'Anon';
   sbj.hand = 'Anon';
    
end

% create a folder in data: e.g. PK_2019_03_24_151515
t = datetime('now','Format', 'yyyy_MM_dd''_''HHmmss');
sbj.filename = [sbj.name '_' char(t)];
mkdir(['data/',sbj.filename])

end