function handles_main = load_data(handles_main) % A. I. mod 13.3.2020

% Get current study
study_idx = handles_main.data_processing_information.study_index;
study = handles_main.data_processing_information.studies{study_idx};
handles_main.current_study = study;

% Get root dir
root_dir = handles_main.data_processing_information.root_dir;

% List DICOM files
file_list = dir(fullfile(root_dir, 'images', study, '*.dcm'));

% Initialize dataset structure
ds = struct('im', [], 'cmap', [], 'rows', [], 'cols', [], 'view', [], 'laterality', [], 'filename', [], 'folder', []);

% Initialize output structure
out = struct('annotation_malignant_mass', [], 'annotation_benign_mass', [], 'annotation_malignant_calc', [], 'annotation_benign_calc', []);

% Initialize indexes related to views
handles_main.rcc_ind = []; % empty
handles_main.rmlo_ind = []; % empty
handles_main.lcc_ind = []; % empty
handles_main.lmlo_ind = []; % empty

for ind = 1:length(file_list)
    if length(file_list) ~= 4  % A. I. mod 2.10.2023
        uiwait(msgbox('Not enough DICOM files in the study.','Read DICOM','error'));
        return;
    end

    % Read DICOM
    if isdicom(fullfile(file_list(ind).folder, file_list(ind).name)) % check that the file is valid DICOM file
        nfo = dicominfo(fullfile(file_list(ind).folder, file_list(ind).name));
    else
        uiwait(msgbox('This file is not a valid DICOM file.','Read DICOM','error'));
        return;
    end
	
	% A. I. mod 4.4.2020
    if sum(strcmp(fieldnames(nfo), 'AcquisitionDeviceProcessingDescription')) == 1 && ( sum(strcmp(fieldnames(nfo), 'ViewPosition')) == 0 || isempty(nfo.ViewPosition) )
        [view, laterality] = parse_view_laterality(nfo);
        ds(ind).view = view; % CC or MLO
        ds(ind).laterality = laterality; % R or L
    elseif sum(strcmp(fieldnames(nfo), 'AcquisitionDeviceProcessingDescription')) == 0 && sum(strcmp(fieldnames(nfo), 'ViewPosition')) == 1 && ~isempty(nfo.ViewPosition) && sum(strcmp(fieldnames(nfo), 'ImageLaterality')) == 0
        [view, laterality] = parse_view_laterality(nfo);
        ds(ind).view = view; % CC or MLO
        ds(ind).laterality = laterality; % R or L
    else
        ds(ind).view = nfo.ViewPosition; % CC or MLO
        ds(ind).laterality = nfo.ImageLaterality; % R or L
    end
	
    if strcmp(ds(ind).laterality,'R') && strcmp(ds(ind).view, 'CC') && isempty(handles_main.rcc_ind)
        handles_main.rcc_ind = ind;
    elseif strcmp(ds(ind).laterality,'R') && strcmp(ds(ind).view, 'MLO') && isempty(handles_main.rmlo_ind)
        handles_main.rmlo_ind = ind;
    elseif strcmp(ds(ind).laterality,'L') && strcmp(ds(ind).view, 'CC') && isempty(handles_main.lcc_ind)
        handles_main.lcc_ind = ind;
    elseif strcmp(ds(ind).laterality,'L') && strcmp(ds(ind).view, 'MLO') && isempty(handles_main.lmlo_ind)
        handles_main.lmlo_ind = ind;
    end
    
    warning('off', 'images:dicomread:overlaySizeMismatch')
    
    if sum(strcmp(fieldnames(nfo), 'Modality')) == 1 && sum(strcmp(fieldnames(nfo), 'SOPClassUID')) == 1  && strcmp(nfo.Modality, 'MG') && strcmp(nfo.SOPClassUID, '1.2.840.10008.5.1.4.1.1.1.2') % check that we have valid mammograms 
        [img, cmap] = dicomread(nfo);
        try
            lut_idx = 1; % default value, change to match your preferences, in Matlab indices start from '1'
            img = dicom_apply_voi_lut(img, nfo, lut_idx); % A. I. mod 9.4.2020
        catch
            uiwait(msgbox('Unable to perform windowing.','Read DICOM','warn')); % do no-op
        end
    else
        uiwait(msgbox('This is not a valid mammogram.','Read DICOM','error'));
        return;
    end
    
    if sum(strcmp(nfo.PhotometricInterpretation, 'MONOCHROME1')) == 1 && strcmp(nfo.PhotometricInterpretation, 'MONOCHROME1') % ranges from bright to dark with ascending pixel values
        img = (2^(nfo.BitsStored) - 1) - img;  %img = max(img, [], 'all') - img; %
    elseif sum(strcmp(nfo.PhotometricInterpretation, 'MONOCHROME2')) == 1 && strcmp(nfo.PhotometricInterpretation, 'MONOCHROME2') % ranges from dark to bright with ascending pixel values
        % do no-op
    else
        uiwait(msgbox('Unspecified Photometric Interpretation.','Read DICOM','error'));
        return;
    end
    
    ds(ind).folder = file_list(ind).folder;
    
    [~,filename,~] = fileparts(file_list(ind).name);
    ds(ind).filename = filename;
    
    img_size = size(img);
    
    ds(ind).im = img;
    ds(ind).cmap = cmap; % it appears that cmap = [] always
    
    ds(ind).rows = nfo.Rows; %nfo.Height
    ds(ind).cols = nfo.Columns; %nfo.Width
    
    % Initialize masks
    out(ind).annotation_malignant_mass = zeros(img_size, 'uint16');
    out(ind).annotation_benign_mass = zeros(img_size, 'uint16');
    out(ind).annotation_malignant_calc = zeros(img_size, 'uint16');
    out(ind).annotation_benign_calc = zeros(img_size, 'uint16');
    out(ind).annotation_malignant_architechtural_distortion = zeros(img_size, 'uint16');
    out(ind).annotation_benign_architechtural_distortion = zeros(img_size, 'uint16');
    
    out(ind).annotation_malignant_mass_count = 0;
    out(ind).annotation_benign_mass_count = 0;
    out(ind).annotation_malignant_calc_count = 0;
    out(ind).annotation_benign_calc_count = 0;
    out(ind).annotation_malignant_architechtural_distortion_count = 0;
    out(ind).annotation_benign_architechtural_distortion_count = 0;
    
    clear img cmap nfo
end

% Assign into handles
handles_main.ds = ds;
handles_main.out = out;

end
