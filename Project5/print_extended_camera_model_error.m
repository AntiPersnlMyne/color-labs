function print_extended_camera_model_error(munki_Labs,camera_Labs, deltaEs)
% print a table that lists the colormunki measured and extended camera model
% estimated Labs for the CC chart and the delta E values between them
% takes in the following data
% munki_Labs 3x24 array of colormunki-measured patch Lab values
% camera_Labs - 3x24 array of extended camera-model-estimated patch Lab values
% deltaEs - 1x24 array of delta E values between the munki and camera Labs
% jaf 10/24/18 - created

% put the data into an array to allow loopless printing
table_array = [(1:24)', munki_Labs', camera_Labs', deltaEs'];

% print the table
fprintf('\n\n');
fprintf('Extended camera model color error\n');
fprintf('camera->camera_RGBs->extended_camera_model->estimated_XYZs\n\n');
fprintf('\tcolormunki measured vs. camera estimated ColorChecker Lab values\n');
fprintf('\t\t   measured\t\t     estimated\n');
fprintf('patch #\t     L        a        b        L        a        b       dEab\n');
fprintf('% 7d\t% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', table_array');
fprintf('\n');
fprintf('\t\t\t\t\t\t\tmin   % 9.4f\n', min(deltaEs));
fprintf('\t\t\t\t\t\t\tmax   % 9.4f\n', max(deltaEs));
fprintf('\t\t\t\t\t\t\tmean  % 9.4f\n', mean(deltaEs));
end

