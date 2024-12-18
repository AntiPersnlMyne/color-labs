%% Credits
% Team #: 1 |
% Authors: Cooper White & Gian-Mateo Tifone |
% Date: 11/02/2023

%% Step 1 - Initialize
clear
disp("Hello Jim :D", newline)

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
ylim([.1 1.0])

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
%                      Only gray RS, flipped B->W
plot (Munki.grayNormY, flip(Camera.RS(:, 19:24), 2), 'LineWidth', 1);
title("Linearized Grayscale Y to RGB Relationship")
xlabel("Munki Gray Y's")
ylabel("Linearized Camera Gray RGBs (RSs)")
colororder(["r", "g", "b"]) % Plot Red, Green, then Blue lines

%% Step 8 - Plot the Color Checker Pre/Post Linearized

% Original camera RGBs
pix = reshape(Camera.RGBNorm', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flip(pix, 2);
figure;
image(pix);
title("Original camera patch RGBs")

% Linearized camera RGBs
pix = reshape(Camera.RS', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flip(pix, 2);
figure;
image(pix);
title("Linearized camera patch RGBs")

%% Step 9 - Estimate XYZ from RSs
camMatrix3x3 = Munki.XYZ * pinv(Camera.RS)

%% Step 10 - Estimate XYZ of CC
Camera.XYZ = camMatrix3x3 * Camera.RS; % [3x24]
Camera.XYZ

%% Step 11 - Create a camera model + analyze error

% Part a
Camera.XYZn_D50 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD50); % calculating XYZn of D50 
Camera.Lab = XYZ2Lab(Camera.XYZ, Camera.XYZn_D50);         % calulates Lab values of CC  
% Worth noting, MATLAB might be insisting here on using its own XYZ2lab instead of ours

% Part b
dEab = deltaEab(Munki.Lab,Camera.Lab); % dEab measured from CC Labs and imaged CC Labs

% Part c
% Print table of L*a*b*'s - Munki and Camera-calculated
print_camera_model_error(Munki.Lab, Camera.Lab, dEab);  

%% Step 12 - Improved Camera Model with Non-Linear Relationships 

% Part a
RSrgb = Camera.RS;
RS_r = RSrgb(1,:);
RS_g = RSrgb(2,:);
RS_b = RSrgb(3,:);

RSrgb_extd = [RSrgb; RS_r.*RS_g; RS_r.*RS_b; RS_g.*RS_b; RS_r.*RS_g.*RS_b;
              RS_r.^2; RS_g.^2; RS_b.^2; ones(1,size(RSrgb,2))];

% Part b
camMatrix3x11 = Munki.XYZ * pinv(RSrgb_extd);

% Print result
camMatrix3x11

%% Step 13 - estimate XYZs from RGB and RS
Camera.XYZ = camMatrix3x11 * RSrgb_extd;
Camera.XYZ

%% Step 14 - Evaluate accuracy of Camera Model
% Calulates L*a*b* values of Camera XYZ (under D50)
Camera.Lab = XYZ2Lab(Camera.XYZ, Camera.XYZn_D50); 
% delta Eab of measured Munki L*a*b* and Camera L*a*b*
dEab = deltaEab(Munki.Lab,Camera.Lab);             

% Print table
print_extended_camera_model_error(Munki.Lab, Camera.Lab, dEab); 

%% Step 15 - Save Extended Camera Model
save('cam_model.mat', 'CameraPolys', 'camMatrix3x11');

%% Step 16 - Camera XYZ from improved model
%
% <include>camRGB2XYZ.m</include>

% Take raw camera RGBs and convert to XYZs using a camera model
Camera.XYZ = camRGB2XYZ('cam_model.mat', Camera.RGBNorm);
Camera.XYZ

%% Step 17 - Visualize the munki-measured XYZs as an sRGB image
Camera.XYZn_D65 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD65);

% Jim Code ~
% Visualize the Munki XYZs in sRGB color space

%                           Munki XYZ      D50             D65
Munki.XYZ_D65 = catBradford(Munki.XYZ,Camera.XYZn_D50,Camera.XYZn_D65);
% sRGB of Munki's XYZ 
Munki.sRGB = XYZ2sRGB(Munki.XYZ_D65);
pix = reshape(Munki.sRGB', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flip(pix, 2);
figure;
image(pix);
title("Munki XYZs chromatically adapted and visualized in sRGB")

% Visualize the camera-estimated XYZs in sRGB color space
%                            Camera XYZ       D50             D65
Camera.XYZ_D65 = catBradford(Camera.XYZ,Camera.XYZn_D50,Camera.XYZn_D65);
% sRGB of Camera's XYZ 
Camera.sRGB = XYZ2sRGB(Camera.XYZ_D65);
pix = reshape(Camera.sRGB', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flip(pix, 2);
figure;
image(pix);
title("Estimated XYZs chromatically adapted and visualized in sRGB")

%% Feedback 
% 
% Cooper & Gian-Mateo coded the lab, the work was even distributed and we
% debugged together :) 
% The only major problem we ran into was our original jpg file having some
% discoloration. So, we retook our pictures. 
% Parts of this lab that were important to us included the ability to
% easily compare the colors that we had generated, also recognizing that we
% can feed functions .mat files was cool. 