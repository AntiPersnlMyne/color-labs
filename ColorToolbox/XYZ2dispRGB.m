function munki_CC_DC = XYZ2dispRGB(display_model, XYZ, XYZn)
% display_model = display_model.mat file
% XYZ [3xn]     = XYZ valeus of CC patches
% XYZn [3x1]    = Whitepoint / Reference white

load("display_model");

% Step c - Adapt XYZ under D50 -> XYZ under Display's whitepoint
catXYZ = catBradford(XYZ, XYZn, XYZw_display);

% Step d - Subtract the black level
catXYZ = catXYZ - XYZk_display;

% Step e - Multiply XYZ by the Display to produce RS
%               [3x3]     [3x24]    
munki_CC_RS = M_Display * catXYZ;

% Step f
munki_CC_RS = munki_CC_RS/100;

% Step g
munki_CC_RS(munki_CC_RS<0) = 0;
munki_CC_RS(1<munki_CC_RS) = 1;

% Step h
munki_CC_RS = round(munki_CC_RS*1023 + 1);

% Step i
munki_CC_DC(1,:) = RLUT_display(munki_CC_RS(1,:));
munki_CC_DC(2,:) = GLUT_display(munki_CC_RS(2,:));
munki_CC_DC(3,:) = BLUT_display(munki_CC_RS(3,:));

% Convert to uint8
uint8(munki_CC_DC);
end