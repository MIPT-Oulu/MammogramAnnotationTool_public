function handles_main = update_annotation_status(handles_main) % A. I. mod 05.09.2021

% Update annotations status and re-write CSV file (this is the file with
% list of studies (names of the folders with mammograms in DICOM format)

filename = fullfile(handles_main.data_processing_information.root_dir, handles_main.data_processing_information.studies_filename);
study_table = readtable(filename,'Delimiter',',');

study_idx = find(strcmp(handles_main.current_study, study_table{:,1}));

study_table.AnnotationStatus(study_idx) = handles_main.data_processing_information.annotation_status(study_idx);

% Update file
writetable(study_table, filename);

end