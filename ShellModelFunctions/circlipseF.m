function apertureShape = circlipseF(a,b,c,s,theta)
% aperture shape function

theta = pi*theta/180;
    

s0 = s(s<=theta);
s1 = s(s<pi+theta & s> theta);
s2 = s(s>=pi+theta);

ap2 = b./sqrt(b^2.*abs(cos(s2-theta).^(a))+abs(sin(s2-theta).^(c)));
ap1 = ones(1,length(s1));%sqrt(cos(-s1).^2+sin(-s1).^2);
ap0 = b./sqrt(b^2.*abs(cos(s0-theta).^(a))+abs(sin(s0-theta).^(c)));
apertureShape = [ap0,ap1,ap2];

end