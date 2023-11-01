%% Credits
% Team #: 1 |
% Authors: Cooper White & Gian-Mateo Tifone |
% Date: 11/xx/2023

%% Step 1 - Initialize
clear
%disp("Hello Jim :D", newline)

%% Step 2 - Import CC 
cie = loadCIEdata;
Camera.RGBNorm = importdata('CameraRGB.txt',' '); % Read in RGBs of CC image [3x24] [R;G;B]
% RGB's were calculated as averaged over a span of 255, meaning they're imported
% normalized to 255

%% Step 3 - Filter out Camera's gray and flip
% Filter out grays
Camera.gray = Camera.RGBNorm(:, 19:24); % 19-24th patches
% Flip grays
Camera.gray = flip(Camera.gray, 2); % Black -> White

%% Step 4 - Import Munki LAB and XYZ
% Part a
Munki.data = importdata('munki_CC_XYZs_Labs.txt','\t'); % Read in Munki XYZ and LAB  [24x7]
Munki.XYZ = Munki.data(:, 2:4)';                        % Munki XYZ [3x24]
Munki.Lab = Munki.data(:, 5:7)';                        % Munki LAB [3x24]

% Part b
Munki.grayY = Munki.XYZ(2,19:24);           % Only Gray Y's of Munki XYZ [1x6]
Munki.grayNormY = Munki.grayY / 100;        % Normalize Y's 
Munki.grayNormY = flip(Munki.grayNormY, 2); % Flip Y's

%% Step 5 - Plot Grayscale Y vs RGB
figure
plot (Munki.grayNormY, Camera.gray, 'LineWidth', 1);
title("Original grayscale Y to RGB relationship")
xlabel("Munki gray Y's")
ylabel("Camera gray RGBs")
colororder(["r", "g", "b"]) % Plot Red, Green, then Blue lines
xlim([0 .9])
ylim([.1 .9])

%% Step 6 - Linearize RGB resposne
% Part a
r=1;g=2;b=3;

% Fits low-order (x^3) polynomial functions between normalized grey patch's RGBs and
% munki-measured gray Ys
%   Ployfit returns the coefficients for a polynomial p(x) of degree n that is a best fit
CameraPolys(r,:) = polyfit(Camera.gray(r,:), Munki.grayNormY, 3); % Polys -Red   line
CameraPolys(g,:) = polyfit(Camera.gray(g,:), Munki.grayNormY, 3); % Polys -Green line
CameraPolys(b,:) = polyfit(Camera.gray(b,:), Munki.grayNormY, 3); % Polys -Blue  line

% Part b
% Linearize camera's response to the ColorChecker patches
%   Polyval evaluates a polynomial (Some p(x)) at certain x values, and
%   retuns the result 
%    Each index of P[#, #, #] is the coeffecient of the polynomial
%    Each index of x[#, #, #] is the polynomial to be evaluated
Camera.RS(r,:) = polyval(CameraPolys(r,:), Camera.RGBNorm(r, :)); % All Patches -Red
Camera.RS(g,:) = polyval(CameraPolys(g,:), Camera.RGBNorm(g, :)); % All Patches -Green
Camera.RS(b,:) = polyval(CameraPolys(b,:), Camera.RGBNorm(b, :)); % All Patches -Blue

% Part c
% Fix out of range values
Camera.RS(Camera.RS<0) = 0;
Camera.RS(Camera.RS>1) = 1;

%% Step 7 - Plot RS Scalars vs RGBs
figure
%                      Only the gray, flipped B->W
plot (Munki.grayNormY, flip(Camera.RS(:, 19:24), 2), 'LineWidth', 1);
title("Linearized Grayscale Y to RGB Relationship")
xlabel("Munki Gray Y's")
ylabel("Linearized Camera Gray RGBs (RSs)")
colororder(["r", "g", "b"]) % Plot Red, Green, then Blue lines

%% Step 8 - Plot the Color Checker Pre/Post Linearized
% Original camera RGBs
pix = reshape(camRGB.normRGB', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flip(pix, 2);
figure;
image(pix);
title("Original camera patch RGBs")

% Linearized camera RGBs
pix = reshape(camRGB.RS', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flip(pix, 2);
figure;
image(pix);
title("Linearized camera patch RGBs")

%% Step 9 - Estimate XYZ from RSs
camMatrix3x3 = Munki.XYZ * pinv(camRGB.RS)

%% Step 10 - Estimate XYZ of CC

camRGB.XYZs = camMatrix3x3 * camRGB.RS % [3x24]
camRGB.XYZs

%% Step 11 - Camera Model Error
camRGB.XYZ_D50 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD50); % calculating XYZn of D50 
camRGB.Lab = XYZ2Lab(camRGB.XYZs, camRGB.XYZ_D50); % calulates Lab values of CC  
dEab = deltaEab(Munki.Lab,camRGB.Lab) %delta Eab of measured CC Labs and imaged CC Labs
print_camera_model_error(Munki.Lab, camRGB.Lab, dEab);

%% Step 12 - Non-Linear Relationships!

RSrgbs = camRGB.RS;
RSrs = RSrgbs(1,:);
RSgs = RSrgbs(2,:);
RSbs = RSrgbs(3,:);


RSrgbs_extd = [RSrgbs; RSrs.*RSgs; RSrs.*RSbs; RSgs.*RSbs; RSrs.*RSgs.*RSbs; RSrs.^2; RSgs.^2; RSbs.^2; ones(1,size(RSrgbs,2))];

camMatrix3x11 = Munki.XYZ * pinv(RSrgbs_extd);
% Print camMatrix3x11
camMatrix3x11

%% Step 13 estimate XYZs from RGB RSs
camRGB.XYZs = camMatrix3x11 * RSrgbs_extd;
camRGB.XYZs

%% Step 14 

camRGB.Lab = XYZ2Lab(camRGB.XYZs, camRGB.XYZ_D50); % calulates Lab values of CC  
dEab = deltaEab(Munki.Lab,camRGB.Lab); %delta Eab of measured CC Labs and imaged CC Labs
print_extended_camera_model_error(Munki.Lab, camRGB.Lab, dEab);

%% Step 15 - Save Extended Camera Model
save('cam_model.mat', 'CameraPolys', 'camMatrix3x11');

%% Step 16 - cam_XYZs
%
% <include>camRGB2XYZ.m</include>

% Take raw camera RGBs and convert to XYZs
camRGB.XYZ.XYZ = camRGB2XYZ('cam_model.mat', camRGB.RGB);
camRGB.XYZ.XYZ

%% Step 17 - Visualize the munki-measured XYZs as an sRGB image
camRGB.XYZ_D65 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD65);
Munki.XYZD65 = catBradford(Munki.XYZ,camRGB.XYZ_D50,camRGB.XYZ_D65);
Munki.sRGBs = XYZ2sRGB(Munki.XYZD65);
pix = reshape(camRGB.RS', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flip(pix, 2);
figure;
image(pix);
title("Munki XYZs chromatically adapted and visualized in sRGB")

% 
camRGB.XYZ.D65 = catBradford(Munki.XYZ,camRGB.XYZ_D50,camRGB.XYZ_D65);
camRGB.XYZ.sRGBs = XYZ2sRGB(camRGB.XYZ.D65);
pix = reshape(camRGB.RS', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flip(pix, 2);
figure;
image(pix);
title("Estimated XYZs chromatically adapted and visualized in sRGB")

