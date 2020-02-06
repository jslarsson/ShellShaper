function shell = shellPlot(startRadius,startHeight,startAperture,...
    radiusGrowthFactor,heightGrowthFactor,apertureGrowthFactor,...
    a,b,c,theta,amount,phi,tStart,tEnd,...
    nGridpoints,skeletonPlot,aperturePlot,nBands,thickness)
% Plots a shell with inserted parameters.


t = linspace(2*pi*tStart,2*pi*tEnd,nGridpoints*(tEnd-tStart));
t = -t; % Uncomment to let start parameters be final aperture
amount = pi*amount/180;
phi = pi*phi/180;
s = linspace(phi,amount+phi,nGridpoints);
thickness = 1-thickness;

% Generating aperture size function
apSize = aperture(t,startAperture,apertureGrowthFactor);
% Cut it off at aperture radius of less that 0.1 (mm)
% apSize = apSize(apSize >= 0.07);
% tEnd = -t(length(apSize));
% disp([tEnd/(2*pi), apSize(end)])
% t = linspace(2*pi*tStart,tEnd,ceil(nGridpoints*(tEnd/(2*pi)-tStart)));
% t = -t;


start = linspace(apSize(1)*thickness,apSize(1));
finish = linspace(apSize(end)*thickness,apSize(end));


% Generating the curve skeleton spiral
spiral = spiralFunc(t,startRadius,startHeight,radiusGrowthFactor,heightGrowthFactor);
spiralOut = spiralFunc(t,startRadius+startAperture,startHeight,radiusGrowthFactor,heightGrowthFactor);
%shell.spiral = spiral;


o1 = xPart(spiral);
o2 = yPart(spiral);
o3 = zPart(spiral);
ex1 = xPart(unitNormal(spiral));
ex2 = xPart(unitBinormal(spiral));
ey1 = yPart(unitNormal(spiral));
ey2 = yPart(unitBinormal(spiral));
ez1 = zPart(unitNormal(spiral));
ez2 = zPart(unitBinormal(spiral));

%FrenetRotation = 180*atan(ez1(1)/ex1(1));
%FrenetRotation = 180*atan(-ex2(1)/ez2(1));
%disp(FrenetRotation)
%thetaF = theta + FrenetRotation;


% Generating the aperture shape function
%apShape = flip(circlipse(a,b,c,s,theta));
apShape = ones(1,length(s));


% figure(2)
% plot3([apSize(1)*ex1(1),0,apSize(1)*ex2(1)],[apSize(1)*ey1(1),0,apSize(1)*ey2(1)],[apSize(1)*ez1(1),0,apSize(1)*ez2(1)])
% axis equal
% figure(1)
% Plot normal and binormal vectors

%     N1 = [apSize(end)*ex1(end)+o1(end),o1(end)];
%     N2 = [apSize(end)*ey1(end)+o2(end),o2(end)];
%     N3 = [apSize(end)*ez1(end)+o3(end),o3(end)];
%     B1 = [apSize(end)*ex2(end)+o1(end),o1(end)];
%     B2 = [apSize(end)*ey2(end)+o2(end),o2(end)];
%     B3 = [apSize(end)*ez2(end)+o3(end),o3(end)];
% 
%     hold on
%     plot3(N1,N2,N3,'m','LineWidth',2)
% 
%     plot3(B1,B2,B3,'g','LineWidth',2)


shellcolor = [0.7,0.7,0.7];

