function display_annotations(handles_main, handles_view)

% Visualize annotations (see also get_perimeter_rep)

global current_view

% Get image index
if strcmp(current_view, 'CC')
    if strcmp(handles_view.output.Tag, 'right_view')
        image_idx = handles_main.rcc_ind;
    else
        image_idx = handles_main.lcc_ind;
    end
elseif strcmp(current_view, 'MLO')
    if strcmp(handles_view.output.Tag, 'right_view')
        image_idx = handles_main.rmlo_ind;
    else
        image_idx = handles_main.lmlo_ind;
    end
end

% Get mask
malignant_mass_mask = handles_main.out(image_idx).annotation_malignant_mass;
malignant_mass_mask(malignant_mass_mask > 0) = 1; %malignant_mass_mask = imbinarize(malignant_mass_mask, 0); % Satu mod
get_perimeter_rep(malignant_mass_mask, handles_view, 'red') % Antti mod

benign_mass_mask = handles_main.out(image_idx).annotation_benign_mass;
benign_mass_mask(benign_mass_mask > 0) = 1; %benign_mass_mask = imbinarize(benign_mass_mask, 0); % Satu mod
get_perimeter_rep(benign_mass_mask, handles_view, 'green') % Antti mod

malignant_calc_mask = handles_main.out(image_idx).annotation_malignant_calc;
malignant_calc_mask(malignant_calc_mask > 0) = 1; %malignant_calc_mask = imbinarize(malignant_calc_mask, 0); % Satu mod
get_perimeter_rep(malignant_calc_mask, handles_view, 'magenta') % Antti mod

benign_calc_mask = handles_main.out(image_idx).annotation_benign_calc;
benign_calc_mask(benign_calc_mask > 0) = 1; %benign_calc_mask = imbinarize(benign_calc_mask, 0); % Satu mod
get_perimeter_rep(benign_calc_mask, handles_view, 'yellow') % Antti mod

malignant_architechtural_distortion_mask = handles_main.out(image_idx).annotation_malignant_architechtural_distortion;
malignant_architechtural_distortion_mask(malignant_architechtural_distortion_mask > 0) = 1; % Antti mod
get_perimeter_rep(malignant_architechtural_distortion_mask, handles_view, 'blue') % Antti mod

benign_architechtural_distortion_mask = handles_main.out(image_idx).annotation_benign_architechtural_distortion;
benign_architechtural_distortion_mask(benign_architechtural_distortion_mask > 0) = 1; % Antti mod
get_perimeter_rep(benign_architechtural_distortion_mask, handles_view, 'cyan') % Antti mod

end