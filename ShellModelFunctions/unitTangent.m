function T = unitTangent(func)
% Gives the unit tangent for a given curve in space.
T = gradient(func);
for i = 1:length(T)
    T(:,i) = T(:,i)/norm(T(:,i));    
end
