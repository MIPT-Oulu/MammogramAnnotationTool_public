function display_images(handles_main)

% Display images, enable zoom, pan and window/level and display annotations

% View View_R_GUI and View_L_GUI
if ~isempty(findobj('Tag','right_view')) && ~isempty(findobj('Tag','left_view'))
    % do no-op
elseif isempty(findobj('Tag','right_view')) && ~isempty(findobj('Tag','left_view'))
    View_R_GUI;
elseif ~isempty(findobj('Tag','right_view')) && isempty(findobj('Tag','left_view'))
    View_L_GUI;
else
    View_R_GUI;
    View_L_GUI;
end

% Get the handles for right_view and left_view
hObj_right = findobj('Tag','right_view');
hObj_left = findobj('Tag','left_view');

handles_right_view = guidata(hObj_right);
handles_left_view = guidata(hObj_left);

global current_view

% Get image index
if strcmp(current_view, 'CC')
    image_idx_right = handles_main.rcc_ind;
    image_idx_left = handles_main.lcc_ind;
elseif strcmp(current_view, 'MLO')
	image_idx_right = handles_main.rmlo_ind;
    image_idx_left = handles_main.lmlo_ind;
end

% Get images and colormaps
im_right = handles_main.ds(image_idx_right).im;
cmap_right = handles_main.ds(image_idx_right).cmap;

im_left = handles_main.ds(image_idx_left).im;
cmap_left = handles_main.ds(image_idx_left).cmap;

% Check if the images should be complemented
if handles_main.im_compl == true
    im_right = imcomplement(im_right);
    im_left = imcomplement(im_left);
end

cla(handles_right_view.axes_mammogram)
cla(handles_left_view.axes_mammogram)

% Show image
set(handles_right_view.axes_mammogram,{'xlim','ylim'}, {[1, size(im_right, 2)], [1, size(im_right, 1)]}); % setting the axes
imshow(im_right, cmap_right, 'Parent', handles_right_view.axes_mammogram)

% Show image
set(handles_left_view.axes_mammogram,{'xlim','ylim'}, {[1, size(im_left, 2)], [1, size(im_left, 1)]}); % setting the axes
imshow(im_left, cmap_left, 'Parent', handles_left_view.axes_mammogram);

% Enable zoom, pan and window/level, requires image size
imgutils(handles_right_view.right_view, 'ImgWidth', size(im_right, 2), 'ImgHeight', size(im_right, 1));
imgutils(handles_left_view.left_view, 'ImgWidth', size(im_left, 2), 'ImgHeight', size(im_left, 1));

% Set View_R_GUI and View_L_GUI visible
if ~strcmp(get(hObj_right,'Visible'),'on')
    set(View_R_GUI,'Visible','on')
end
if ~strcmp(get(hObj_left,'Visible'),'on')
    set(View_L_GUI,'Visible','on')
end

% Display annotations
if strcmp(get(hObj_right,'Visible'),'on')
    display_annotations(handles_main, handles_right_view)
end
if strcmp(get(hObj_left,'Visible'),'on')
    display_annotations(handles_main, handles_left_view)
end

% Focus on right_view and left_view
figure(hObj_right)
figure(hObj_left)

% Return focus on main_window
hObj_main = findobj('Tag','main_window'); % Antti mod 29.3.2020
figure(hObj_main)

end