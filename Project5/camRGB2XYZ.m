function camXYZ = camRGB2XYZ(camModel, camRGB)
% Takes Camera Model and Camera RGBs and converts them to XYZ values
%  
%   camModel = .mat variable file
%    camPolys
%    camMatrix3x11
%
%   camRGB   = vector of RGBs [3xn]

% Import .mat variables
load(camModel)

% Normalize
camRGB = camRGB/255;

% Radiometric Scalar 
r=1;g=2;b=3;
camRGB_RS(r,:) = polyval(camPolys(r,:), camRGB(r, :));
camRGB_RS(g,:) = polyval(camPolys(g,:), camRGB(g, :));
camRGB_RS(b,:) = polyval(camPolys(b,:), camRGB(b, :));

% Fix out of range values
camRGB_RS(camRGB_RS<0) = 0;
camRGB_RS(camRGB_RS>1) = 1;

% 12a
RSrgbs = camRGB_RS;
RSrs = RSrgbs(1,:);
RSgs = RSrgbs(2,:);
RSbs = RSrgbs(3,:);

RSrgbs_extd = [RSrgbs; RSrs.*RSgs; RSrs.*RSbs; RSgs.*RSbs; RSrs.*RSgs.*RSbs; RSrs.^2; RSgs.^2; RSbs.^2; ones(1,size(RSrgbs,2))];

% Estimate XYZs from RGB RSs
camXYZ = camMatrix3x11 * RSrgbs_extd;
end