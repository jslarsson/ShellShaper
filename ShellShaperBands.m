% Path to folders containing photos and functions
addpath .\ShellsToShape
addpath .\ShellModelFunctions

% Use all .jpg and .jpeg files in the photo folder 
contents = dir('ShellsToShape\*.jp*g');
nSnails = numel(contents);

% Save in the following table and existing folder
saveas = '.\ShapedShells\parameters.csv';
saveimagefolder = '.\ShapedShells';

% Loop through shell images, from startNumber to lastNumber,
% change to lastNumber = nSnails to do all.
startNumber = 1;
lastNumber = 4; %nSnails;

% Run the program
ShellShaperBandsProgram(contents, saveas, saveimagefolder, startNumber, lastNumber)

