function N = unitNormal(func)
% Gives the unit normal for a space curve.
N = unitTangent(unitTangent(func));
for i = 1:length(N)
    N(:,i) = N(:,i)/norm(N(:,i));    
end