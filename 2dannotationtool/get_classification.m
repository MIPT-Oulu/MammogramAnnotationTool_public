function [benign_left, benign_right, malignant_left, malignant_right] = get_classification(handles_main) % Antti mod 8.11.2019

% Get classification for sides R and L

if handles_main.out(handles_main.rcc_ind).annotation_malignant_mass_count ~= 0 || handles_main.out(handles_main.rmlo_ind).annotation_malignant_mass_count ~= 0 ...
        || handles_main.out(handles_main.rcc_ind).annotation_malignant_calc_count ~= 0 || handles_main.out(handles_main.rmlo_ind).annotation_malignant_calc_count ~= 0 ...
        || handles_main.out(handles_main.rcc_ind).annotation_malignant_architechtural_distortion_count ~= 0 || handles_main.out(handles_main.rmlo_ind).annotation_malignant_architechtural_distortion_count ~= 0 % right
    malignant_right = true;
else
    malignant_right = false;
end
    
if handles_main.out(handles_main.lcc_ind).annotation_malignant_mass_count ~= 0 || handles_main.out(handles_main.lmlo_ind).annotation_malignant_mass_count ~= 0 ...
        || handles_main.out(handles_main.lcc_ind).annotation_malignant_calc_count ~= 0 || handles_main.out(handles_main.lmlo_ind).annotation_malignant_calc_count ~= 0 ...
        || handles_main.out(handles_main.lcc_ind).annotation_malignant_architechtural_distortion_count ~= 0 || handles_main.out(handles_main.lmlo_ind).annotation_malignant_architechtural_distortion_count ~= 0 % left
    malignant_left = true;
else
    malignant_left = false;
end

if handles_main.out(handles_main.rcc_ind).annotation_benign_mass_count ~= 0 || handles_main.out(handles_main.rmlo_ind).annotation_benign_mass_count ~= 0 ...
        || handles_main.out(handles_main.rcc_ind).annotation_benign_calc_count ~= 0 || handles_main.out(handles_main.rmlo_ind).annotation_benign_calc_count ~= 0 ...
        || handles_main.out(handles_main.rcc_ind).annotation_benign_architechtural_distortion_count ~= 0 || handles_main.out(handles_main.rmlo_ind).annotation_benign_architechtural_distortion_count ~= 0 % right
    benign_right = true;
else
    benign_right = false;
end

if handles_main.out(handles_main.lcc_ind).annotation_benign_mass_count ~= 0 || handles_main.out(handles_main.lmlo_ind).annotation_benign_mass_count ~= 0 ...
        || handles_main.out(handles_main.lcc_ind).annotation_benign_calc_count ~= 0 || handles_main.out(handles_main.lmlo_ind).annotation_benign_calc_count ~= 0 ...
        || handles_main.out(handles_main.lcc_ind).annotation_benign_architechtural_distortion_count ~= 0 || handles_main.out(handles_main.lmlo_ind).annotation_benign_architechtural_distortion_count ~= 0 % left
    benign_left = true;
else
    benign_left = false;
end

%disp([benign_left, benign_right, malignant_left, malignant_right]) % For debugging

end