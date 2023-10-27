%% Credits
% Team #: 1
% Authors: Cooper White & Gian-Mateo Tifone
% Date: 10/5/2023

%% Initialization
clear
cie = loadCIEdata;   

%% Project 3 - Step 3
% Blackbody and CIE Standard Observer -Data

BB2856K = blackbody(2856, cie.lambda); %Illuminant A's   BB
BB5003K = blackbody(5003, cie.lambda); %Illuminant D50's BB
BB6504K = blackbody(6504, cie.lambda); %Illuminant D65's BB

% Find value to normalize
index = 37; %Index of the 560nm
ANormVal = cie.illA(index, 1);
D50NormVal = cie.illD50(index, 1);
D65NormVal = cie.illD65(index, 1);

% Normalize
illANormalized = cie.illA./ANormVal;
illD50Normalized = cie.illD50./D50NormVal;
illD65Normalized = cie.illD65./D65NormVal;

% Blackbody and CIE Standard Observer -Graphs
% x-axis
cie.lambda;

% Plot -> Blackbody 
figure(1);
hold on
plot(cie.lambda,BB2856K,'Color',[0,0,0],'LineWidth',1.5)
plot(cie.lambda,BB5003K,'Color',[1,0,0],'LineWidth',1.5)
plot(cie.lambda,BB6504K,'Color',[0,0,1],'LineWidth',1.5)

% Plot -> Standard Illuminants
plot(cie.lambda, illANormalized,  'Color',[0,0,0],'LineWidth',1.5,'LineStyle','--');
plot(cie.lambda, illD50Normalized,'Color',[1,0,0],'LineWidth',1.5,'LineStyle','--');
plot(cie.lambda, illD65Normalized,'Color',[0,0,1],'LineWidth',1.5,'LineStyle','--');
hold off

% Format plot(s)
title('blackbody and standard illuminant spectra')
xlabel('wavelength(nm)')
ylabel('relative power')
xlim([350 800]);
ylim([0 2.5]);
legend('Location', 'best') %Auto-places Legend 
legend('blackbody (2856K)','blackbody (5003K)', 'blackbody (6504K)', ...
       'illuminant A', 'illuminant D50', 'illuminant D65');

% Plot -> 2-Degree
figure(2);
hold on
plot(cie.lambda,cie.cmf2deg(:,1),'Color',[1,0,0],'LineWidth',1.5)
plot(cie.lambda,cie.cmf2deg(:,2),'Color',[0,1,0],'LineWidth',1.5)
plot(cie.lambda,cie.cmf2deg(:,3),'Color',[0,0,1],'LineWidth',1.5)

% Plot -> 10-Degree
plot(cie.lambda,cie.cmf10deg(:,1),'Color',[1,0,0],'LineWidth',1.5,'LineStyle','--')
plot(cie.lambda,cie.cmf10deg(:,2),'Color',[0,1,0],'LineWidth',1.5,'LineStyle','--')
plot(cie.lambda,cie.cmf10deg(:,3),'Color',[0,0,1],'LineWidth',1.5,'LineStyle','--')
hold off

% Format plot(s)
title('CIE standard observer CMFs')
xlabel('wavelength(nm)')
ylabel('tristimulus values')
xlim([350 800]);
ylim([0 2.5]);
legend('x_b_a_r 2 deg.','y_b_a_r 2 deg.', 'z_b_a_r 2 deg.', ...
       'x_b_a_r 10 deg.', 'y_b_a_r 10 deg.', 'z_b_a_r 10 deg.');

%% Project 3 - Step 4 
% This function takes Surface reflectance, Color Matching Function, Illumination and converts it to XYZ tristimulus values.
%   refs = Surface reflectance nx1 vector
%
%   cmfs = Color matching functions nx3 vector 
%          in [x,y,z] order
%
%   illum = SPD of light source nx1 vector
%
% <include>ref2XYZ.m</include>

%% Project 3 - Step 5
CC_spectra = importdata('ColorChecker_380_780_5nm.txt');
for patch_num = 2:25
CC_XYZs(:,patch_num-1) = ref2XYZ(CC_spectra(:,patch_num),cie.cmf2deg,cie.illD65);
end
CC_XYZs

% Plot ColorChecker
figure(3)
hold on
for patch = 1:size(CC_spectra, 2)-1
    plot(cie.lambda, CC_spectra(:, patch +1), 'Color',rand(1,3))
