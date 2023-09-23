function output = get_characterizing_input(label, handles_view) % A. I. mod 15.3.2020

% Choose a dialog based on given label

dlg_title = {'Additional characterization'};

if strcmp(handles_view.output.Name, 'Right view')
    hObj = findobj('Tag','right_view');
elseif strcmp(handles_view.output.Name, 'Left view')
    hObj = findobj('Tag','left_view');
end

window_position = getpixelposition(hObj);

if strcmp(label,'malignant_mass')
    output = choose_dialog_mass(dlg_title, window_position);
elseif strcmp(label,'benign_mass')
    output = choose_dialog_mass(dlg_title, window_position);
elseif strcmp(label,'malignant_calc')
    output = choose_dialog_calc(dlg_title, window_position);
elseif strcmp(label,'benign_calc')
    output = choose_dialog_calc(dlg_title, window_position);
elseif strcmp(label,'malignant_architechtural_distortion')
    output = choose_dialog_architechtural_distortion(dlg_title, window_position);
elseif strcmp(label,'benign_architechtural_distortion')
    output = choose_dialog_architechtural_distortion(dlg_title, window_position);
end

end