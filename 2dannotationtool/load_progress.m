function handles_main = load_progress(handles_main) % Antti mod 05.09.2021

% Load the current progress (annotations, assessments, remarks)

% Get root dir
root_dir = handles_main.data_processing_information.root_dir;

% Get study identifier
this_study_idx = handles_main.data_processing_information.study_index;
this_study = handles_main.data_processing_information.studies{this_study_idx};

filename = fullfile(root_dir, 'mat', strcat(this_study, '.mat'));

if isfile(filename) % when progress has been saved
    load(filename, 'study', 'annotations', 'inds', 'breast_density', 'remarks_text', 'status_ready')

    if ~strcmp(this_study, study)
        errordlg('Study identifier mismatch','User Data Error');
        return;
    end
    
    % Get masks
    handles_main.out = annotations;

    %Get inds
    handles_main.rcc_ind = inds.rcc_ind;
    handles_main.lcc_ind = inds.lcc_ind;
    handles_main.rmlo_ind = inds.rmlo_ind;
    handles_main.lmlo_ind = inds.lmlo_ind;
    
    % Get remarks
    handles_main.remarks = remarks_text;
    
    % Get breast density
    handles_main.breast_density = breast_density;
    
    % Get annotation status
    handles_main.status_ready = status_ready;
    
else % when MAT file does not exist yet
    handles_main.status_ready = 0;
end

end
