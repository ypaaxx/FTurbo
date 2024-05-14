function Res = artikel_3b_R_func(varargin)

argc = nargin + 1;
if argc == 1
    varargin =  "-dir C:\Users\fura\Documents -c_3m 0.5 -Ht 0.3 -i 0 -tau 1.0 -k 1.12 -m 1.0";
    argc = length(split(varargin));
end

disp(varargin);

c_3a = 0.5;
H_t = 0.3;
Re = 4e5;
tauR = 1.5;
c = 0.1;
Rk = 0.35;
omega = 2000 * pi/30;
m_f = 1;
K_R = 1.12;
attack = 0;

for count = 2:2:argc
    switch varargin{count-1} 
        case "-c_3m"
            c_3a = str2double(varargin(count));
        case "-dir"
                Directory = string(varargin(count));
        case "-Ht"
            H_t = str2double(varargin{count});
        case "-m"
            m_f = str2double(varargin{count});
        case "-k"
            K_R = str2double(varargin{count});
        case "-tau"
            tauR = str2double(varargin{count});
        case "-i"
            attack = str2double(varargin{count});
        case "-c"
            c = str2double(varargin{count});
        case "-Re"
            Re = str2double(varargin{count});
        case "-Rk"
            Rk = str2double(varargin{count});
        case "-rpm"
            omega = str2double(varargin{count}) * pi/30;
        case "-n1"
            n1 = str2double(varargin{count});
        case "-n2"
            n2 = str2double(varargin{count});
        otherwise
            error("err");
    end
end

attackR = attack;
Uk = omega*(Rk);
folder = Directory;

%%

c_2a = c_3a/m_f;
c_1a = c_2a/m_f;
c_1u = 0;
c_2u = -H_t;
w_1 = sqrt((1+c_1u)^2+c_1a^2);
alfa_1 = 0;
alfa_2_inv = atan(c_2u*K_R/c_2a);
%tauR = tau_BS2(d_betta, betta_2);

%%
AVDR = [m_f^0 m_f^0 m_f m_f];

a = [-0.4631   -0.2539   -0.1046    0];
a_ = linspace(a(1), a(end), 200);

r_ = ones(size(a_));
h_ = interp1(a, 1./AVDR, a_, "linear");

surfR = Surface(r_, h_, a_);

%% Инициировать
foilR = MerdnlFoil(c, 37, 0.04, 1.3, 0.2);

foilR.setStator(0);
foilR.setTau(tauR);
foilR.setSurface(surfR);

%%
stop = 0;
stop_count = 10;

while (stop ~= 1)&&(stop_count > 0) % подогнать хорду лопатки под область
    a_old = foilR.z_lange();
    Re_r  = Uk*(Rk)*foilR.b_ *w_1 /1.545e-5;
    kR = Re/Re_r;
    da = foilR.z_lange()/foilR.b_/kR;
    a = cumsum([0 1 da 1])*foilR.b_*kR;
    a = a - a(end);
    a_ = linspace(a(1), a(end), 200);
    h_ = interp1(a, 1./AVDR, a_, "linear");

    foilR.Z = round(foilR.Z/kR);
    surfR = Surface(r_, h_, a_);
    foilR.setSurface(surfR);
    foilR.dXa = a(2);
    foilR.design(c_1a, alfa_1, alfa_2_inv, 'attack_choice', 0, 'attack', attackR);
    stop = abs(1-foilR.z_lange()/a_old) < 0.01;
    stop_count = stop_count - 1;
end

%%
if (~isdeployed)
    fig1 = figure();
    hold on;
    axis equal;
    xticks(sort(a));
    xticklabels({'0', '1', '2', 'z=0', '3', '4', '5'});
    grid on;
    xlim([a(1), a(end)]);
    coordR = foilR.getCoordinates;
    coordR_y = coordR(:,2);
    coordR_z = coordR(:,3);
    plot(coordR_z, -coordR_y);
    drawnow
end
%%
save(folder + "/data.m");

%% Вырисовать модели для CFX
Rk = 0.35; % meter

h = h_*foilR.b_*Rk*0.03;
r = r_;
a = a_;
coordR = foilR.getCoordinates("export");
subfolder = folder;
%mkdir(subfolder);
% dlmwrite(subfolder + "r.sldcrv", [(r)' zeros(size(a')) a']*Rk, 'delimiter', ' ', 'precision', 10);
% dlmwrite(subfolder + "rUp.sldcrv", [(r+h/2)' zeros(size(a')) (a-h/2)']*Rk, 'delimiter', ' ', 'precision', 10);
% dlmwrite(subfolder + "rDown.sldcrv", [(r-h/2)' zeros(size(a')) (a+h/2)']*Rk, 'delimiter', ' ', 'precision', 10);

dlmwrite(subfolder + "/shroud.crv", [(r+h/2)' zeros(size(a'))  (a)']*Rk, 'delimiter', ' ', 'precision', 10);
dlmwrite(subfolder + "/hub.crv", [(r-h/2)' zeros(size(a'))  (a)']*Rk, 'delimiter', ' ', 'precision', 10);

%dlmwrite([subfolder, 'profile.sldcrv'], coordR*Rk, 'delimiter', ' ', 'precision', 10);
%dlmwrite([subfolder, 'profile.sldcrv'], coordR(1,:)*Rk, '-append', 'delimiter', ' ', 'precision', 10);
%dlmwrite([subfolder, 'foilS.sldcrv'], coordS*Rk, 'delimiter', ' ', 'precision', 10);
%dlmwrite([subfolder, 'foilS.sldcrv'], coordS(1,:)*Rk, '-append', 'delimiter', ' ', 'precision', 10);

dlmwrite(subfolder + "/profile.crv", '# 1', 'delimiter', ' ', 'precision', 10);
dlmwrite(subfolder + "/profile.crv", [coordR(:,1)*(1-0.05*foilR.b_) coordR(:,2)*(1-0.05*foilR.b_) coordR(:,3)]*Rk, '-append', 'delimiter', ' ', 'precision', 10);
dlmwrite(subfolder + "/profile.crv", '# 2', '-append','delimiter', ' ', 'precision', 10);
dlmwrite(subfolder + "/profile.crv", [coordR(:,1)*(1+0.05*foilR.b_) coordR(:,2)*(1+0.05*foilR.b_) coordR(:,3)]*Rk, '-append', 'delimiter', ' ', 'precision', 10);

dlmwrite(subfolder + "/data.txt", ['Z rotor: ' num2str(foilR.Z)], 'delimiter', '');

w_1 = sqrt((tan(foilR.res.betta1)*foilR.res.c1m)^2 + foilR.res.c1m^2);
Re_r  = Uk*(Rk)*foilR.b_ *w_1 /1.545e-5;

dlmwrite(subfolder + "/data.txt", ['Re rotor: ' num2str(Re_r,'%.2e')] , '-append', 'delimiter', '');

dlmwrite(subfolder + "/Inf.inf", '!======  FTurbo  ========', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", 'Axis of Rotation: Z' , '-append', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", ['Number of Blade Sets: ' num2str(foilR.Z)] , '-append', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", 'Coordinate System Orientation: Righthanded' , '-append', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", 'Geometry Units: M' , '-append', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", 'Hub Data File: hub.crv' , '-append', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", 'Shroud Data File: shroud.crv' , '-append', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", 'Profile Data File: profile.crv' , '-append', 'delimiter', '');

disp(subfolder);

Res = 0;
end