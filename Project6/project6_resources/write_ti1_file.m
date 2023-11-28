function filename = write_ti1_file (table4ti1, filename)

% Open/Create document
fid = fopen(filename, 'w+');

% Create Document
fprintf(fid, '%s\n\n', "CTI1")

fprintf(fid, '%s\n\n', "COLOR_REP")

fprintf(fid, '%s\n', "NUMBER_OF_FIELDS 4")
fprintf(fid, '%s\n', "BEGIN_DATA_FORMAT")
fprintf(fid, '%s\n', "SAMPLE_ID RGB_R RGB_G RGB_B")
fprintf(fid, '%s\n\n', "END_DATA_FORMAT")

fprintf(fid, '%s\n', "NUMBER_OF_SETS 30")
fprintf(fid, '%s\n', "BEGIN_DATA")

for i = 1:size(table4ti1(:, 1))
    fprintf(fid, '%i %i %i %i\n' ,table4ti1(i, 1),table4ti1(i, 2),table4ti1(i, 3),table4ti1(i, 4))
end

fprintf(fid, '%s', "END_DATA")

fclose(fid);
end % End function