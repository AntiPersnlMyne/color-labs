%% Credits
% Team #: 1 |
% Authors: Cooper White & Gian-Mateo Tifone |
% Date: 10/23/2023

%% Step 1 - Initialization
cie = loadCIEdata;  
load('loadPatchData.mat') % Read in patches
CCPNG = imread('chart.jpg'); % Read in Color checker PNG