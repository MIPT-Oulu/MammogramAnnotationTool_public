function handles_main = annotate_image(handles_view, handles_main, image_idx, label)

% Drawing a freehand ROI, creating a mask and storing information related
% to the ROI.

% Get image
img = handles_main.ds(image_idx).im;

% Get mask
if strcmp(label,'malignant_mass')
    segmentation_mask = handles_main.out(image_idx).annotation_malignant_mass;
    line_color = 'r';
elseif strcmp(label,'benign_mass')
    segmentation_mask = handles_main.out(image_idx).annotation_benign_mass;
    line_color = 'g';
elseif strcmp(label,'malignant_calc')
    segmentation_mask = handles_main.out(image_idx).annotation_malignant_calc;
    line_color = 'm';
elseif strcmp(label,'benign_calc')
    segmentation_mask = handles_main.out(image_idx).annotation_benign_calc;
    line_color = 'y';
elseif strcmp(label,'malignant_architechtural_distortion')
    segmentation_mask = handles_main.out(image_idx).annotation_malignant_architechtural_distortion;
    line_color = 'b';
elseif strcmp(label,'benign_architechtural_distortion')
    segmentation_mask = handles_main.out(image_idx).annotation_benign_architechtural_distortion;
    line_color = 'c';
end

% Get height (rows) and width (columns)
%[h, w, ~] = size(img);
h = handles_main.ds(image_idx).rows;
w = handles_main.ds(image_idx).cols;

% Set ROI, ESC aborts ROI creation when left mouse button has not been released
roi = drawfreehand(handles_view.axes_mammogram,'Color',line_color,'Smoothing',1,'FaceAlpha',0,'DrawingArea',[0,0,w,h],'LabelVisible','hover','Label',label,'InteractionsAllowed','reshape'); % Antti mod 11.3.2020

% Handle the situation when ROI creation is aborted
try
    % Create mask, see https://www.mathworks.com/help/images/ref/createmask.html
    new_segmentation_mask = createMask(roi, img); % Antti mod
    
    % Delete ROI object
    delete(roi);
    
    new_segmentation_mask = uint16(new_segmentation_mask);
    [y, x] = find(new_segmentation_mask); % Antti mod 15.3.2020
    x_center = mean(x); % Antti mod 15.3.2020
    y_center = mean(y); % Antti mod 15.3.2020
    val = max(segmentation_mask(:)) + 1; % increment val as masks are added
    %disp(val) % For debugging
    new_segmentation_mask(new_segmentation_mask == 1) = val;
    
    % Add new mask into the existng segmentation mask
    segmentation_mask = imadd(segmentation_mask, new_segmentation_mask, 'uint16');
    mask_count = count_masks(segmentation_mask);
    
    % Set mask
    if strcmp(label,'malignant_mass')
        handles_main.out(image_idx).annotation_malignant_mass = segmentation_mask;
        handles_main.out(image_idx).annotation_malignant_mass_count = mask_count;
        mask_char = get_characterizing_input(label, handles_view); % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_malignant_mass_char(val) = mask_char; % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_malignant_mass_x_center(val) = x_center; % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_malignant_mass_y_center(val) = y_center; % Antti mod 15.3.2020
    elseif strcmp(label,'benign_mass')
        handles_main.out(image_idx).annotation_benign_mass = segmentation_mask;
        handles_main.out(image_idx).annotation_benign_mass_count = mask_count;
        mask_char = get_characterizing_input(label, handles_view); % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_benign_mass_char(val) = mask_char; % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_benign_mass_x_center(val) = x_center; % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_benign_mass_y_center(val) = y_center; % Antti mod 15.3.2020
    elseif strcmp(label,'malignant_calc')
        handles_main.out(image_idx).annotation_malignant_calc = segmentation_mask;
        handles_main.out(image_idx).annotation_malignant_calc_count = mask_count;
        mask_char = get_characterizing_input(label, handles_view); % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_malignant_calc_char(val) = mask_char; % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_malignant_calc_x_center(val) = x_center; % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_malignant_calc_y_center(val) = y_center; % Antti mod 15.3.2020
    elseif strcmp(label,'benign_calc')
        handles_main.out(image_idx).annotation_benign_calc = segmentation_mask;
        handles_main.out(image_idx).annotation_benign_calc_count = mask_count;
        mask_char = get_characterizing_input(label, handles_view); % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_benign_calc_char(val) = mask_char; % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_benign_calc_x_center(val) = x_center; % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_benign_calc_y_center(val) = y_center; % Antti mod 15.3.2020
    elseif strcmp(label,'malignant_architechtural_distortion') % Antti mod 18.3.2020
        handles_main.out(image_idx).annotation_malignant_architechtural_distortion = segmentation_mask;
        handles_main.out(image_idx).annotation_malignant_architechtural_distortion_count = mask_count;
        mask_char = get_characterizing_input(label, handles_view); % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_malignant_architechtural_distortion_char(val) = mask_char; % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_malignant_architechtural_distortion_x_center(val) = x_center; % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_malignant_architechtural_distortion_y_center(val) = y_center; % Antti mod 15.3.2020
    elseif strcmp(label,'benign_architechtural_distortion') % Antti mod 18.3.2020
        handles_main.out(image_idx).annotation_benign_architechtural_distortion = segmentation_mask;
        handles_main.out(image_idx).annotation_benign_architechtural_distortion_count = mask_count;
        mask_char = get_characterizing_input(label, handles_view); % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_benign_architechtural_distortion_char(val) = mask_char; % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_benign_architechtural_distortion_x_center(val) = x_center; % Antti mod 15.3.2020
        handles_main.out(image_idx).annotation_benign_architechtural_distortion_y_center(val) = y_center; % Antti mod 15.3.2020
    end
catch
    % do no-op
end

clear img segmentation_mask new_segmentation_mask

end