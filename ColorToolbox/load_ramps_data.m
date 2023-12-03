% load_ramps_data.m

% parse the ramps_plus.ti3 file and load the measured XYZ data into the
% workspace
% 11/6/13 jaf - created, 
% 4/12/16 jaf - modified for Argyll v1.8.3 .ti3 format to skip 22 header
% lines instead of 29
% 11/20/18 jaf - added deletion of temp vars

% read in the data from the .ti3 file skipping the header
ramps = importdata('ramps_plus.ti3',' ',22);

% unscramble the data file
ramps_sorted = sortrows(ramps.data(:,2:7),[1 2 3]);
mixed = ramps_sorted(25:end-4,:);
mixed_sorted = sortrows(mixed, [2 3]);
ramps_sorted_XYZs = ramps_sorted(:,4:6);
mixed_sorted_XYZs = mixed_sorted(:,4:6);

% extract the measured XYZs for display black and white
XYZk = mean(ramps_sorted_XYZs(1:4,:))';
XYZw = mean(ramps_sorted_XYZs(end-3:end,:))';

% extract the measured XYZs for the R,G,B, and neutral (N) ramps
% and YES, the R B G N order is correct (Argyll weirdness)
ramp_R_XYZs = [XYZk, mixed_sorted_XYZs(1:1+9, :)'];
ramp_B_XYZs = [XYZk, ramps_sorted_XYZs(5:5+9,:)'];
ramp_G_XYZs = [XYZk, ramps_sorted_XYZs(15:15+9,:)'];
ramp_N_XYZs = [XYZk, mixed_sorted_XYZs(11:end, :)', XYZw];

% delete temporary vars
clear ramps ramps_sorted mixed mixed_sorted ramps_sorted_XYZs mixed_sorted_XYZs

