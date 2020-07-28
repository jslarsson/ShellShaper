% Path to folder containing photos and functions
addpath .\ShellsToShape
addpath .\ShellModelFunctions

% Use all .jpg and .jpeg files in the photo folder
contents = dir('ShellsToShape\*.jp*g');

% Save in the following table and folder
saveas = '.\ShapedShells\parameters.txt';
saveimagefolder = '.\ShapedShells';


% Go through these shell images.
startNumber = 1;
lastNumber = numel(contents);

% Show internal growth spiral? 1/0
showspiral = 1;


% Run program
ShellShaperProgram(contents, saveas, saveimagefolder, startNumber, lastNumber, showspiral)
