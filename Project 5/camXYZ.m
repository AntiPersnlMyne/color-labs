function camXYZ = camRGB2XYZ(camModel, camRGB)
% Takes Camera Model and Camera RGBs and converts them to XYZ values
%  
%   camModel = .mat variable file
%    camPolys
%    camMatrix3x11
%
%   camRGB   = vector of RGBs [3xn]

% Normalize
camRGB = camRGB/255;

% Radiometric Scalar 
camRGB.RS(r,:) = polyval(camPolys(r,:), camRGB.normRGB(r, :));
camRGB.RS(g,:) = polyval(camPolys(g,:), camRGB.normRGB(g, :));
camRGB.RS(b,:) = polyval(camPolys(b,:), camRGB.normRGB(b, :));

% Fix out of range values
camRGB.RS(camRGB.RS<0) = 0;
camRGB.RS(camRGB.RS>1) = 1;

% 12a
RSrgbs = camRGB.RS;
RSrs = RSrgbs(1,:);
RSgs = RSrgbs(2,:);
RSbs = RSrgbs(3,:);

RSrgbs_extd = [RSrgbs; RSrs.*RSgs; RSrs.*RSbs; RSgs.*RSbs; RSrs.*RSgs.*RSbs; RSrs.^2; RSgs.^2; RSbs.^2; ones(1,size(RSrgbs,2))];

% Estimate XYZs from RGB RSs
camXYZ = camMatrix3x11 * RSrgbs_extd;
end