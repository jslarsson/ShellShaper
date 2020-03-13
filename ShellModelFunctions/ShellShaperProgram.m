function ShellShaperProgram(contents, saveas, saveimagefolder, startNumber, lastNumber)

nSnails = numel(contents);
growthP = zeros(nSnails,2);
startV = zeros(nSnails,3);
eccent = zeros(nSnails,2);
scaleF = zeros(nSnails,1);
shellLength = zeros(nSnails,1);
snailID = strings(nSnails,1);
apexpoints = zeros(nSnails,2);

% We do not need to be told if the image is too big.
warning('off', 'Images:initSize:adjustingMag');


model = [];

tic
for snailNumber = startNumber:lastNumber
    filename = contents(snailNumber).name;
    snailimage = imread(filename);
    snailname = filename(1:end-4);
    
    % Does the following until good shape is obtained
    fig1 = figure(1);
    set(fig1,'units','normalized','outerposition',[0.1 0.1 0.9 0.9])
    
    hold on
    imshow(snailimage)
    
    L1 = drawpoint('Label','Apex');
    pause
    L2 = drawpoint('Label','Right1');
    pause
    L3 = drawpoint('Label','Right2');
    pause
    L5 = drawpoint('Label','ExtremeRight');
    pause
    L13 = drawpoint('Label','Left');
    pause
    L12 = drawpoint('Label','ExtremeLeft');
    pause
    C1 = drawcircle('Label','Circle');
    pause
    E = drawellipse('Center',C1.Center,'Label','Ellipse','SemiAxes',[C1.Radius,1.5*C1.Radius]);
    pause
    L7 = drawpoint('Label','EndSuture');
    pause
    L8 = drawpoint('Label','EndColumnella');
    pause
    
    
    % Size
    [~, ind] = max(E.Vertices(:,2));
    L = drawline('Label','L','Position',[L1.Position; E.Vertices(ind,:)]);
    pause

    scaleLength = inputdlg('How many mm is this length?',...
        'Scale');
    scaleL = str2double(scaleLength{:});
    
    
    L.Visible = 'off';
    done = false;
    fig2 = figure;
    while done == false
        apex = L1.Position;
        scale = norm(L.Position(1,:)-L.Position(2,:))/scaleL;
        snailData = [L1.Position; L2.Position; L3.Position; L5.Position; ...
            L12.Position; L13.Position; L7.Position; L8.Position]./scale;
        circlipse = [C1.Center; C1.Radius, E.SemiAxes(2)]./scale;

        
        theta = min(E.RotationAngle,360-E.RotationAngle);
        isneg = -sign(180-E.RotationAngle);
        [startValues, growthParameters, angle, eccentricity, X,...
            visiblepart, rotangle] = FindParameters(snailData,circlipse,isneg*theta);

        figure(fig2)
        set(fig2,'units','normalized','outerposition',[0.6 0.1 0.4 0.8])
        clf
        shell = shellPlot(startValues(1),startValues(2),startValues(3),...
            growthParameters(1),growthParameters(2),growthParameters(1),...
            2,eccentricity(1)/startValues(3),2,eccentricity(2),visiblepart(2)-visiblepart(1),visiblepart(1),0,5,...
            180,1,0,0,0.1);
        
        
        camlight(-70,30)
        camlight(70,-30)
        view(-180/pi*rotangle,0)
        lighting phong
        material([0.3 0.7 0.1])
        alpha(0.5)
        axis equal
        axis off
        M = max(shell.outside.ZData,[],'all');
        m = min(shell.outside.ZData,[],'all');
        vertmove = max(abs(shell.outside.YData),[],'all')*1.2*scale;
        shellL = abs(m-M);
        
        figure(fig1)
        hold on
        delete(model)
        model = plotOnImage(shell.outside, fig1, apex, ...
            -angle, scale,rotangle,vertmove, [0.6 0.2 0.7]);
        
        
        input = questdlg('Is this good enough?', ...
            'Outline','Yes','No','Yes');
        if strcmp(input,'Yes')
            done = true;
            L1.Visible = 'off'; 
            L2.Visible = 'off'; 
            L3.Visible = 'off'; 
            L5.Visible = 'off';
            L12.Visible = 'off'; 
            L13.Visible = 'off';
            C1.Visible = 'off';
            C2.Visible = 'off'; 
            E.Visible = 'off'; 
            L7.Visible = 'off';
            L8.Visible = 'off';
            F2 = getframe(fig2);
            Image = frame2im(F2);
            savemodelname = strcat(saveimagefolder,'\model_',filename);
            imwrite(Image, savemodelname)
            F1 = getframe(fig1);
            Image = frame2im(F1);
            saveimagename = strcat(saveimagefolder,'\both_',filename);
            imwrite(Image, saveimagename)
            close all
        elseif strcmp(input,'No')
            pause
        end
    end
    
    growthP(snailNumber,:) = growthParameters;
    startV(snailNumber,:) = startValues;
    eccent(snailNumber,:) = eccentricity;
    scaleF(snailNumber) = scale;
    shellLength(snailNumber) = shellL;
    snailID(snailNumber) = string(snailname);
    apexpoints(snailNumber,:) = apex;
    
    disp(['Done with number: ',num2str(snailNumber)])
    disp(['Photo: ',filename])
    disp(' ')
    toc
end

%% Saves a table with the result to a txt-file, or csv.

gw = growthP(:,1);
gh = growthP(:,2);
r0 = startV(:,1);
z0 = startV(:,2);
a0 = startV(:,3);
scaleFactor = scaleF;
eccentricity = eccent(:,1);
apAngle = eccent(:,2);
apex = apexpoints;
results = table(snailID, gw, gh, r0,z0,a0,...
    eccentricity, apAngle, shellLength, apex, scaleFactor);
writetable(results,saveas)

