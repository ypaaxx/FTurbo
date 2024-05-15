function Res = artikel_3b_S_func(varargin)


argc = nargin + 1;
if argc == 1
    varargin =  split("-dir C:\Users\fura\Documents -c_3m 0.9 -Ht 0.972 -i 0 -tau 1.0 -k 1.12 -m 1.0");
    argc = length(split(varargin));
end

disp(varargin);

c_3a = 0.5;
H_t = 0.3;
Re = 2e5;
tauS = 1.5;
c = 0.1;
Rk = 0.35;
omega = 2000 * pi/30;
m_f = 1;
K_S = 1.12;
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
            K_S = str2double(varargin{count});
        case "-tau"
            tauS = str2double(varargin{count});
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
attackS = attack;
m_f = sqrt(m_f);

Uk = omega*(Rk);
folder = Directory;

%% Начало цикла
c_2a = c_3a/m_f;
c_2u = -H_t;
c_2 = sqrt(c_2u^2+c_2a^2);
alfa_2 = atan(c_2u/c_2a);
alfa_3_inv = atan((1-K_S)*c_2u/c_3a);

%tauR = tau_BS2(d_betta, betta_2);
%tauS = tau_BS2(-alfa_2, alfa_3);

%%
AVDR = [m_f^0 m_f^0 m_f m_f];

a = [0  0.1046    0.3138    0.5229];

a_ = linspace(a(1), a(end), 200);
r_ = ones(size(a_));
h_ = interp1(a, 1./AVDR, a_, "linear");

surfS = Surface(r_, h_, a_);

%%
foilS = MerdnlFoil(c, 42, 0.14, 0.33, 0.2);
foilS.setStator(1);
foilS.dXa = a(2);
foilS.setTau(tauS);
foilS.setSurface(surfS);

%%
stop = 0;
stop_count = 10;
while (stop ~= 1)&&(stop_count > 0)
    a_old = foilS.z_lange();
    Re_s  = Uk*(Rk)*foilS.b_ *c_2 /1.545e-5;
    kS = Re/Re_s;
    da = foilS.z_lange()/foilS.b_/kS;
    a = cumsum([0 1 da 1])*foilS.b_*kS;
    a_ = linspace(a(1), a(end), 200);
    h_ = interp1(a, 1./AVDR, a_, "linear");

    foilS.Z = round(foilS.Z/kS);
    surfS = Surface(r_, h_, a_);
    foilS.setSurface(surfS);
    foilS.dXa = a(2);
    foilS.design(c_2a, alfa_2, alfa_3_inv, 'attack_choice', 0, 'attack', attackS);
    stop = abs(1-foilS.z_lange()/a_old) < 0.01;
    stop_count = stop_count - 1;
end

%%
if (~isdeployed)
    fig1 = figure();
    hold on;
    axis equal;
    xticks(sort(a));
    xticklabels({'z=0', '3', '4', '5'});
    grid on;
    xlim([a(1), a(end)]);

    coordS = foilS.getCoordinates;
    coordS_y = coordS(:,2);
    coordS_z = coordS(:,3);
    plot(coordS_z, coordS_y);

    drawnow
end
%%
save(folder + "/data.m");
%% Вырисовать модели для CFX
Rk = 0.35; % meter

h = h_*foilS.b_*Rk*0.03;
r = r_;
a = a_;

coordS = foilS.getCoordinates("export");
coordS(:,2) = -coordS(:,2);
subfolder = folder;

%mkdir(subfolder);
%dlmwrite([subfolder, 'r.sldcrv'], [(r_)' zeros(size(a_')) a_']*Rk, 'delimiter', ' ', 'precision', 10);
%dlmwrite([subfolder, 'rUp.sldcrv'], [(r_+h_/2.*cos(gamma))' zeros(size(a_')) (a_-h_/2.*sin(gamma))']*Rk, 'delimiter', ' ', 'precision', 10);
%dlmwrite([subfolder, 'rDown.sldcrv'], [(r_-h_/2.*cos(gamma))' zeros(size(a_')) (a_+h_/2.*sin(gamma))']*Rk, 'delimiter', ' ', 'precision', 10);