end

% Format Plot
title('reflectance spectra of ColorChecker chart patches')
xlabel('wavelength(nm)')
ylabel('reflectance factor')
xlim([350 800]);
ylim([0 1]);
hold off

%% Project 3 - Step 6
% This function takes an input XYZ - 3xn vector 
% and returns xyY - 3xn vector - chromaticity coordinates
%   XYZ = trustimulus values, vector
%   
%   x,y = chromaticity coordinates, vector
%
%   Y = Luminance factor
%
% <include>XYZ2xyY.m</include>

%% Project 3 - Step 7
CC_xyYs = XYZ2xyY(CC_XYZs);
CC_xyYs

% Lab 3 - Step 8
cm_lams=380:10:730;
cm_h_offset = 19;
% Import Data and Normalize to 1 - Patch 5.1
data=importdata('5.1_real.sp', ' ', cm_h_offset);
patch1.real = data.data/100;
cm_h_offset = 18;
data=importdata('5.1_imaged.sp', ' ', cm_h_offset);
patch1.imaged = data.data/100;
data=importdata('5.1_matching.sp', ' ', cm_h_offset);
patch1.matching = data.data/100;

% Import Data and Normalize to 1 - Patch 5.2
cm_h_offset = 19;
data=importdata('5.2_real.sp', ' ', cm_h_offset);
patch2.real = data.data/100;
cm_h_offset = 18;
data=importdata('5.2_imaged.sp', ' ', cm_h_offset);
patch2.imaged = data.data/100;
data=importdata('5.2_matching.sp', ' ', cm_h_offset);
patch2.matching = data.data/100;

%% Project 3 - Step 9
% Interpolation of Patch data
patch1.Ireal=interp1(cm_lams,patch1.real, cie.lambda(:), "linear", "extrap");
patch1.Iimaged=interp1(cm_lams,patch1.imaged,cie.lambda(:), "linear", "extrap");
patch1.Imatching=interp1(cm_lams,patch1.matching, cie.lambda(:), "linear", "extrap");
patch2.Ireal=interp1(cm_lams,patch2.real, cie.lambda(:), "linear", "extrap");
patch2.Iimaged=interp1(cm_lams,patch2.imaged,cie.lambda(:), "linear", "extrap");
patch2.Imatching=interp1(cm_lams,patch2.matching, cie.lambda(:), "linear", "extrap");

% Plot Figure 4
figure(4)
plot(cm_lams, patch1.real, 'o', 'Color', [1,0,0]);
hold on
plot(cm_lams, patch1.imaged,'o', 'Color', [0,1,0]);
plot(cm_lams, patch1.matching,'o', 'Color', [0,0,1]);
plot(cie.lambda,patch1.Ireal,'.', 'Color', [0,0,0]);
plot(cie.lambda,patch1.Iimaged,'.', 'Color', [0,0,0]);
plot(cie.lambda,patch1.Imatching,'.', 'Color', [0,0,0]);

% Format plot
title('patch 5.1 measured and interpolated data')
legend('real measured', 'imaged measured', 'matching measured', ...
    'real interpolated', 'imaged interpolated', 'matching interpolated', 'Location','best');
xlabel('wavelength(nm)')
ylabel('reflectance factor')
xlim([350 800]);
ylim([0 1]);
hold off

% Plot Figure 5
figure(5)
plot(cm_lams, patch2.real,'o', 'Color', [1,0,0]);
hold on
plot(cm_lams, patch2.imaged,'o', 'Color', [0,1,0]);
plot(cm_lams, patch2.matching,'o', 'Color', [0,0,1]);
plot(cie.lambda,patch2.Ireal,'.', 'Color', [0,0,0]);
plot(cie.lambda,patch2.Iimaged,'.', 'Color', [0,0,0]);
plot(cie.lambda,patch2.Imatching,'.', 'Color', [0,0,0]);
hold off

% Format Plot
title('patch 5.2 measured and interpolated data')
legend('real measured', 'imaged measured', 'matching measured', ...
    'real interpolated', 'imaged interpolated', 'matching interpolated', 'Location','best');
xlabel('wavelength(nm)')
ylabel('reflectance factor')
xlim([350 800]);
ylim([0 1]);
hold off

