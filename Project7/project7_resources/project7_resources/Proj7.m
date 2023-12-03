%% Credits
% Team #: 1 |
% Authors: Cooper White & Gian-Mateo Tifone |
% Date: 11/02/2023

%% Step 1 - Initialize
clear
disp("Hello Jim :D", newline)

%% Step 2 - Import Camera Data
cie = loadCIEdata;
Camera.RGBNorm = importdata('CameraRGB.txt',' '); % Read in RGBs of CC image [3x24] [R;G;B]
% RGB's were calculated as averaged over a span of 255, meaning they're imported
% normalized to 255

%b)
Camera.RGBNorm = double(Camera.RGBNorm*100); % turn to double --> mult by 100
Camera.RGBNorm = round(Camera.RGBNorm); % round back to uint8

%c) Creating the table4ti1 matrix
table4ti1 = ones(30, 4);
table4ti1(:, 1) = 1:30;
table4ti1(1:24, 2:4) = Camera.RGBNorm';
table4ti1(25:27, 2:4) = 0;
table4ti1(28:30, 2:4) = 100;

%d) made workflow_test_uncal.ti1

%e) used ColorMunki and made workflow_uncal_test.ti3

%f) Extratcing data structure that contains the displayed XYZs
uncal_XYZs = importdata('workflow_test_uncal.ti3',' ',20);

%g) Creating data structure for XYZ data of displayed CC Patches
uncal_CC.XYZ = uncal_XYZs.data(1:24,5:7);
uncal_CC.XYZw = mean(uncal_XYZs.data(25:27,5:7));
uncal_CC.XYZk = mean(uncal_XYZs.data(28:30,5:7));





