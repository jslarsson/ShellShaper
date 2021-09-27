function [startValues, growthParameters, angle,...
    eccentricity, coilingaxis, vpart, rotangle] = FindParameters(snailData,circl, theta)


% Move origin to apex and rename
apex = snailData(1,:);
tData = snailData - apex;
circlipse = circl(1,:) - apex;

P = tData(3,:);
Q = tData(5,:);
T = tData(4,:);

% Suture growth to find vertical axis
v = P - Q;
u = Q - T;

p = (Q(2)*u(1)+v(2)*T(1)-Q(1)*u(2)-v(1)*T(2))/...
    (2*(v(2)*u(1)-v(1)*u(2)));
q = (Q(2)*T(1)-Q(1)*T(2))/(v(2)*u(1)-v(1)*u(2));
SutureGrowth = -p - sqrt(p^2-q);

% Points on new y-axis
X = Q + SutureGrowth*v;
%Y = T + SutureGrowth*u;
coilingaxis = X + apex;
% Rotation angle
angle = atan(X(1)/X(2));


% Landmark coordinates get rotated
Rotation = [cos(angle) -sin(angle); sin(angle) cos(angle)];
rotData = (Rotation*tData')';
rotStart = (Rotation*circlipse')';
r0 = rotStart(1,1);
h0 = rotStart(1,2); 
a0 = circl(2,1); 
startValues = [r0, h0, a0];
eccent = circl(2,2);

if snailData(2,1)~=0
% Radius and aperture parameter fit
widthMeasurement = abs([(rotStart(1,1)+a0); rotData(5,1);...
    rotData(3,1); rotData(6,1); rotData(2,1)]);
% angle between landmarks: pi
t = -[0; pi; 2*pi; 3*pi; 4*pi];

widthFit = fit(t,widthMeasurement, 'exp1');
widthCoeff = coeffvalues(widthFit);
gw = widthCoeff(2);


% Height parameters
heightMeasurement = abs([rotStart(1,2); rotData(5,2);...
    rotData(3,2); rotData(6,2); rotData(2,2)]);
heightFit = fit(t,heightMeasurement,'exp1');
coeff = coeffvalues(heightFit);

gh = coeff(2);
else
    % Radius and aperture parameter fit
widthMeasurement = abs([(rotStart(1,1)+a0); rotData(5,1);...
    rotData(3,1); rotData(6,1)]);
% angle between landmarks: pi
t = -[0; pi; 2*pi; 3*pi];

widthFit = fit(t,widthMeasurement, 'exp1');
widthCoeff = coeffvalues(widthFit);
gw = widthCoeff(2);


% Height parameters
heightMeasurement = abs([rotStart(1,2); rotData(5,2);...
    rotData(3,2); rotData(6,2)]);
heightFit = fit(t,heightMeasurement,'exp1');
coeff = coeffvalues(heightFit);

gh = coeff(2);
end


growthParameters = [gw,gh];

%%

short = linspace(-pi,0);
orgFFspiral = spiralFunc(short,rotStart(1,1)+a0,rotStart(1,2),gw,gh);
%    plot3(orgspiral(1,:),orgspiral(2,:),orgspiral(3,:));
sT = unitTangent(orgFFspiral);
rotangle = -acos(norm([0,sT(2,end),sT(3,end)])/norm(sT(:,end)));
%rotate(spiralplot,[0,0,-1],rotangle,[0, 0, 0]);

rotM = [cos(rotangle) -sin(rotangle); sin(rotangle) cos(rotangle)];
rotSp = rotM*orgFFspiral([1 2],:);
spiral = [rotSp; orgFFspiral(3,:)];
%    plot3(spiral(1,:),spiral(2,:),spiral(3,:),'g')
%     spx = spiralplot.XData;
%     spy = spiralplot.YData;
%     spz = spiralplot.ZData;
%     spiral = [spx;spy;spz];
xN = xPart(unitNormal(spiral));
yN = yPart(unitNormal(spiral));
zN = zPart(unitNormal(spiral));
xB = xPart(unitBinormal(spiral));
yB = yPart(unitBinormal(spiral));
zB = zPart(unitBinormal(spiral));
%     plot3([spiral(1,end),spiral(1,end)+xN(end)],[spiral(2,end),spiral(2,end)+yN(end)],...
%         [spiral(3,end),spiral(3,end)+zN(end)],'y')
%     plot3([spiral(1,end),spiral(1,end)+xB(end)],[spiral(2,end),spiral(2,end)+yB(end)],...
%         [spiral(3,end),spiral(3,end)+zB(end)],'m')
% The angle in degrees between the rotated curve's unit normal and the
% x-axis
normalAngle = sign(zN(end))*180/pi*acos(norm(xN(end))/norm([xN(end),yN(end),zN(end)]));
apRotation = theta + 180/pi*angle - normalAngle;


vec1 = rotData(7,:)-rotStart(1,:);
vec2 = rotData(8,:)-rotStart(1,:);
sangle = 180+180/pi*atan2(vec1(2),vec1(1));
eangle = 180+180/pi*atan2(vec2(2),vec2(1));
vpart = [sangle, eangle]-normalAngle;

thetashift = pi/2 - pi/180*apRotation;
cX = cos(thetashift)*(xN(end))+...
    sin(thetashift)*(xB(end));
cY = cos(thetashift)*(yN(end))+...
    sin(thetashift)*(yB(end));
cZ = cos(thetashift)*(zN(end))+...
    sin(thetashift)*(zB(end));
cN = norm([cX,cY,cZ]);
%     scatter3(spiral(1,end)+cX,spiral(2,end)+cY,spiral(3,end)+cZ,'k')
cNP = norm([cX(end),0,cZ(end)]);
c = eccent*cN/cNP;
eccentricity = [c,apRotation];