%% Project 3 - Step 10
%Calculated values for XYZ Patch 1
patch1.CalcrealXYZ = ref2XYZ(patch1.Ireal, cie.cmf2deg, cie.illD50);
patch1.CalcimagedXYZ = ref2XYZ(patch1.Iimaged, cie.cmf2deg, cie.illD50);
patch1.CalcmatchingXYZ = ref2XYZ(patch1.Imatching, cie.cmf2deg, cie.illD50);
%Calculated values for XYZ Patch 2
patch2.CalcrealXYZ = ref2XYZ(patch2.Ireal, cie.cmf2deg, cie.illD50);
patch2.CalcimagedXYZ = ref2XYZ(patch2.Iimaged, cie.cmf2deg, cie.illD50);
patch2.CalcmatchingXYZ = ref2XYZ(patch2.Imatching, cie.cmf2deg, cie.illD50);
%Reading in the ColorMunki XYZ data and assiging to struct
real_measuredXYZ = readmatrix('5_XYZ_Labs_Real.txt');
imaged_measuredXYZ = readmatrix('5_XYZ_Labs_imaged.txt');
matching_measuredXYZ = readmatrix('5_XYZ_Labs_matching.txt');

%Patch 1
patch1.CMreal = real_measuredXYZ(1,2:4);
patch1.CMimaged = imaged_measuredXYZ(1,2:4);
patch1.CMmatching = matching_measuredXYZ(1,2:4);
%Patch 2
patch2.CMreal = real_measuredXYZ(2,2:4);
patch2.CMimaged = imaged_measuredXYZ(2,2:4);
patch2.CMmatching = matching_measuredXYZ(2,2:4);

%Table 1 -Header
fprintf('%s\n\n',"Measured and calculated tristumulus values");
fprintf('%48s\n', "patch 5.1");
fprintf('%30s %37s\n', "measured", "calculated");
fprintf('%14s %12s %10s %12s %12s %10s\n', "X", "Y", "Z", "X", "Y", "Z");

%Table 1 -Data
fprintf('%8s %2.6f   %2.6f   %2.6f %s', 'real',patch1.CMreal, '   ');
fprintf('%2.6f   %2.6f   %2.6f\n', patch1.CalcrealXYZ);
fprintf('%8s %2.6f   %2.6f   %2.6f %s', 'imaged', patch1.CMimaged, '   ');
fprintf('%2.6f   %2.6f   %2.6f\n', patch1.CalcimagedXYZ);
fprintf('%8s %2.6f   %2.6f   %2.6f %s', 'matching', patch1.CMmatching,'   ');
fprintf('%2.6f   %2.6f   %2.6f\n\n\n', patch1.CalcmatchingXYZ);

%Table 2 -Header
fprintf('%48s\n', "patch 5.2");
fprintf('%30s %37s\n', "measured", "calculated");
fprintf('%14s %12s %10s %12s %12s %10s\n', "X", "Y", "Z", "X", "Y", "Z");

%Tabel 2 -Data
fprintf('%8s %2.6f   %2.6f   %2.6f %s', 'real',patch2.CMreal, '   ');
fprintf('%2.6f   %2.6f   %2.6f\n', patch2.CalcrealXYZ);
fprintf('%8s %2.6f   %2.6f   %2.6f %s', 'imaged', patch2.CMimaged, '   ');
fprintf('%2.6f   %2.6f   %2.6f\n', patch2.CalcimagedXYZ);
fprintf('%8s %2.6f   %2.6f   %2.6f %s', 'matching', patch2.CMmatching,'   ');
fprintf('%2.6f   %2.6f   %2.6f\n\n\n', patch2.CalcmatchingXYZ);

