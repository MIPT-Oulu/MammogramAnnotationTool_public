function save_masks_as_png(handles_main) % A. I. mod 28.11.2019

% Save PNG images of the annotations for all views, generate destination file name from study details

% Get current study
study = handles_main.current_study;

% Get root dir
root_dir = handles_main.data_processing_information.root_dir; % root_dir for example 'C:\MatlabProjectFiles\MammoAnnotationTool\dataset\'

% Check if folder exists and if not, then make one
makedir(fullfile(root_dir, 'masks', study))

% Save masks for all views
for idx = 1:length(handles_main.ds)

    if strcmp(handles_main.ds(idx).laterality,'R') && strcmp(handles_main.ds(idx).view, 'CC')
        image_ind = handles_main.rcc_ind;
    elseif strcmp(handles_main.ds(idx).laterality,'R') && strcmp(handles_main.ds(idx).view, 'MLO')
        image_ind = handles_main.rmlo_ind;
    elseif strcmp(handles_main.ds(idx).laterality,'L') && strcmp(handles_main.ds(idx).view, 'CC')
        image_ind = handles_main.lcc_ind;
    elseif strcmp(handles_main.ds(idx).laterality,'L') && strcmp(handles_main.ds(idx).view, 'MLO')
        image_ind = handles_main.lmlo_ind;
    end
    
    % Save as PNG file
    imwrite(double(full(handles_main.out(image_ind).annotation_malignant_mass)), fullfile(root_dir, 'masks', study, strcat(handles_main.ds(image_ind).filename, '_mask_malignant_mass', '.png')), 'BitDepth', 8);
    imwrite(double(full(handles_main.out(image_ind).annotation_benign_mass)), fullfile(root_dir, 'masks', study, strcat(handles_main.ds(image_ind).filename, '_mask_benign_mass', '.png')), 'BitDepth', 8); 
    imwrite(double(full(handles_main.out(image_ind).annotation_malignant_calc)), fullfile(root_dir, 'masks', study, strcat(handles_main.ds(image_ind).filename, '_mask_malignant_calc', '.png')), 'BitDepth', 8);
    imwrite(double(full(handles_main.out(image_ind).annotation_benign_calc)), fullfile(root_dir, 'masks', study, strcat(handles_main.ds(image_ind).filename, '_mask_benign_calc', '.png')), 'BitDepth', 8);
    imwrite(double(full(handles_main.out(image_ind).annotation_malignant_architechtural_distortion)), fullfile(root_dir, 'masks', study, strcat(handles_main.ds(image_ind).filename, '_mask_malignant_architechtural_distortion', '.png')), 'BitDepth', 8);
    imwrite(double(full(handles_main.out(image_ind).annotation_benign_architechtural_distortion)), fullfile(root_dir, 'masks', study, strcat(handles_main.ds(image_ind).filename, '_mask_benign_architechtural_distortion', '.png')), 'BitDepth', 8);
    
end

end