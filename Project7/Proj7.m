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
Camera.RGBNorm = importdata('CameraRGB.txt',' '); % Read in RGBs of CC image [3x24] [R;G;B]
% RGB's were calculated as averaged over a span of 255, meaning they're imported
% normalized to 255 [RGB/255 built in]

%b)
Camera.RGBNorm = Camera.RGBNorm * 100; % Turn to double, divide by 255, multiply 100
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
uncal_CC.XYZw = mean(uncal_XYZs.data(25:27,5:7));  % Extract Whitepoint
uncal_CC.XYZk = mean(uncal_XYZs.data(28:30,5:7));  % Extract Blackpoitn

%h) Calculate Lab values
uncal_CC.Lab = XYZ2Lab(uncal_CC.XYZ', uncal_CC.XYZw');

%i) Load the real Colormuki values
load("loadMunkiData");

%j) Calculate differences between Real patch and displayed Patch
dEabLab = deltaEab(Munki.Lab, uncal_CC.Lab);

%k) Print differences
print_uncalibrated_workflow_error(Munki.Lab, uncal_CC.Lab, dEabLab)





