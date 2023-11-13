function print_display_model_error(munki_Labs, display_Labs, deltaEs)
% print a table that lists the colormunki measured and display model
% estimated Labs for the CC chart and the delta E values between them
% takes in the following data
% munki_Labs 3x24 array of colormunki-measured patch Lab values
% display_Labs - 3x24 array of display-model-estimated patch Lab values
% deltaEs - 1x24 array of delta E values between the munki and camera Labs
% jaf 11/5/18 - created

% tabulate the results
table_array = [(1:24)', munki_Labs', display_Labs', deltaEs'];

% print a formatted table of the calculated XYZ and Lab values and delta Es
fprintf('\n\n');
fprintf('Display model color error\n');
fprintf('XYZ_real->display_model->RGB_disp->display\n\n');
fprintf('\t       Real vs. displayed ColorChecker Lab values\n');
fprintf('\t\t     real\t\t     displayed\n');
fprintf('patch #\t     L        a        b        L        a        b       dEab\n');
fprintf('% 7d\t% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', table_array');
fprintf('\n');
fprintf('\t\t\t\t\t\t\tmin   % 9.4f\n', min(deltaEs));
fprintf('\t\t\t\t\t\t\tmax   % 9.4f\n', max(deltaEs));
fprintf('\t\t\t\t\t\t\tmean  % 9.4f\n', mean(deltaEs));

