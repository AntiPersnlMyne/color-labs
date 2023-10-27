%% Credits
% Team #: 1 |
% Authors: Cooper White & Gian-Mateo Tifone |
% Date: 10/23/2023

%% Step 1 - Initialization
clear
cie = loadCIEdata;  

%% Step 2 - Setup ref2XYZ
% This function takes Surface reflectance, Color Matching Function, Illumination and converts it to XYZ tristimulus values.
%   refs = Surface reflectance nx1 vector
%
%   cmfs = Color matching functions nx3 vector 
%          in [x,y,z] order
%
%   illum = SPD of light source nx1 vector
%
% <include>ref2XYZ.m</include>

%% Step 3 - Test ref2XYZ
spectra.CC = load('ColorChecker_380-780-5nm.txt');
CC_Light.XYZs.D65 = ref2XYZ(spectra.CC(:,2:25),cie.cmf2deg,cie.illD65);

CC_Light.XYZs.D65

%% Step 4 - Setup XYZ2Lab
% This function takes XYZ tristimulus values and XYZn tristimulus values (of reference illuminant)
% and converts it to L*a*b*
%
%   XYZ  = Tristimulus values 3xn vector
%          3xn vector, [X;Y;Z]
%
%   XYZn = Tristimulus values (of ref. illuminant)
%          3x1 vector [X;Y;Z]
%
% <include>XYZ2Lab.m</include>

%% Step 5 - Test XYZ2Lab
% Calculate XYZn values
CC_Light.XYZn.D65 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD65);

% Calculate Lab values
CC_Light.Lab.D65 = XYZ2Lab(CC_Light.XYZs.D65, CC_Light.XYZn.D65);

% The name of each patch in the Macbeth Color Checker
names = textread('ColorChecker_names.txt','%s','delimiter','|'); %#ok<DTXTRD>


% TABLE - Header
fprintf('%s', 'ColorChecker XYZ and Lab values (D65 illuminant and 2 deg. observer)', newline, newline)
fprintf('%s %4s %8s %8s %8s %8s %8s %14s\n', 'Patch #', 'X', 'Y', 'Z', 'L*', 'a*', 'b*', 'Patch Name')

% TABLE - Body
fspec = '%5.0f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %s %2s\n';
for patchnum = 1:size(CC_Light.Lab.D65,2)
%          format     1       X,Y,Z       L,a,b      Patch name
    fprintf(fspec, patchnum, CC_Light.XYZs.D65(1, patchnum), CC_Light.XYZs.D65(2,patchnum), CC_Light.XYZs.D65(3,patchnum), CC_Light.Lab.D65(1,patchnum), CC_Light.Lab.D65(2,patchnum), CC_Light.Lab.D65(3,patchnum),' ', names{patchnum,1}) % Prints each Patch's XYZ + LAB 
end

%% Step 6 - Darker CC Spectra
% Darker CC Spectra
CC_Dark.XYZs.D65 = CC_Light.XYZs.D65*0.02;

% Dark L*a*b* values
CC_Dark.Lab.D65 = XYZ2Lab(CC_Dark.XYZs.D65, CC_Light.XYZn.D65);


fprintf('%s', 'ColorChecker (Dark) XYZ and Lab values (D65 illuminant and 2 deg. observer)', newline, newline);
fprintf('%s %4s %8s %8s %8s %8s %8s %14s\n', 'Patch #', 'X', 'Y', 'Z', 'L*', 'a*', 'b*', 'Patch Name')

% TABLE - Body
fspec = '%5.0f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %s %2s\n';
for patchnum = 1:size(CC_Light.Lab.D65,2)
%          format     1       X,Y,Z       L,a,b      Patch name
    fprintf(fspec, patchnum, CC_Dark.XYZs.D65(1, patchnum), CC_Dark.XYZs.D65(2,patchnum), CC_Dark.XYZs.D65(3,patchnum), CC_Dark.Lab.D65(1,patchnum), CC_Dark.Lab.D65(2,patchnum), CC_Dark.Lab.D65(3,patchnum),' ', names{patchnum, 1}) % Prints each Patch's XYZ + LAB 
end

%% Step 7 - Setup deltaEab
% Takes 2 sets of Lab and converts them to Delta Eab values
%
%  Lab is a 3xn matrix
%
%  DEab is a 1xn matrix
%
% <include>deltaEab.m</include>

%% Step 8 - Test deltaEab
spectra.MC = load('MetaChecker_380-780-5nm.txt');
% Use 'spectra.' struct for spectra data

