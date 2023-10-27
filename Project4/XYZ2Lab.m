function Lab = XYZ2Lab(XYZ, XYZn)
% Calculate Ratios, the 'x' to be compared in the Piecewise function
Ratios = XYZ ./ XYZn; 

% Define anonymous functions, the parts of the Piecewise function
Cond1 = @(x) x.^(1/3)        ; %x > 0.008856 
Cond2 = @(x) 7.787*x + 16/116; %x ≤ 0.008856

% Apply operations of Piecewise
cond1Index = Ratios > 0.008856             ;
Ratios(cond1Index)  = Cond1(Ratios(cond1Index)) ;
Ratios(~cond1Index) = Cond2(Ratios(~cond1Index));

% Calculate L*a*b*
L = 116*Ratios(2,:)-16             ;
a = 500*(Ratios(1,:) - Ratios(2,:));
b = 200*(Ratios(2,:) - Ratios(3,:));

Lab = [L;a;b];
end