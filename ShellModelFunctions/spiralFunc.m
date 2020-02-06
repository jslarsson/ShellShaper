function spiral = spiralFunc(t,r0,z0,Kr,Kz)
% Gives a spiral with the given start values and growth parameters.
spiral = [r0*exp(Kr*t).*cos(t); -r0*exp(Kr*t).*sin(t); -z0*exp(Kz*t)];
