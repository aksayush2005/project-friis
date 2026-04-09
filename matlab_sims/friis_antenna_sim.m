%%project-friis
clc; clear; close all;

filename = input('OSM file: ','s');
Pt = input('Pt: '); Gt = input('Gt: '); Gr = input('Gr: ');
n = input('Path loss exponent: ');
ns = input('Number of sectors: ');
thr = input('Coverage threshold (dB): ');
noise = 1e-9;

doc = xmlread(filename);
nodes = doc.getElementsByTagName('node');
ways  = doc.getElementsByTagName('way');

nodeMap = containers.Map('KeyType','double','ValueType','any');

for i=0:nodes.getLength-1
    nd=nodes.item(i);
    id=str2double(nd.getAttribute('id'));
    lat=str2double(nd.getAttribute('lat'));
    lon=str2double(nd.getAttribute('lon'));
    nodeMap(id)=[lon*111320 lat*110540];
end

obs=[];
for i=0:ways.getLength-1
    w=ways.item(i);
    tags=w.getElementsByTagName('tag');
    isB=false;
    for t=0:tags.getLength-1
        tg=tags.item(t);
        if strcmp(char(tg.getAttribute('k')),'building')
            isB=true; break;
        end
    end
    if isB
        nds=w.getElementsByTagName('nd'); coords=[];
        for j=0:nds.getLength-1
            ref=str2double(nds.item(j).getAttribute('ref'));
            if isKey(nodeMap,ref), coords=[coords; nodeMap(ref)]; end
        end
        if size(coords,1)>2
            ox=min(coords(:,1)); oy=min(coords(:,2));
            ow=max(coords(:,1))-ox; oh=max(coords(:,2))-oy;
            obs=[obs; ox oy ow oh 20];
        end
    end
end

obs(:,1)=obs(:,1)-min(obs(:,1));
obs(:,2)=obs(:,2)-min(obs(:,2));
cx=mean(obs(:,1)); cy=mean(obs(:,2));
obs(:,1)=obs(:,1)-cx; obs(:,2)=obs(:,2)-cy;

area=ceil(max(abs(obs(:)))*1.2);
step=max(5,round(area/200));

x=-area:step:area; y=-area:step:area;
[X,Y]=meshgrid(x,y);

fig=figure('Name','RF Planner','NumberTitle','off');
ax=axes(fig); hold on;
for i=1:size(obs,1)
    rectangle(ax,'Position',obs(i,1:4),'EdgeColor',[0.6 0.6 0.6]);
end
axis equal; grid on; zoom off; pan off;
title('Click tower → enter angle → Simulate');

data.tx=[]; data.ty=[]; data.theta=[];
data.X=X; data.Y=Y; data.obs=obs;
data.Pt=Pt; data.Gt=Gt; data.Gr=Gr;
data.n=n; data.ns=ns; data.noise=noise; data.thr=thr;

guidata(fig,data);

uicontrol('Style','pushbutton','String','Simulate',...
    'Position',[20 20 120 40],'Callback',@simulate);

set(fig,'WindowButtonDownFcn',@clickCb);

function clickCb(src,~)
d=guidata(src);
cp=get(gca,'CurrentPoint');
x=cp(1,1); y=cp(1,2);
ang=input('Angle (deg): ');
d.tx(end+1)=x; d.ty(end+1)=y; d.theta(end+1)=deg2rad(ang);
plot(x,y,'ro','LineWidth',2)
quiver(x,y,cosd(ang)*50,sind(ang)*50,'r','LineWidth',2)
guidata(src,d);
end

function simulate(src,~)
d=guidata(src);

tx=d.tx; ty=d.ty; th=d.theta;
X=d.X; Y=d.Y; obs=d.obs;
Pt=d.Pt; Gt=d.Gt; Gr=d.Gr;
n=d.n; ns=d.ns; noise=d.noise; thr=d.thr;

if isempty(tx), disp('No towers'); return; end

SINR_dB = compute(tx,ty,th,X,Y,Pt,Gt,Gr,n,ns,noise,obs);
SINR_dB = imgaussfilt(SINR_dB,2);

cov = sum(SINR_dB(:)>thr)/numel(SINR_dB);
fprintf('\nCoverage = %.2f %%\n',cov*100);

if cov < 0.6
    fprintf('Recommended angles:\n');
    for i=1:length(tx)
        best=th(i); bestScore=-inf;
        for ang=0:30:330
            test=th; test(i)=deg2rad(ang);
            S=compute(tx,ty,test,X,Y,Pt,Gt,Gr,n,ns,noise,obs);
            sc=sum(S(:)>thr);
            if sc>bestScore
                bestScore=sc; best=deg2rad(ang);
            end
        end
        fprintf('Tower %d → %.1f°\n',i,rad2deg(best));
    end
else
    fprintf('Coverage acceptable\n');
end

figure
imagesc(X(1,:),Y(:,1),SINR_dB)
axis xy; colormap(jet); colorbar; hold on
plot(tx,ty,'wo','LineWidth',2)
title(sprintf('Heatmap (%.2f%%)',cov*100))

figure
contour(X,Y,SINR_dB,20)
colorbar; hold on; plot(tx,ty,'ro')
title('Contour')

figure
surf(X,Y,SINR_dB)
shading interp; colorbar
title('3D'); view(45,40)

end

function SINR_dB=compute(tx,ty,th,X,Y,Pt,Gt,Gr,n,ns,noise,obs)

Pr_all=zeros([size(X),length(tx)]);

for i=1:length(tx)
    dx=X-tx(i); dy=Y-ty(i);
    d=sqrt(dx.^2+dy.^2); d(d==0)=1;
    theta=atan2(dy,dx);

    bw=360/ns; sg=zeros(size(X));

    for s=1:ns
        ts=deg2rad((s-1)*bw)+th(i);
        tr=atan2(sin(theta-ts),cos(theta-ts));
        mask=abs(rad2deg(tr))<=bw/2;
        G=exp(-(tr.^2)/(2*(deg2rad(bw/2.5))^2));
        G(~mask)=0;
        sg=max(sg,G);
    end

    Pr=Pt*Gt*Gr.*sg./(d.^n);
    Pr=Pr.*10.^((4*randn(size(X)))/10);

    d_ref=sqrt((X-tx(i)).^2+(Y+ty(i)).^2); d_ref(d_ref==0)=1;
    Pr=Pr+0.3*Pt./(d_ref.^n);

    for k=1:size(obs,1)
        o=obs(k,:);
        in=(X>o(1)&X<o(1)+o(3)&Y>o(2)&Y<o(2)+o(4));
        Pr(in)=Pr(in)*10^(-o(5)/10);
    end

    Pr_all(:,:,i)=Pr;
end

sig=max(Pr_all,[],3);
intf=sum(Pr_all,3)-sig;

SINR= sig./(intf+noise);
SINR_dB=10*log10(SINR);

end
