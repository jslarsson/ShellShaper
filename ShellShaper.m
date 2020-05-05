% Path to folder containing photos and functions
addpath .\ShellsToShape
addpath .\ShellModelFunctions

% Use all .jpg and .jpeg files in the photo folder
contents = dir('ShellsToShape\*.jp*g');

% Save in the following table (.txt or .csv) and folder
% The table will be appended
saveas = '.\ShapedShells\parameters.csv';
saveimagefolder = '.\ShapedShells';


% Go through these shell images.
startNumber = 1;
lastNumber = numel(contents);


% Run program
ShellShaperProgram(contents, saveas, saveimagefolder, startNumber, lastNumber)
