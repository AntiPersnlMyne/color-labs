function camXYZ = camRGB2XYZ(camModel, camRGB)
% Takes Camera Model and Camera RGBs and converts them to XYZ values
%  
%   camModel = .mat variable file
%    CameraPolys
%    camMatrix3x11
%
%   camRGB   = vector of RGBs [3xn]
%
%   camXYZ   = vector of XYZs [3xn]

% Import .mat variables
load(camModel)

% Calculate Radiometric Scalars
r=1;g=2;b=3;
Camera_RS(r,:) = polyval(CameraPolys(r,:), camRGB(r, :)); % All Patches -Red
Camera_RS(g,:) = polyval(CameraPolys(g,:), camRGB(g, :)); % All Patches -Green
Camera_RS(b,:) = polyval(CameraPolys(b,:), camRGB(b, :)); % All Patches -Blue

% Fix out-of-bounds values
Camera_RS(Camera_RS<0) = 0;
Camera_RS(Camera_RS>1) = 1;

% Calculate Extended RS RGBs
RSrgb = Camera_RS;
RS_r = RSrgb(1,:);
RS_g = RSrgb(2,:);
RS_b = RSrgb(3,:);

RSrgb_extd = [RSrgb; RS_r.*RS_g; RS_r.*RS_b; RS_g.*RS_b; RS_r.*RS_g.*RS_b;
              RS_r.^2; RS_g.^2; RS_b.^2; ones(1,size(RSrgb,2))];

% Estimate/Calculate XYZs
camXYZ = camMatrix3x11 * RSrgb_extd;
end