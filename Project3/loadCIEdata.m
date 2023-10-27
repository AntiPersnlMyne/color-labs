%%
% This function imports all of the CIE data from the project 3 resources
% folder as well as creates a PRD and IllE matrix to store in the structure
% <include>loadCIEdata.m</include>
function [cie] = loadCIEdata
CIE_2 = readmatrix('CIE_2Deg_380-780-5nm.txt');
cie.lambda = CIE_2(:,1);
cie.cmf2deg = CIE_2(:,2:4);
CIE_10 = readmatrix('CIE_10Deg_380-780-5nm.txt');
cie.cmf10deg = CIE_10(:,2:4);
CIE_illA = readmatrix('CIE_IllA_380-780-5nm.txt');
cie.illA = CIE_illA(:,2);
CIE_illC = readmatrix('CIE_IllC_380-780-5nm.txt');
cie.illC = CIE_illC(:,2);
CIE_illD50 = readmatrix('CIE_IllD50_380-780-5nm.txt');
cie.illD50 = CIE_illD50(:,2);
CIE_illD65 = readmatrix('CIE_IllD65_380-780-5nm.txt');
cie.illD65 = CIE_illD65(:,2);
CIE_illE = ones(81,1).*100;
cie.illE = CIE_illE;
CIE_illF = readmatrix("CIE_IllF_1-12_380-780-5nm.txt");
cie.illF = CIE_illF(:,2:13);
PRD = ones(81,1);
cie.PRD=PRD;
end