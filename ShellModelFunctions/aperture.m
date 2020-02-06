function a = aperture(t,a0,Ka)
% Gives the aperture size factor as a function of time.
a = a0*exp(Ka*t);