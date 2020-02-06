function shell = shellPlotOutsideFF(startRadius,startHeight,startAperture,...
    radiusGrowthFactor,heightGrowthFactor,apertureGrowthFactor,...
    a,b,c,theta,amount,phi,tStart,tEnd,...
    nGridpoints,skeletonPlot,aperturePlot,nBands,thickness)
% Plots a shell with inserted parameters.


t = linspace(2*pi*tStart,2*pi*tEnd,nGridpoints*(tEnd-tStart));
t = -t;
amount = pi*amount/180;
phi = pi*phi/180;
s = linspace(phi,amount+phi,nGridpoints);
thickness = 1-thickness;

% Generating aperture size function
apSize = aperture(t,startAperture,apertureGrowthFactor);


start = linspace(apSize(1)*thickness,apSize(1));
finish = linspace(apSize(end)*thickness,apSize(end));


% Generating the curve skeleton spiral
spiral = spiralFunc(t,startRadius,startHeight,radiusGrowthFactor,heightGrowthFactor);
shell.spiral = spiral;

% Generate the external spiral for FF reference
FFspiral = spiralFunc(t,startRadius+startAperture,startHeight,radiusGrowthFactor,heightGrowthFactor);



o1 = xPart(spiral);
o2 = yPart(spiral);
o3 = zPart(spiral);
ex1 = xPart(unitNormal(FFspiral));
ex2 = xPart(unitBinormal(FFspiral));
ey1 = yPart(unitNormal(FFspiral));
ey2 = yPart(unitBinormal(FFspiral));
ez1 = zPart(unitNormal(FFspiral));
ez2 = zPart(unitBinormal(FFspiral));

% FrenetRotation = 180*atan(ez1(1)/ex1(1));
% thetaF = theta + FrenetRotation;


% Generating the aperture shape function
%apShape = circlipseF(a,b,c,s,theta);
apShape = ones(1,length(s));



% Plot normal and binormal vectors
%     N1 = [apSize(1)*ex1(1)+o1(1),o1(1)];
%     N2 = [apSize(1)*ey1(1)+o2(1),o2(1)];
%     N3 = [apSize(1)*ez1(1)+o3(1),o3(1)];
%     B1 = [apSize(1)*ex2(1)+o1(1),o1(1)];
%     B2 = [apSize(1)*ey2(1)+o2(1),o2(1)];
%     B3 = [apSize(1)*ez2(1)+o3(1),o3(1)];
% 
%     plot3(N1,N2,N3,'k')
%     hold on
%     plot3(B1,B2,B3,'g')

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
        apShape'.*cos(s)'*(xPart(unitNormal(FFspiral)).*apSize)+...
        apShape'.*sin(s)'*(xPart(unitBinormal(FFspiral)).*apSize);
    Y = ones(nGridpoints,1)*yPart(spiral)+...
        apShape'.*cos(s)'*(yPart(unitNormal(FFspiral)).*apSize)+...
        apShape'.*sin(s)'*(yPart(unitBinormal(FFspiral)).*apSize);
    Z = ones(nGridpoints,1)*zPart(spiral)+...
        apShape'.*cos(s)'*(zPart(unitNormal(FFspiral)).*apSize)+...
        apShape'.*sin(s)'*(zPart(unitBinormal(FFspiral)).*apSize);
    
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
            plot3(X(:,1),Y(:,1),...
                Z(:,1),'color',green,'linewidth',2)
        end
    elseif thickness ~= ismember(0,0.99)
%         insideX = X;
%         insideY = Y;
%         insideZ = Z;
        shell.inside = surf(X,Y,Z,'FaceColor',shellcolor,'EdgeColor','none');
    end   
end

% Plot curve skeleton when corresponding box is checked
if skeletonPlot
    hold on
    plot3(spiral(1,:),spiral(2,:),spiral(3,:),'color',[0.7 0.3 0.8],'linewidth',3)
end
