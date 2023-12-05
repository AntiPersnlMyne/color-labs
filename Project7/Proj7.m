%% Credits
% Team #: 1 |
% Authors: Cooper White & Gian-Mateo Tifone |
% Date: 12/xx/2023

%% Step 1 - Initialize
clear
disp("Certifiable Jim Moment", newline)

%% Step 2 - Import Camera Data
%a)
cie = loadCIEdata;
Camera.RGB = importdata('CameraRGB.txt',' '); % Read in RGBs of CC image [3x24] [R;G;B]
% RGB's were calculated as averaged over a span of 255, meaning they're imported
% normalized to 255 [RGB/255 built in]

%b)
Camera.RGBNorm = Camera.RGB * 100; % Turn to double, divide by 255, multiply 100
Camera.RGBNorm = uint8(Camera.RGBNorm); % convert back to uint8

%c) Creating the table4ti1 matrix
table4ti1 = ones(30, 4);
table4ti1(:, 1) = 1:30;
table4ti1(1:24, 2:4) = Camera.RGBNorm';
table4ti1(25:27, 2:4) = 0;
table4ti1(28:30, 2:4) = 100;

%d) Made workflow_test_uncal.ti1
%e) used ColorMunki and made workflow_uncal_test.ti3
%f) create data structure that contains the displayed XYZs
%g) Extract XYZ, whitepoint, blackpoint
uncal_XYZs = importdata('workflow_test_uncal.ti3',' ',20);

uncal_CC.XYZ = uncal_XYZs.data(1:24,5:7);          % Extract XYZs of color
uncal_CC.XYZk = mean(uncal_XYZs.data(25:27,5:7));  % Extract Whitepoint
uncal_CC.XYZw = mean(uncal_XYZs.data(28:30,5:7));  % Extract Blackpoint

%h) Calculate Lab values
uncal_CC.Lab = XYZ2Lab(uncal_CC.XYZ', uncal_CC.XYZw');

%i) Load the real Colormuki values
load("loadMunkiData");

%j) Calculate differences between Real patch and displayed Patch
dEabLab = deltaEab(Munki.Lab, uncal_CC.Lab);

%k) Print differences
print_uncalibrated_workflow_error(Munki.Lab, uncal_CC.Lab, dEabLab)

%% Step 2 - Calibrated Workflow

%a) Camera.RGBNorm - Same as Step 1.a
Camera.RGB;

%b) Put our Camera's RGB thru RGB2XYZ
CalCamera.XYZ = camRGB2XYZ('cam_model.mat', Camera.RGB);

%c) 
CalCamera.XYZn_D50 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD50);
CalCamera.RGB_DC = XYZ2dispRGB('display_model.mat',CalCamera.XYZ,CalCamera.XYZn_D50);

%d)
CalCamera.RGBNorm = double(CalCamera.RGB_DC) * 100/255;
CalCamera.RGBNorm = uint8(CalCamera.RGBNorm);

%e) Creating the table4ti1 matrix - But for step 2
%   NOTE: Does override the table in step 1
table4ti1 = ones(30, 4);
table4ti1(:, 1) = 1:30;
table4ti1(1:24, 2:4) = CalCamera.RGBNorm';
table4ti1(25:27, 2:4) = 0;
table4ti1(28:30, 2:4) = 100;

%f) Make "workflow_test_cal.ti1

%g) Use colormunki - dispread -P 1,0,2 -v workflow_test_cal
% ~ ~ ~ ~ ~ ~ ~ ~
% PLEASE DO THIS, I DONT HAVE YOUR DISPLAY
% ~ ~ ~ ~ ~ ~ ~ ~ 

%h) Load the measured XYZs
cal_XYZs = importdata('workflow_test_cal.ti3',' ',20);

%i) Extract XYZ data
cal_CC.XYZ = cal_XYZs.data(1:24,5:7);          % Extract XYZs of color
cal_CC.XYZk = mean(cal_XYZs.data(25:27,5:7));  % Extract Whitepoint
cal_CC.XYZw = mean(cal_XYZs.data(28:30,5:7));  % Extract Blackpoint

%j) Calculate Lab values
cal_CC.Lab = XYZ2Lab(cal_CC.XYZ', cal_CC.XYZw');

%k) Load the real Colormuki values - Previously done
%load("loadMunkiData");

%l) Calculate differences between Real patch and displayed Patch
dEabLab = deltaEab(Munki.Lab, cal_CC.Lab);

%m) Print differences
print_calibrated_workflow_error(Munki.Lab, cal_CC.Lab, dEabLab)

    
%% Step 3 - Visualize the differences 
% ... Between ground-truth, uncalibrated, and calibrated renderings
% of the ColorChecker chart

%a) Load the real Colormuki values - Previously done
%load("loadMunkiData");

%b) Use "cform" to calculate RGB from XYZ
% ~
% This is what I WOULD use, but seemingly 'xyz2srgb' no longer exists in
% MATLAB R2023b. I'd love to be proven wrong.
%xyz2rgb_form = makecform('xyz2srgb');
%Munki.RGB = applycform(xyz2rgb_form, Munki.XYZ)
% ~
% This is what the documentation says to use instead
Munki.RGB = xyz2rgb(Munki.XYZ'); % Default is sRGB

%c)
Munki.RGB = uint8(Munki.RGB * 255)';
% RGBs are given 0-1 by the function

%d) Create workflow diffs
% Uncalibrated: Camera.RGB
% Calibrated: CalCamera.RGB_DC
% Ground-truth: Munki.RGB

G_truth = flip ( imrotate( reshape(Munki.RGB', [6 4 3]), 90 ) );
Uncalibrated = uint8 ( flip ( imrotate( reshape(Camera.RGB', [6 4 3]), 90 ) ) * 255 );
Calibrated = flip ( imrotate( reshape(CalCamera.RGB_DC', [6 4 3]), 90 ) );

% Array to reform - Convert to uint8 to be read 0-255
workflow = uint8(ones(8, 12, 3));

% Ground Truth
workflow(1:2:7, 1:2:11, :) = G_truth;
workflow(1:2:7, 2:2:12, :) = G_truth;

% Uncalibrated
workflow(2:2:8, 1:2:11, :) = Uncalibrated;

% Calibrated
workflow(2:2:8, 2:2:12, :) = Calibrated;

% Show image
figure
image(workflow)

