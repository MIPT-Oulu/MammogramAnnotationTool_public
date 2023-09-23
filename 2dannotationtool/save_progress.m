function save_progress(handles_main) % A. I. mod 05.09.2021

% Save progress in various formats

% Get study identifier
study = handles_main.current_study;

% Get breast density
breast_density = handles_main.breast_density;

% Get remarks
remarks_text = handles_main.remarks;

% Get ready status
status_ready = handles_main.status_ready;

% Get masks
annotations = handles_main.out;

% Get inds
inds.rcc_ind = handles_main.rcc_ind;
inds.lcc_ind = handles_main.lcc_ind;
inds.rmlo_ind = handles_main.rmlo_ind;
inds.lmlo_ind = handles_main.lmlo_ind;

% Get classification
[benign_left, benign_right, malignant_left, malignant_right] = get_classification(handles_main);

classification.benign_left = benign_left;
classification.benign_right = benign_right;
classification.malignant_left = malignant_left;
classification.malignant_right = malignant_right;

% Get root dir
root_dir = handles_main.data_processing_information.root_dir;

% Check if the folder already exists and if not, then make one
makedir(fullfile(root_dir, 'mat'))
makedir(fullfile(root_dir, 'csv'))

% Save annnotations and study data as MAT file
save(fullfile(root_dir, 'mat', strcat(study, '.mat')), 'study', 'annotations', 'inds', 'breast_density', 'remarks_text', 'status_ready', 'classification', '-v7.3')

% Save PNG images of the annotations for all views (and make dir)
save_masks_as_png(handles_main)  % FIXME: comment if you don't wish to use this functionality

% Save classification results
save_classification_as_csv(handles_main)

% Save breast density assessment as a CSV file accompanied with StudyInstanceUID
save_breast_density_assessment(handles_main)

end