% Calculate XYZ for MC, both under illA and illD65
MC_Light.XYZs.D65 = ref2XYZ(spectra.MC(:,2:25),cie.cmf2deg,cie.illD65);
MC_Light.XYZs.A   = ref2XYZ(spectra.MC(:,2:25),cie.cmf2deg,cie.illA);

% Calculate XYZn for MC, both under illA and illD65
MC_Light.XYZn.D65 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD65);
MC_Light.XYZn.A   = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illA);

% Calculate LAB for MC, both under illA and illD65
MC_Light.Lab.D65 = XYZ2Lab(MC_Light.XYZs.D65, MC_Light.XYZn.D65);
MC_Light.Lab.A   = XYZ2Lab(MC_Light.XYZs.A  , MC_Light.XYZn.A)  ;


% Calculate XYZs for CC, both under illA and illD65
CC_Light.XYZs.D65; %Already made
CC_Light.XYZs.A = ref2XYZ(spectra.CC(:,2:25),cie.cmf2deg,cie.illA);

% Calculate XYZn for CC, both under illA and illD65
CC_Light.XYZn.D65; %Already made
CC_Light.XYZn.A = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illA);

% Calculate LAB for CC, under illA and illD65
CC_Light.Lab.D65; %Already made
CC_Light.Lab.A = XYZ2Lab(CC_Light.XYZs.A,CC_Light.XYZn.A);

% Calculate DEab(65) and DEab(A)
DEab.D65 = deltaEab(MC_Light.Lab.D65, CC_Light.Lab.D65); %DEab - D65
DEab.A   = deltaEab(MC_Light.Lab.A,   CC_Light.Lab.A)  ; %DEab - A

% TABLE - Header
fprintf('%s', "ColorChecker and Metachecker color differences", newline, newline);
fprintf('%s %10s %11s\n', "Patch #", "DEab(D65)", "DEab(illA)");

% TABLE - Body
fspec = '%7.0f %10.3s %7.3f\n';

for patchnum = 1:size(DEab.A, 2)
    fprintf(fspec, patchnum, DEab.D65(1, patchnum), DEab.A(1, patchnum));
end

%% Step 9 - Calculated, LAB, DeltaE

% ~Code imported from Proj3~
CalcPatchData;

% Calculate XYZn for D50
CC_Light.XYZn.D50 = ref2XYZ(cie.PRD,cie.cmf2deg,cie.illD50);

% Calculated values for LAB Patch 1
patch1.CalcrealLab = XYZ2Lab(patch1.CalcrealXYZ, CC_Light.XYZn.D50);
patch1.CalcimagedLab = XYZ2Lab(patch1.CalcimagedXYZ, CC_Light.XYZn.D50);
patch1.CalcmatchingLab = XYZ2Lab(patch1.CalcmatchingXYZ, CC_Light.XYZn.D50);

% Calculated values for LAB Patch 2
patch2.CalcrealLab = XYZ2Lab(patch2.CalcrealXYZ, CC_Light.XYZn.D50);
patch2.CalcimagedLab = XYZ2Lab(patch2.CalcimagedXYZ, CC_Light.XYZn.D50);
patch2.CalcmatchingLab = XYZ2Lab(patch2.CalcmatchingXYZ, CC_Light.XYZn.D50);

% Patch1 DEab
%                                    Patch 1 real        Patch 1 imaged
patch1.DEab.real_imaged   = deltaEab(patch1.CalcrealLab, patch1.CalcimagedLab)  ; 
%                                    Patch 1 real        Patch 1 matching
patch1.DEab.real_matching = deltaEab(patch1.CalcrealLab, patch1.CalcmatchingLab);

% Patch2 DEab
%                                    Patch 2 real        Patch 2 imaged
patch2.DEab.real_imaged   = deltaEab(patch2.CalcrealLab, patch2.CalcimagedLab)  ; 
%                                    Patch 2 real        Patch 2 matching
patch2.DEab.real_matching = deltaEab(patch2.CalcrealLab, patch2.CalcmatchingLab);

% TABLE 5.1 - Header
fprintf('%s\n\n',"Calculated XYZ, Lab, and deltaE values (w.r.t. real patches)");
fprintf('%48s\n', "patch 5.1");
fprintf('%13s %9s %9s %10s %9s %9s %9s\n', "X", "Y", "Z", "L", "a", "b", "dEab");