%% Project 3 - Step 11
%CMunki xyY patch 1
patch1.CMrealxyY=XYZ2xyY(patch1.CMreal');
patch1.CMimagedxyY = XYZ2xyY(patch1.CMimaged');
patch1.CMmatchingxyY = XYZ2xyY(patch1.CMmatching');
%CMunki xyY patch 2
patch2.CMrealxyY=XYZ2xyY(patch2.CMreal');
patch2.CMimagedxyY = XYZ2xyY(patch2.CMimaged');
patch2.CMmatchingxyY = XYZ2xyY(patch2.CMmatching');
%Calculated xyY patch 1
patch1.CalcrealxyY = XYZ2xyY(patch1.CalcrealXYZ');
patch1.CalcimagedxyY = XYZ2xyY(patch1.CalcimagedXYZ');
patch1.CalcmatchingxyY = XYZ2xyY(patch1.CalcmatchingXYZ');
%Calculated xyY patch 2
patch2.CalcrealxyY = XYZ2xyY(patch2.CalcrealXYZ');
patch2.CalcimagedxyY = XYZ2xyY(patch2.CalcimagedXYZ');
patch2.CalcmatchingxyY = XYZ2xyY(patch2.CalcmatchingXYZ');

% Table 1 -Header
fprintf('%s\n\n',"Measured and calculated tristumulus values");
fprintf('%48s\n', "patch 5.1");
fprintf('%30s %37s\n', "measured", "calculated");
fprintf('%13s %12s %10s %10s %12s %10s\n', "x", "y", 'Y', 'x', 'y', 'Y');

%Table 1 -Data
fprintf('%8s %2.6f   %2.6f   %2.6f %s', 'real', patch1.CMrealxyY, '   ');
fprintf('%2.6f   %2.6f   %2.6f\n', patch1.CalcrealxyY);
fprintf('%8s %2.6f   %2.6f   %2.6f %s', 'imaged', patch1.CMimagedxyY, '   ');
fprintf('%2.6f   %2.6f   %2.6f\n', patch1.CalcimagedxyY);
fprintf('%8s %2.6f   %2.6f   %2.6f %s', 'matching', patch1.CMmatchingxyY,'   ');
fprintf('%2.6f   %2.6f   %2.6f\n\n\n', patch1.CalcmatchingxyY);

%Table 2 -Header
fprintf('%48s\n', "patch 5.2");
fprintf('%30s %37s\n', "measured", "calculated");
fprintf('%13s %12s %10s %10s %12s %10s\n', "x", "y", 'Y', 'x', 'y', 'Y');

%Table 2 -Data
fprintf('%8s %2.6f   %2.6f   %2.6f %s', 'real', patch2.CMrealxyY, '   ');
fprintf('%2.6f   %2.6f   %2.6f\n', patch2.CalcrealxyY);
fprintf('%8s %2.6f   %2.6f   %2.6f %s', 'imaged', patch2.CMimagedxyY, '   ');
fprintf('%2.6f   %2.6f   %2.6f\n', patch2.CalcimagedxyY);
fprintf('%8s %2.6f   %2.6f   %2.6f %s', 'matching', patch2.CMmatchingxyY,'   ');
fprintf('%2.6f   %2.6f   %2.6f\n\n\n', patch2.CalcmatchingxyY);

%% Project 3 - Step 12
% Plot chromaticity skeleton
plot_chrom_diag_skel;

% Plot Patch 1
plot(patch1.CalcrealxyY(1,1),patch1.CalcrealxyY(2,1),'o','Color', [1,0,0], 'DisplayName', '5.1 real');
plot(patch1.CalcimagedxyY(1,1),patch1.CalcimagedxyY(2,1),'square','Color', [1,0,0], 'DisplayName', '5.1 imaged');
plot(patch1.CalcmatchingxyY(1,1),patch1.CalcmatchingxyY(2,1),'diamond','Color', [1,0,0], 'DisplayName', '5.1 matching');


% Plot Patch 2
plot(patch2.CalcrealxyY(1,1),patch2.CalcrealxyY(2,1),'o','Color', [0,0,1], 'DisplayName', '5.2 real');
plot(patch2.CalcimagedxyY(1,1),patch2.CalcimagedxyY(2,1),'square','Color', [0,0,1], 'DisplayName', '5.2 imaged');
plot(patch2.CalcmatchingxyY(1,1),patch2.CalcmatchingxyY(2,1),'diamond','Color', [0,0,1],'DisplayName', '5.2 imaged');

% Format Plot
title('Chromaticity Coordinates of 5.1 and 5.2 Patches')
legend({'', '', '','','','','','','','','','','','', ...
        '5.1 real', '5.1 imaged', '5.1 matching', ...
        '5.2 real', '5.2 imaged', '5.2 matching'}, ...
        'Location', 'northeast', 'FontSize',9) 

%% Feedback

% i.) 
% Cooper and Gian-Mateo both coded the project; Cooper and Gian-Mateo spend
% several adruous hours debugging together

% ii.) 
% We had to reference google for some fprintf tips, and for formatting the
% shapes of the points in our plots for interpolated vs real data. 

%iii.)
%Structs were QUITE valuable as it made our workspace more streamlined, and
%cut down on confusing variable notation

%iv.)
% no improvments needed, just took a while, and caffeine







