%                      R(λ)  x,y,z  S(λ)
function XYZ = ref2XYZ(refs, cmfs,  illum)
k = 100 / sum(cmfs(:, 2).*illum);
X = k * sum(cmfs(:, 1).*illum.*refs);
Y = k * sum(cmfs(:, 2).*illum.*refs);
Z = k * sum(cmfs(:, 3).*illum.*refs);
XYZ = [X;Y;Z];
end