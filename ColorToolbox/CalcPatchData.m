%% CalcPatchData
% Calculates structs:
%    patch1
%    patch2
%
% Saves structs to textfile called "CalcPatchData.txt".
% This script only needs to be run *ONCE*, the data is written to the
% .txt file to load in from. Only run the script again if the
% "CalcPatchData.txt" file is missing.
% Avoids having to do lengthy calculations every run, as seen in Proj4.
%
% GM - 10/27/23

% Import Data and Normalize to 1 - Patch 5.1
cm_h_offset = 19;
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

% Interpolation of Patch data
cm_lams=380:10:730;
patch1.Ireal=interp1(cm_lams,patch1.real, cie.lambda(:), "linear", "extrap");
patch1.Iimaged=interp1(cm_lams,patch1.imaged,cie.lambda(:), "linear", "extrap");
patch1.Imatching=interp1(cm_lams,patch1.matching, cie.lambda(:), "linear", "extrap");
patch2.Ireal=interp1(cm_lams,patch2.real, cie.lambda(:), "linear", "extrap");
patch2.Iimaged=interp1(cm_lams,patch2.imaged,cie.lambda(:), "linear", "extrap");
patch2.Imatching=interp1(cm_lams,patch2.matching, cie.lambda(:), "linear", "extrap");

%Calculated values for XYZ Patch 1
patch1.CalcrealXYZ = ref2XYZ(patch1.Ireal, cie.cmf2deg, cie.illD50);
patch1.CalcimagedXYZ = ref2XYZ(patch1.Iimaged, cie.cmf2deg, cie.illD50);
patch1.CalcmatchingXYZ = ref2XYZ(patch1.Imatching, cie.cmf2deg, cie.illD50);
%Calculated values for XYZ Patch 2
patch2.CalcrealXYZ = ref2XYZ(patch2.Ireal, cie.cmf2deg, cie.illD50);
patch2.CalcimagedXYZ = ref2XYZ(patch2.Iimaged, cie.cmf2deg, cie.illD50);
patch2.CalcmatchingXYZ = ref2XYZ(patch2.Imatching, cie.cmf2deg, cie.illD50);

% Save relavant data to textfile
save("CalculatedPatchData.mat", "patch2", "patch1")