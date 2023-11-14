%% Credits
% Team #: 1 |
% Authors: Cooper White & Gian-Mateo Tifone |
% Date: 11/02/2023

%% Step 1/2 - initilization 
clear; 

cie = loadCIEdata;
XYZ_D50 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD50);
XYZ_D65 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD65);

%% Step 3
load_ramps_data;

%% Step 4 - Forward Matrix
Red_max.X = max(ramp_R_XYZs(1, :)); %X_r,max
Red_max.Y = max(ramp_R_XYZs(2, :)); %Y_r,max
Red_max.Z = max(ramp_R_XYZs(3, :)); %Z_r,max

Green_max.X = max(ramp_G_XYZs(1, :)); %X_g,max
Green_max.Y = max(ramp_G_XYZs(2, :)); %Y_g,max
Green_max.Z = max(ramp_G_XYZs(3, :)); %Z_g,max

Blue_max.X = max(ramp_B_XYZs(1, :)); %X_g,max
Blue_max.Y = max(ramp_B_XYZs(2, :)); %Y_g,max
Blue_max.Z = max(ramp_B_XYZs(3, :)); %Z_g,max

% Create matrix of max
m_fwd = [Red_max.X, Green_max.X, Blue_max.X ;
         Red_max.Y, Green_max.Y, Blue_max.Y ;
         Red_max.Z, Green_max.Z, Blue_max.Z];

% Subtract the XYZ of display (XYZk)
m_fwd = m_fwd-XYZk;

% Add XYZk (black) collumn
m_fwd = cat(2, m_fwd, XYZk);

% Divide the XYZw value (Y)
m_fwd = m_fwd / XYZw(2, 1);

% Display Matrix
m_fwd

%% Step 5 - Derive the LUTs
RedRamp = ramp_R_XYZs - XYZk;   % XYZ of Red minus black 
GreenRamp = ramp_G_XYZs - XYZk; % XYZ of Green minus black 
BlueRamp = ramp_B_XYZs - XYZk;  % XYZ of BLue minus black 

RedRamp   = RedRamp   / XYZw(2, 1); % Divide XYZ by (Y) of white
GreenRamp = GreenRamp / XYZw(2, 1); % Divide XYZ by (Y) of white
BlueRamp  = BlueRamp  / XYZw(2, 1); % Divide XYZ by (Y) of white

% Clip out of bounds numbers
RedRamp(RedRamp<0)     = 0; % Less than 0 becomes 0
RedRamp(RedRamp>1)     = 1; % Greater than 1 becomes 1
GreenRamp(GreenRamp<0) = 0;
GreenRamp(GreenRamp>1) = 1;
BlueRamp(BlueRamp<0)   = 0;
BlueRamp(BlueRamp>1)   = 1;

% Estiamte Radiometric Scalars
m_fwd_inv = pinv(m_fwd(1:3,1:3)); % Calculate inverse matrix of 3x3 forward matrix

RedRampRS   = m_fwd_inv * RedRamp;   % Multiply XYZ by inverse forward matrix
GreenRampRS = m_fwd_inv * GreenRamp; % 
BlueRampRS  = m_fwd_inv * BlueRamp;  % 

% Extract the Red/Green/Blue channels from the RSs of each ramp
% I.e. Extract Red RS from RedRamp
%      Extract Green RS from GreenRamp
%      Extract Blue RS from BlueRamp
RedRampRS_R   = RedRampRS(1,:);
GreenRampRS_G = GreenRampRS(2,:);
BlueRampRS_B  = BlueRampRS(3,:);

% Interpolate channels from 0-255 using 'pchip'
ramp_DCs = round(linspace(0,255,11));

% Create LUT for Red/Green/Blue
RedLUT_fwd   = interp1(ramp_DCs, RedRampRS_R, 0:1:255, 'pchip');
GreenLUT_fwd = interp1(ramp_DCs, GreenRampRS_G, 0:1:255, 'pchip');
BlueLUT_fwd  = interp1(ramp_DCs, BlueRampRS_B, 0:1:255, 'pchip');

% Plot LUT
figure
hold on
plot(0:255, RedLUT_fwd,  'Color', [1, 0, 0])
plot(0:255, GreenLUT_fwd,'Color', [0, 1, 0])
plot(0:255, BlueLUT_fwd, 'Color', [0, 0, 1])

xlabel("Digital Counts RGB 0-255")
ylabel("Radiometrix Scalars RGB 0-1")
title("Forward Model LUTs")
ylim([0 1])
xlim([0 255])





