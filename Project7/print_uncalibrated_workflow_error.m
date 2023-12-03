function print_uncalibrated_workflow_error(munki_Labs, workflow_Labs_uncal, deltaEs_uncal)
% print a table that lists the CC Lab values for the munki-measured and
% uncalibrated color imaging workflow and the delta E values between them
%
% takes in the following data
% munki_Labs 3x24 array of colormunki-measured CC Lab values
% workflow_Labs_uncal - 3x24 array of dispalyed CC Labs using the uncalibrated
% workflow
% deltaEs_uncal - 1x24 array of delta E values between the munki-measured and
% unclalibrated workflow Labs
% 11/5/18 jaf - created

% put the data into an array to allow loopless printing
table_array = [(1:24)', munki_Labs', workflow_Labs_uncal', deltaEs_uncal'];

fprintf('\n\n');
fprintf('Uncalibrated workflow color error\n');
fprintf('camera->RGB_cam->display\n\n');
fprintf('\t       Real vs. displayed ColorChecker Lab values\n');
fprintf('\t\t     real\t\t     displayed\n');
fprintf('patch #\t     L        a        b        L        a        b       dEab\n');
fprintf('% 7d\t% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', table_array');
fprintf('\n');
fprintf('\t\t\t\t\t\t\tmin   % 9.4f\n', min(deltaEs_uncal));
fprintf('\t\t\t\t\t\t\tmax   % 9.4f\n', max(deltaEs_uncal));
fprintf('\t\t\t\t\t\t\tmean  % 9.4f\n', mean(deltaEs_uncal));
end