% TABLE 5.1 - Body
fprintf('%8s %2.4f   %2.4f   %2.4f %s', 'real',patch1.CalcrealXYZ, '   ');
fprintf('%2.4f   %2.4f   %2.4f\n', patch1.CalcrealLab);
fprintf('%8s %2.4f   %2.4f   %2.4f %s', 'imaged', patch1.CalcimagedXYZ, '   ');
fprintf('%2.4f   %2.4f   %2.4f %s %2.4f\n', patch1.CalcimagedLab, ' ', patch1.DEab.real_imaged);
fprintf('%8s %2.4f   %2.4f   %2.4f %s', 'matching', patch1.CalcmatchingXYZ,'   ');
fprintf('%2.4f   %2.4f   %2.4f %s %2.4f\n\n\n', patch1.CalcmatchingLab, ' ', patch1.DEab.real_matching);


% TABLE 5.2 - Header
fprintf('%48s\n', "patch 5.2");
fprintf('%13s %9s %9s %10s %9s %8s %9s\n', "X", "Y", "Z", "L", "a", "b", "dEab");

% TABLE 5.2 - Body
fprintf('%8s %2.4f   %2.4f   %2.4f %s', 'real',patch2.CalcrealXYZ, '   ');
fprintf('%2.4f   %2.4f   %2.4f\n', patch2.CalcrealLab);
fprintf('%8s %2.4f   %2.4f   %2.4f %s', 'imaged', patch2.CalcimagedXYZ, '   ');
fprintf('%2.4f   %2.4f   %2.4f %s %2.4f\n', patch2.CalcimagedLab, ' ', patch2.DEab.real_imaged);
fprintf('%8s %2.4f   %2.4f   %2.4f %s', 'matching', patch2.CalcmatchingXYZ,'   ');
fprintf('%2.4f %8.4f   %2.4f %s %2.4f\n\n\n', patch2.CalcmatchingLab, ' ', patch2.DEab.real_matching);

%% Step 10 - Visualize Color Differences
figure(1)
hold on
% Plot Patch 1
plot(patch1.CalcrealLab(2,1),patch1.CalcrealLab(3,1)        ,'o'      ,'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'MarkerSize', 4, 'DisplayName', '5.1 real');
plot(patch1.CalcimagedLab(2,1),patch1.CalcimagedLab(3,1)    ,'square' ,'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'MarkerSize', 4, 'DisplayName', '5.1 imaged');
plot(patch1.CalcmatchingLab(2,1),patch1.CalcmatchingLab(3,1),'diamond','MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'MarkerSize', 4, 'DisplayName', '5.1 matching');

% Plot Patch 2
plot(patch2.CalcrealLab(2,1),patch2.CalcrealLab(3,1)        ,'o'      ,'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'MarkerSize', 4, 'DisplayName', '5.2 real');
plot(patch2.CalcimagedLab(2,1),patch2.CalcimagedLab(3,1)    ,'square' ,'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'MarkerSize', 4, 'DisplayName', '5.2 imaged');
plot(patch2.CalcmatchingLab(2,1),patch2.CalcmatchingLab(3,1),'diamond','MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'MarkerSize', 4, 'DisplayName', '5.2 matching');

% Draw viscircles
% Requires the "Image Processing Toolbox" Add-on to be installed
% [x1 , Y1]
% [x2 , y2]
% radius 2.5, as that's the average of 2-3 DEab JND's
viscircles([patch1.CalcrealLab(2,1), patch1.CalcrealLab(3,1) ; ...
            patch2.CalcrealLab(2,1), patch2.CalcrealLab(3,1)], ...
            2.5, 'Color', 'k', LineWidth=.7);

% Format plot
axis square %So the circles look like circles
grid on     %Add gridlines
xlabel('a*')
ylabel('b*')
xticks(-60:10:60)
yticks(-60:10:60)
xlim([-60 60]);
ylim([-60 60]);
legend({'5.1 real', '5.1 imaged', '5.1 matching', ...
        '5.2 real', '5.2 imaged', '5.2 matching'}, ...
        'Location', 'southeast', 'FontSize',9) 

%% Feedback
% i)
% Gian-Mateo wrote the functions. Cooper and Gian-Mateo coded the lab. 
%
% ii)
% The largest 'setbacks' were optimizing the XYZ2Lab function without
% for-loops. Also, having to reinstall MATLAB for the "Image Processing
% Toolbox" - which wouldn't otherwise install.
%
% iii)
% Focusing on how to fully utilize MATLAB, i.e. without for loops, focusing
% on matrix operations. Also, embedding structs within structs.
%
% iv)
% Reintroducing, or delaying, the introduction of Matrix operations (such
% as calling items at an array indexes + how MATLAB interprets 1 as "True"
% when knowing where to call an index) closer to Projects 3 and 4
