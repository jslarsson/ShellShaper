function [b1,b2,b3] = extrinsic2intrinsic(gw,gh,r0,h0,t)

b1 = exp(-gw*t).*sqrt(exp(2*gh*t)*gh^2*h0^2+exp(2*gw*t)*(1+gw^2)*r0^2);

b2 = -r0*sqrt( (1+gw^2)*(exp(2*(gh+gw)*t)*gh^2*(1+gh^2-2*gh*gw+gw^2)*h0^2+exp(4*gw*t)*(1+gw^2)*r0^2) )./...
    (exp(2*gh*t)*gh^2*h0^2 + exp(2*gw*t)*(1+gw^2)*r0^2);


b3part1 = exp(2*(2*gh+gw)*t) .*abs( (gh^2*sqrt(1+gw^2)*(-gh^3+gw+3*gh^2*gw+gw^3-gh*(1+3*gw^2))*h0^2*r0) ./...
    ( exp(2*gh*t)*gh^2*(1+gh^2-2*gh*gw+gw^2)*h0^2+exp(2*gw*t)*(1+gw^2)*r0^2).^(3/2) ).^2;

b3part2 = (gh*(1+gh^2-2*gh*gw+gw^2)*h0*( (exp(2*gh*t)*gh^2*(gh-2*gw)*h0^2-exp(2*gw*t)*gw*(1+gw^2)*r0^2).*cos(t) + ...
    (exp(2*gh*t)*gh^2*(1+gh*gw-gw^2)*h0^2+exp(2*gw*t)*(1+gw^2)*r0^2).*sin(t) )./ ...
    ( sqrt(1+gw^2)*(exp(2*gh*t)*gh^2*(1+gh^2-2*gh*gw+gw^2)*h0^2+exp(2*gw*t)*(1+gw^2)*r0^2).^(3/2)) ).^2;

b3part3 = (gh*(1+gh^2-2*gh*gw+gw^2)*h0*((exp(2*gh*t)*gh^2*(1+gh*gw-gw^2)*h0^2 +...
    exp(2*gw*t)*(1+gw^2)*r0^2).*cos(t) + (-exp(2*gh*t)*gh^2*(gh-2*gw)*h0^2+exp(2*gw*t)*gw*(1+gw^2)*r0^2).*sin(t)) ./...
    ( sqrt(1+gw^2)*(exp(2*gh*t)*gh^2*(1+gh^2-2*gh*gw+gw^2)*h0^2+exp(2*gw*t)*(1+gw^2)*r0^2).^(3/2) )).^2;

b3 = sqrt( b3part1 + exp(2*gh*t).*(abs(b3part2) + abs(b3part3)) );