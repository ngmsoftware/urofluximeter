function [V, T] = processWebData(R)

vPos = find(R=='V');
vPos = vPos(1);
ePos = find(R=='E');
ePos = ePos(end);

R = R(vPos:ePos);

R(R=='V') = [];
R(R=='E') = [];
R(R==10) = [];
R(R==13) = ' ';

VT = sscanf(R,'%f');

V = VT(1:2:end)';
T = VT(2:2:end)';

end