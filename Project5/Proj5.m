%% Credits
% Team #: 1 |
% Authors: Cooper White & Gian-Mateo Tifone |
% Date: 10/23/2023

%% Step 1 - Initialize
clear

%% Step 2 - Import CC 
cie = loadCIEdata;  
load('loadPatchData.mat')                    % Read in patches
camRGB.RGB = importdata('cam_RGBs.txt',' '); % Read in RGBs of CC image  [3x24]
camRGB.normRGB = camRGB.RGB / 255;           % Normalize RGBs            [3x24]

% Filter out greys
% 19-24th patches
camRGB.grays = camRGB.normRGB(:, 19:24);
% Flip greys
camRGB.grays = flip(camRGB.grays, 2); % Already normalized

MunkiData.data = importdata('munki_CC_XYZs_Labs.txt','\t'); % Read in Munki XYZ and LAB  [24x7]
MunkiData.XYZ = MunkiData.data(:, 2:4)'; % Munki XYZ [3x24]
MunkiData.Lab = MunkiData.data(:, 5:7)'; % Munki LAB [3x24]

MunkiData.grayY = MunkiData.XYZ(2,19:24);   % Only Gray Y's of Munki XYZ [1x6]

MunkiData.normGrayY = MunkiData.grayY / 100; % Normalize Y's
MunkiData.normGrayY = flip(MunkiData.normGrayY, 2); % Flip Y's

%% Step 5 - Plot Grayscale Y vs RGB
figure
plot (MunkiData.normGrayY, camRGB.grays, 'LineWidth', 1);
title("Original grayscale Y to RGB relationship")
xlabel("Munki gray Y's")
ylabel("Camera gray RGBs")
xlim([0 .9])
ylim([.1 .9])

%% Step 6 - Linearize RGB resposne

r=1;g=2;b=3;

% Fits low-order polynomial functions between normalized camera RGBs and
% munki-measured gray Ys
camPolys(r,:) = polyfit(camRGB.grays(r,:), MunkiData.normGrayY, 3);
camPolys(g,:) = polyfit(camRGB.grays(g,:), MunkiData.normGrayY, 3);
camPolys(b,:) = polyfit(camRGB.grays(b,:), MunkiData.normGrayY, 3);

% Linearize the camera data
camRGB.RS(r,:) = polyval(camPolys(r,:), camRGB.normRGB(r, :));
camRGB.RS(g,:) = polyval(camPolys(g,:), camRGB.normRGB(g, :));
camRGB.RS(b,:) = polyval(camPolys(b,:), camRGB.normRGB(b, :));

% Fix out of range values
camRGB.RS(camRGB.RS<0) = 0;
camRGB.RS(camRGB.RS>1) = 1;

%% Step 7 - Plot RS Scalars vs RGBs
figure
%                          Only the gray, flipped B->W
plot (MunkiData.normGrayY, flip(camRGB.RS(:, 19:24), 2), ...
    'LineWidth', 1);
title("Linearized Grayscale Y to RGB Relationship")
xlabel("Munki Gray Y's")
ylabel("Linearized Camera Gray RGBs (RSs)")

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
camMatrix3x3 = MunkiData.XYZ * pinv(camRGB.RS)

%% Step 10 - Estimate XYZ of CC

camRGB.XYZs = camMatrix3x3 * camRGB.RS % [3x24]
camRGB.XYZs

%% Step 11 - Camera Model Error
camRGB.XYZ_D50 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD50); % calculating XYZn of D50 
camRGB.Lab = XYZ2Lab(camRGB.XYZs, camRGB.XYZ_D50); % calulates Lab values of CC  
dEab = deltaEab(MunkiData.Lab,camRGB.Lab) %delta Eab of measured CC Labs and imaged CC Labs
print_camera_model_error(MunkiData.Lab, camRGB.Lab, dEab);

%% Step 12 - Non-Linear Relationships!

RSrgbs = camRGB.RS;
RSrs = RSrgbs(1,:);
RSgs = RSrgbs(2,:);
RSbs = RSrgbs(3,:);


RSrgbs_extd = [RSrgbs; RSrs.*RSgs; RSrs.*RSbs; RSgs.*RSbs; RSrs.*RSgs.*RSbs; RSrs.^2; RSgs.^2; RSbs.^2; ones(1,size(RSrgbs,2))];

camMatrix3x11 = MunkiData.XYZ * pinv(RSrgbs_extd);
% Print camMatrix3x11
camMatrix3x11

%% Step 13 estimate XYZs from RGB RSs
camRGB.XYZs = camMatrix3x11 * RSrgbs_extd;
camRGB.XYZs

%% Step 14 

camRGB.Lab = XYZ2Lab(camRGB.XYZs, camRGB.XYZ_D50); % calulates Lab values of CC  
dEab = deltaEab(MunkiData.Lab,camRGB.Lab); %delta Eab of measured CC Labs and imaged CC Labs
print_extended_camera_model_error(MunkiData.Lab, camRGB.Lab, dEab);

%% Step 15 - Save Extended Camera Model
save('cam_model.mat', 'camPolys', 'camMatrix3x11');

%% Step 16 - cam_XYZs
%
% <include>camRGB2XYZ.m</include>

% Take raw camera RGBs and convert to XYZs
camRGB.XYZ.XYZ = camRGB2XYZ('cam_model.mat', camRGB.RGB);
camRGB.XYZ.XYZ

%% Step 17 - Visualize the munki-measured XYZs as an sRGB image
camRGB.XYZ_D65 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD65);
MunkiData.XYZD65 = catBradford(MunkiData.XYZ,camRGB.XYZ_D50,camRGB.XYZ_D65);
MunkiData.sRGBs = XYZ2sRGB(MunkiData.XYZD65);
pix = reshape(camRGB.RS', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flip(pix, 2);
figure;
image(pix);
title("Munki XYZs chromatically adapted and visualized in sRGB")

% 
camRGB.XYZ.D65 = catBradford(MunkiData.XYZ,camRGB.XYZ_D50,camRGB.XYZ_D65);
camRGB.XYZ.sRGBs = XYZ2sRGB(camRGB.XYZ.D65);
pix = reshape(camRGB.RS', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = flip(pix, 2);
figure;
image(pix);
title("Estimated XYZs chromatically adapted and visualized in sRGB")

