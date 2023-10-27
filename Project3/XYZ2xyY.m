%%
% This function takes an input XYZ - 3xn vector 
% and returns xyY - 3xn vector - chromaticity coordinates
%   XYZ = trustimulus values, vector
%   
%   x,y = chromaticity coordinates, vector
%
%   Y = Luminance factor
%
% <include>XYZ2xyY.m</include>

function xyY = XYZ2xyY(XYZ)
X = XYZ(1, :);
Y = XYZ(2, :);
Z = XYZ(3, :);

x = X ./ (X+Y+Z);
y = Y ./ (X+Y+Z);

xyY = [x;y;Y];
end