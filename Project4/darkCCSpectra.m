function [darkXYZ = darkCCSpectra(XYZ, XYZn)
% Function takes CC Spectra - XYZ, XYZn, Lab - and multiples them by 0.02
% Returns [ XYZ  ]
%         [ XYZn ]

% Multiply all spectra
XYZ  = XYZ *0.02;
XYZn = XYZn*0.02;

% Return multipled XYZ and XYZn into a single matrix
darkXYZ = []
end