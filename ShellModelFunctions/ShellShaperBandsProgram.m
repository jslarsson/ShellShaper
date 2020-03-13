function ShellShaperBandsProgram(contents, saveas, saveimagefolder, startNumber, lastNumber)

input = inputdlg('Maximum number of bands?', ...
    'Input',[1,30]);
maxBands = str2double(input);


nSnails = numel(contents);
growthP = zeros(nSnails,2);
startV = zeros(nSnails,3);
eccent = zeros(nSnails,2);
scaleF = zeros(nSnails,1);
shellLength = zeros(nSnails,1);
photoID = strings(nSnails,1);
apexpoints = zeros(nSnails,2);
bandA = zeros(nSnails,2*maxBands);
apertureA = zeros(nSnails,2);
model = [];
modelbands = [];

% We do not need to be told if the image is too big.
warning('off', 'Images:initSize:adjustingMag');

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

    
    list = 1:maxBands;
    list = string(list);

    [indx,~] = listdlg('ListString', list,'PromptString','Select all bands which are present.');
        
    
    L1 = drawpoint('Label','Apex');
    pause
    L2 = drawpoint('Label','Right1');
    pause
    L3 = drawpoint('Label','Right2');
    pause
    L5 = drawpoint('Label','FarRight');
    pause
    L13 = drawpoint('Label','Left');
    pause
    L12 = drawpoint('Label','FarLeft');
    pause
    C1 = drawcircle('Label','Circle');
    pause
%     E = drawellipse('Center',C1.Center,'Label','Ellipse','SemiAxes',[C1.Radius,1.5*C1.Radius]);
%     pause
    L7 = drawpoint('Label','EndS');
    pause
    L8 = drawpoint('Label','EndC');
    pause
    
    bandpos = nan(2*maxBands,2);
    bandstart = cell(length(indx),1);
    bandend = cell(length(indx),1);
    % Banding
    for i = 1:length(indx)
        pointlabel = strcat('B',string(indx(i)),'start');
        bandstart{i} = drawpoint('Label',pointlabel);
        pause
        pointlabel = strcat('B',string(indx(i)),'end');
        bandend{i} = drawpoint('Label',pointlabel);
        pause
        bandpos(2*indx(i)-1,:) = bandstart{i}.Position;
        bandpos(2*indx(i),:) = bandend{i}.Position;
    end

    % Size
    %[~, ind] = max(E.Vertices(:,2));
    endline = [C1.Center(1), C1.Center(2)+C1.Radius];
    L = drawline('Label','L','Position',[L1.Position; endline]);%E.Vertices(ind,:)
    pause

    scaleLength = inputdlg('How many mm is this length?',...
        'Scale');
    scaleL = str2double(scaleLength{:});
    L.Visible = 'off';
    scale = norm(L.Position(1,:)-L.Position(2,:))/scaleL;
    bandpos = bandpos./scale;
    
    done = false;
    fig2 = figure;
    while done == false
        apex = L1.Position;
        
        snailData = [L1.Position; L2.Position; L3.Position; L5.Position; ...
            L12.Position; L13.Position; L7.Position; L8.Position]./scale;
        %circlipse = [C1.Center; C1.Radius, E.SemiAxes(2)]./scale;
        circleData = [C1.Center; C1.Radius, 0]./scale;
        
        %theta = min(E.RotationAngle,360-E.RotationAngle);
        %isneg = -sign(180-E.RotationAngle);
        [startValues, growthParameters, angle, eccentricity, X,...
            visiblepart, rotangle, bandAngles] = FindParametersBands(snailData,circleData,0,bandpos);
        eccentricity(1) = 1;
        
        figure(fig2)
        set(fig2,'units','normalized','outerposition',[0.6 0.1 0.4 0.8])
        clf
        hold on
        shell = shellPlot(startValues(1),startValues(2),startValues(3),...
            growthParameters(1),growthParameters(2),growthParameters(1),...
            2,eccentricity(1),2,eccentricity(2),visiblepart(2)-visiblepart(1),visiblepart(1),0,5,...
            180,1,0,0,0); %OutsideFF
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
        
        for j = 1:length(indx)
            banding(indx(j)) = shellPlot(startValues(1),startValues(2),startValues(3),...
            growthParameters(1),growthParameters(2),growthParameters(1),...
            2,eccentricity(1),2,eccentricity(2),bandAngles(2*indx(j))-bandAngles(2*indx(j)-1),bandAngles(2*indx(j)-1),0,5,...
            180,1,0,1,0);
            % shellPlotOutsideFF
        end
        camlight(-70,30)
        camlight(70,-30)
        view(-180/pi*rotangle,0)
        lighting phong
        material([0.3 0.7 0.1])
        axis equal
        axis off

        
        figure(fig1)
        hold on
        delete(model)
        delete(modelbands)
        model = plotOnImage(shell.outside, fig1, apex, -angle, scale,...
            rotangle, vertmove, [0.6 0.2 0.7]);
        for j = 1:length(indx)
            modelbands(indx(j)) = plotOnImage(banding(indx(j)).outside,fig1,apex, -angle, scale,...
                rotangle, vertmove, 'k');
        end
        
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

            for i = 1:size(bandend,1)
               bandstart{i}.Visible = 'off';
               bandend{i}.Visible = 'off';
            end
            
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
    photoID(snailNumber) = string(snailname);
    apexpoints(snailNumber,:) = apex;
    bandA(snailNumber,:) = bandAngles;
    apertureA(snailNumber,:) = visiblepart;
    
    model = [];
    modelbands = [];
    
    disp(['Done with number: ',num2str(snailNumber)])
    disp(['Photo: ',filename])
    disp(' ')
    toc
end

%% Saves a table with the result to a txt-file, or csv.

widthGrowth = growthP(:,1);
heightGrowth = growthP(:,2);
aperturePositionRadial = startV(:,1);
aperturePositionHeight = startV(:,2);
apertureSize = startV(:,3);
scaleFactor = scaleF;
apertureSuture = apertureA(:,1);
apertureColumnella = apertureA(:,2);
%eccentricity = eccent(:,1);
%apAngle = eccent(:,2);
apexPos = apexpoints;
%%

results = table(photoID, widthGrowth, heightGrowth, aperturePositionRadial,...
    aperturePositionHeight,apertureSize,bandA,apertureSuture,apertureColumnella,...
    shellLength, apexPos, scaleFactor);
results = splitvars(results,'bandA');

for i = 1:maxBands
    results.Properties.VariableNames{6+2*i-1} = char(strcat('band',string(i),'start'));
    results.Properties.VariableNames{6+2*i} = char(strcat('band',string(i),'end'));
end
%%

writetable(results,saveas)