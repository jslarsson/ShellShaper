function B = unitBinormal(func)
% Gives the unit binormal to a curve in space
B = cross(unitTangent(func),unitNormal(func));