if thickness ~= 0
    % Generating start and end annulus
    diskX = o1(1)+apShape'.*cos(s)'*ex1(1).*start+...
        apShape'.*sin(s)'*ex2(1).*start;
    diskY = o2(1)+apShape'.*cos(s)'*ey1(1).*start+...
        apShape'.*sin(s)'*ey2(1).*start;
    diskZ = o3(1)+apShape'.*cos(s)'*ez1(1).*start+...
        apShape'.*sin(s)'*ez2(1).*start;
    %stopper0 = [diskX,diskY,diskZ];
    
    shell.starter = surf(diskX,diskY,diskZ,'FaceColor',shellcolor,'EdgeColor','none');
    hold on
    diskX = o1(end)+apShape'.*cos(s)'*ex1(end).*finish+...
        apShape'.*sin(s)'*ex2(end).*finish;
    diskY = o2(end)+apShape'.*cos(s)'*ey1(end).*finish+...
        apShape'.*sin(s)'*ey2(end).*finish;
    diskZ = o3(end)+apShape'.*cos(s)'*ez1(end).*finish+...
        apShape'.*sin(s)'*ez2(end).*finish;
    %stopperEnd = [diskX,diskY,diskZ];
    
    shell.stopper = surf(diskX,diskY,diskZ,'FaceColor',shellcolor,'EdgeColor','none');
end

% Generating the surface, outside and inside
% S(s,t)=H(t)+P(s)a(t)(cos(s)N(t)+sin(s)B(t))
for i=1:2
    if i==2 
        apSize = apSize*thickness;
        shellcolor = [0.25,0.25,0.25];
    elseif nBands > 0
        shellcolor = 'k';
    end
    
    X = ones(nGridpoints,1)*xPart(spiral)+...
        apShape'.*cos(s)'*(xPart(unitNormal(spiral)).*apSize)+...
        apShape'.*sin(s)'*(xPart(unitBinormal(spiral)).*apSize);
    Y = ones(nGridpoints,1)*yPart(spiral)+...
        apShape'.*cos(s)'*(yPart(unitNormal(spiral)).*apSize)+...
        apShape'.*sin(s)'*(yPart(unitBinormal(spiral)).*apSize);
    Z = ones(nGridpoints,1)*zPart(spiral)+...
        apShape'.*cos(s)'*(zPart(unitNormal(spiral)).*apSize)+...
        apShape'.*sin(s)'*(zPart(unitBinormal(spiral)).*apSize);
    
    if i==1
        outsideX = X;
        outsideY = Y;
        outsideZ = Z;
        shell.outside = surf(outsideX,outsideY,outsideZ,'FaceColor',shellcolor,'EdgeColor','none');
        if aperturePlot
            hold on
            green = [0, 0.75, 0.2];
            %plot3(X(:,length(t)),Y(:,length(t)),...
            %    Z(:,length(t)),'k','linewidth',2)
            shell.apertureCurve = plot3(X(:,end),Y(:,end),...
                Z(:,end),'color',green,'linewidth',2);
            widthPos = find(abs(Z(:,end) + startHeight) < 0.01);
            [~,maxwidth] = max(X(widthPos,end));
            widthPoint = [X(widthPos(maxwidth),end),Y(widthPos(maxwidth),end),Z(widthPos(maxwidth),end)];
        end
    elseif thickness ~= ismember(0,0.99)
        insideX = X;
        insideY = Y;
        insideZ = Z;
        shell.inside = surf(X,Y,Z,'FaceColor',shellcolor,'EdgeColor','none');
    end
    
    
    
    % Plot aperture curve when corresponding box is checked
    
end

hold on
% Plot curve skeleton when corresponding box is checked
if skeletonPlot ==1
    
    shell.spiral = plot3(spiral(1,:),spiral(2,:),spiral(3,:),'color','m','linewidth',3);%[0.7 0.3 0.8]
elseif skeletonPlot ==2
    v = acos(norm([widthPoint(1),widthPoint(2)])/(startRadius+startAperture));
    OutSpiral = spiralOut;
    OutSpiral(1,:) = cos(v)*spiralOut(1,:) - sin(v)*spiralOut(2,:);
    OutSpiral(2,:) = sin(v)*spiralOut(1,:) + cos(v)*spiralOut(2,:);
    shell.outsideSpiral = plot3(OutSpiral(1,:),OutSpiral(2,:),OutSpiral(3,:),'color',[0.2 0.6 0.6],'linewidth',3);
end
