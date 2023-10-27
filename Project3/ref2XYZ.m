%%
% This function takes Surface reflectance, Color Matching Function, Illumination and converts it to XYZ tristimulus values.
%   refs = Surface reflectance nx1 vector
%
%   cmfs = Color matching functions nx3 vector 
%          in [x,y,z] order
%
%   illum = SPD of light source nx1 vector
%
% <include>ref2XYZ.m</include>

%                      R(λ)  x,y,z  S(λ)
function XYZ = ref2XYZ(refs, cmfs,  illum)
% Normalize for each illuminant
k = 100./(cmfs(:,2)'*illum);

% Calculate XYZ values
XYZ = k.*cmfs'*diag(illum)*refs;
end