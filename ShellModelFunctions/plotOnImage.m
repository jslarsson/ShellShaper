function Smodel = plotOnImage(model, fig1, apex, angle, scale, rotangle, vertmove, fcolor)

set(0,'DefaultFigureVisible','off')

X = model.XData.*scale;
Z = -model.YData.*scale;
Y = -model.ZData.*scale;

figure
S = surface(X,Y,Z);

rotate(S,[0,1,0],180/pi*rotangle,[0,0,0])
rotate(S,[0,0,1],180*angle/pi,[0,0,0]);

X = S.XData+apex(1);
Y = S.YData+apex(2);
Z = S.ZData+vertmove;
lgt1 = camlight(-70,30);
lgt2 = camlight(70,-30);

set(0,'DefaultFigureVisible','on')
figure(fig1)

Smodel = surface(X,Y,Z,'FaceColor',fcolor,'EdgeColor','none');
hold on
camlight(lgt1, -70,30);
camlight(lgt2, 70, 30);
view(0,90)
lighting phong
alpha(Smodel,0.4)
material(Smodel,[0.3 0.7 0.1])
axis equal
axis off


