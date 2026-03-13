clc;
clear;
close all;

area = input('Enter simulation area limit (e.g. 100 for -100 to 100): ');
step = input('Enter grid resolution (e.g. 1 meter): ');

Pt = input('Enter transmit power (e.g. 100): ');
Gt = input('Enter transmitter gain (e.g. 1): ');
Gr = input('Enter receiver gain (e.g. 1): ');

n = input('Enter path loss exponent (1.5 - 3 recommended): ');

num_tx = input('Enter number of transmitters: ');

tx = zeros(1,num_tx);
ty = zeros(1,num_tx);

for i = 1:num_tx
    fprintf('Enter coordinates for transmitter %d\n',i);
    tx(i) = input('X position: ');
    ty(i) = input('Y position: ');
end

%% 2.  2D GRID

x = -area:step:area;
y = -area:step:area;

[X,Y] = meshgrid(x,y);


Pr_total = zeros(size(X));


for i = 1:num_tx
    
    d = sqrt((X - tx(i)).^2 + (Y - ty(i)).^2);
    
    d(d==0) = 1;
    
    Pr = Pt * Gt * Gr ./ (d.^n);
    
    Pr_total = max(Pr_total, Pr);
end


Pr_dB = 10*log10(Pr_total);


Pr_dB = Pr_dB - max(Pr_dB(:));


Pr_dB = imgaussfilt(Pr_dB,2);

figure
imagesc(x,y,Pr_dB)
axis xy
colorbar
colormap(jet)
caxis([-80 0])

title('Signal Coverage Heatmap')
xlabel('X Position (m)')
ylabel('Y Position (m)')
hold on

plot(tx,ty,'wo','MarkerSize',10,'LineWidth',2)


figure
contour(X,Y,Pr_dB,20,'LineWidth',1.5)
colormap(jet)
colorbar
grid on
hold on

plot(tx,ty,'ro','MarkerSize',10,'LineWidth',2)

title('2D Contour Plot of Signal Strength')
xlabel('X Position (m)')
ylabel('Y Position (m)')


figure
surf(X,Y,Pr_dB)

shading interp
colormap(jet)
colorbar

title('3D Signal Coverage Surface')
xlabel('X Position (m)')
ylabel('Y Position (m)')
zlabel('Signal Strength (dB)')

hold on

plot3(tx,ty,zeros(size(tx)),'ro','MarkerSize',10,'LineWidth',2)

view(45,40)
grid on