dlmwrite(subfolder + "/shroud.crv", [(r+h/2)' zeros(size(a'))  (a)']*Rk, 'delimiter', ' ', 'precision', 10);
dlmwrite(subfolder + "/hub.crv", [(r-h/2)' zeros(size(a'))  (a)']*Rk, 'delimiter', ' ', 'precision', 10);

%dlmwrite([subfolder, 'profile.sldcrv'], coordR*Rk, 'delimiter', ' ', 'precision', 10);
%dlmwrite([subfolder, 'profile.sldcrv'], coordR(1,:)*Rk, '-append', 'delimiter', ' ', 'precision', 10);
%dlmwrite([subfolder, 'foilS.sldcrv'], coordS*Rk, 'delimiter', ' ', 'precision', 10);
%dlmwrite([subfolder, 'foilS.sldcrv'], coordS(1,:)*Rk, '-append', 'delimiter', ' ', 'precision', 10);

dlmwrite(subfolder + "/profile.crv", '# 1', 'delimiter', ' ', 'precision', 10);
dlmwrite(subfolder + "/profile.crv", [coordS(:,1)*(1-0.05*foilS.b_) coordS(:,2)*(1-0.05*foilS.b_) coordS(:,3)]*Rk, '-append', 'delimiter', ' ', 'precision', 10);
dlmwrite(subfolder + "/profile.crv", '# 2', '-append','delimiter', ' ', 'precision', 10);
dlmwrite(subfolder + "/profile.crv", [coordS(:,1)*(1+0.05*foilS.b_) coordS(:,2)*(1+0.05*foilS.b_) coordS(:,3)]*Rk, '-append', 'delimiter', ' ', 'precision', 10);

%dlmwrite([subfolder, 'foilS' 'z' num2str(foilS.Z) '.crv'], '# 1', 'delimiter', ' ', 'precision', 10);
%dlmwrite([subfolder, 'foilS' 'z' num2str(foilS.Z) '.crv'], coordS*Rk - [0.05,0,0]*Rk, '-append', 'delimiter', ' ', 'precision', 10);
%dlmwrite([subfolder, 'foilS' 'z' num2str(foilS.Z) '.crv'], '# 2', '-append','delimiter', ' ', 'precision', 10);
%dlmwrite([subfolder, 'foilS' 'z' num2str(foilS.Z) '.crv'], coordS*Rk + [0.05,0,0]*Rk, '-append', 'delimiter', ' ', 'precision', 10);

dlmwrite(subfolder + "/data.txt", ['Z stator: ' num2str(foilS.Z)] , '-append', 'delimiter', '');

c_2 = sqrt((tan(foilS.res.alfa1)*foilS.res.c1m)^2 + foilS.res.c1m^2);
Re_st = Uk*(Rk)*foilS.b_*c_2/1.545e-5;

dlmwrite(subfolder + "/data.txt", ['Re stator: ' num2str(Re_st, '%.2e')] , '-append', 'delimiter', '');

dlmwrite(subfolder + "/Inf.inf", '!======  FTurbo  ========', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", 'Axis of Rotation: Z' , '-append', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", ['Number of Blade Sets: ' num2str(foilS.Z)] , '-append', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", 'Coordinate System Orientation: Righthanded' , '-append', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", 'Geometry Units: M' , '-append', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", 'Hub Data File: hub.crv' , '-append', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", 'Shroud Data File: shroud.crv' , '-append', 'delimiter', '');
dlmwrite(subfolder + "/Inf.inf", 'Profile Data File: profile.crv' , '-append', 'delimiter', '');

disp(subfolder);
Res = 0;
end