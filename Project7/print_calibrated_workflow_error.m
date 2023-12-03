function print_calibrated_workflow_error(munki_Labs, workflow_Labs_cal, deltaEs_cal)
% print a table that lists the CC Lab values for the munki-measured and
% uncalibrated color imaging workflow and the delta E values between them
%
% takes in the following data
% munki_Labs - 3x24 array of colormunki-measured CC Lab values
% workflow_Labs_cal - 3x24 array of displayed CC Labs using the calibrated
% workflow
% deltaEs_cal - 1x24 array of delta E values between the munki-measured and
% calibrated workflow Labs
% 11/5/18 jaf - created

% put the data into an array to allow loopless printing
table_array = [(1:24)', munki_Labs', workflow_Labs_cal', deltaEs_cal'];

fprintf('\n\n');
fprintf('Calibrated workflow color error\n');
fprintf('camera->RGB_cam->camera_model->XYZ_est->display_model->RGB_disp->display\n\n');
fprintf('\t       Real vs. displayed ColorChecker Lab values\n');
fprintf('\t\t     real\t\t     displayed\n');
fprintf('patch #\t     L        a        b        L        a        b       dEab\n');
fprintf('% 7d\t% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', table_array');
fprintf('\n');
fprintf('\t\t\t\t\t\t\tmin   % 9.4f\n', min(deltaEs_cal));
fprintf('\t\t\t\t\t\t\tmax   % 9.4f\n', max(deltaEs_cal));
fprintf('\t\t\t\t\t\t\tmean  % 9.4f\n', mean(deltaEs_cal));
end
