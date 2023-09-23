function varargout = View_L_GUI(varargin)
% VIEW_L_GUI MATLAB code for View_L_GUI.fig
%      VIEW_L_GUI, by itself, creates a new VIEW_L_GUI or raises the existing
%      singleton*.
%
%      H = VIEW_L_GUI returns the handle to a new VIEW_L_GUI or the handle to
%      the existing singleton*.
%
%      VIEW_L_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_L_GUI.M with the given input arguments.
%
%      VIEW_L_GUI('Property','Value',...) creates a new VIEW_L_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before View_L_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to View_L_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help View_L_GUI

% Last Modified by GUIDE v2.5 21-Feb-2020 14:46:44

% Copyright (c) 2019 Research Unit of Health Sciences and Technology
% Copyright (c) 2019 Antti Isosalo
% Copyright (c) 2019 Helinä Heino
% Copyright (c) 2019 Satu I. Inkinen
% Copyright (c) 2019 Topi Turunen
% Copyright (c) 2019 Miika T. Nieminen

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @View_L_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @View_L_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before View_L_GUI is made visible.
function View_L_GUI_OpeningFcn(hObject, eventdata, left_view_handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% left_view_handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to View_L_GUI (see VARARGIN)

% Choose default command line output for View_L_GUI
left_view_handles.output = hObject;

% Set window title
set(left_view_handles.left_view, 'Name', 'Left view');

% Update handles structure
guidata(hObject, left_view_handles);

% UIWAIT makes View_L_GUI wait for user response (see UIRESUME)
% uiwait(left_view_handles.left_view);


% --- Outputs from this function are returned to the command line.
function varargout = View_L_GUI_OutputFcn(hObject, eventdata, left_view_handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% left_view_handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = left_view_handles.output;


% --- Executes on key press with focus on left_view or any of its controls.
function left_view_WindowKeyPressFcn(hObject, eventdata, left_view_handles)
% hObject    handle to left_view (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% left_view_handles    structure with handles and user data (see GUIDATA)

modifiers = get(gcf,'currentModifier'); 
ctrl_is_pressed = ismember('control',modifiers);

% Handle a situation where combination of keys with ctrl key are pressed
if ctrl_is_pressed
    return;
end

switch eventdata.Key % Keypress
    case 'i' % invert image
        hObj_main = findobj('Tag','main_window');
        handles_main = guidata(hObj_main);
        handles_main = compl_image(handles_main); % invert (coplement) image
        display_images(handles_main);
        guidata(hObj_main, handles_main);
    case 'r' % remove annotation
        remove_annotation_cb(hObject, eventdata, left_view_handles)
    case 's'
        hObj_main = findobj('Tag','main_window');
        handles_main = guidata(hObj_main);
        Main_GUI('menu_item_save_Callback',hObj_main,eventdata,handles_main)
    case 'v' % switch view
        hObj_main = findobj('Tag','main_window');
        handles_main = guidata(hObj_main);
        handles_main = switch_view(handles_main);
        display_images(handles_main);
        guidata(hObj_main, handles_main);
    case 'z' % zoom out
        hObj_main = findobj('Tag','main_window');
        handles_main = guidata(hObj_main);
        display_images(handles_main);
    case 'f1' % annotate malignant mass
        annotate_cb(hObject, eventdata, left_view_handles)
    case 'f2' % annotate benign mass
        annotate_cb(hObject, eventdata, left_view_handles)
    case 'f3' % annotate malignant calc
        annotate_cb(hObject, eventdata, left_view_handles)
    case 'f4' % annotate benign calc
        annotate_cb(hObject, eventdata, left_view_handles)
    case 'f5' % malignant architectural distortion
        annotate_cb(hObject, eventdata, left_view_handles)
    case 'f6' % benign architectural distortion
        annotate_cb(hObject, eventdata, left_view_handles)
    case 'rightarrow' % next
        hObj_main = findobj('Tag','main_window');
        handles_main = guidata(hObj_main);
        Main_GUI('switch_study',hObj_main,eventdata,handles_main);
    case 'leftarrow' % previous
        hObj_main = findobj('Tag','main_window');
        handles_main = guidata(hObj_main);
        Main_GUI('switch_study',hObj_main,eventdata,handles_main);
    otherwise
        % do no-op
end


% --------------------------------------------------------------------
function annotate_cb(hObject, eventdata, left_view_handles)

event_key = eventdata.Key;
if strcmp(event_key, 'f1')
    label = 'malignant_mass';
elseif strcmp(event_key, 'f2')
    label = 'benign_mass';
elseif strcmp(event_key, 'f3')
    label = 'malignant_calc';
elseif strcmp(event_key, 'f4')
    label = 'benign_calc';
elseif strcmp(event_key, 'f5')
    label = 'malignant_architechtural_distortion';
elseif strcmp(event_key, 'f6')
    label = 'benign_architechtural_distortion';
end
    
global current_view

hObj_main = findobj('Tag','main_window');
handles_main = guidata(hObj_main); % handles

hObj_right = findobj('Tag','right_view');
right_view_handles = guidata(hObj_right);

% Get image index
if strcmp(current_view, 'CC')
    idx = handles_main.lcc_ind;
elseif strcmp(current_view, 'MLO')
	idx = handles_main.lmlo_ind;
end

% Annotate image
handles_main = annotate_image(left_view_handles, handles_main, idx, label);

% Display images and annotations
display_images(handles_main);

% Update handles structure
guidata(hObj_main,handles_main)

% Update handles structure
guidata(hObj_right, right_view_handles);

% Update handles structure
guidata(hObject, left_view_handles);


% ---
function remove_annotation_cb(hObject, eventdata, left_view_handles) %#ok<INUSL>

% Get position for the annotation which needs to be removed, ESC cancels
[x, y] = select_point(left_view_handles.axes_mammogram);

X = floor(x);
Y = floor(y);

% Handle the situation where user aborts by pressing ESC
if isempty(x) && isempty(y) % A. I. mod
    return;
end

global current_view

hObj_main = findobj('Tag','main_window');
handles_main = guidata(hObj_main); % handles

hObj_right = findobj('Tag','right_view');
right_view_handles = guidata(hObj_right);

% Get image index
if strcmp(current_view, 'CC')
    image_idx = handles_main.lcc_ind;
elseif strcmp(current_view, 'MLO')
	image_idx = handles_main.lmlo_ind;
end

% Handle the situation where index in either position exceeds array bounds (must not exceed image dimensions)
if X < 0 || Y < 0  % A. I. mod
    return;
end

% Handle the situation where index in either position exceeds array bounds (must not exceed image dimensions)
if X > handles_main.ds(image_idx).cols || Y > handles_main.ds(image_idx).rows  % A. I. mod
    return;
end

%disp([X, Y]) % For debugging

% Delete annotation, if two (or more) masks fully overlap, both (or all) overlapping masks will be deleted
[res_mask_malignant_mass, mask_count_malignant_mass, pxl_val_malignant_mass] = delete_annotation(handles_main.out(image_idx).annotation_malignant_mass, X, Y); % A. I. mod 15.3.2020
[res_mask_benign_mass, mask_count_benign_mass, pxl_val_benign_mass] = delete_annotation(handles_main.out(image_idx).annotation_benign_mass, X, Y); % A. I. mod 15.3.2020
[res_mask_malignant_calc, mask_count_malignant_calc, pxl_val_malignant_calc] = delete_annotation(handles_main.out(image_idx).annotation_malignant_calc, X, Y); % A. I. mod 15.3.2020
[res_mask_benign_calc, mask_count_benign_calc, pxl_val_benign_calc] = delete_annotation(handles_main.out(image_idx).annotation_benign_calc, X, Y); % A. I. mod 15.3.2020
[res_mask_malignant_architechtural_distortion, mask_count_malignant_architechtural_distortion, pxl_val_malignant_architechtural_distortion] = delete_annotation(handles_main.out(image_idx).annotation_malignant_architechtural_distortion, X, Y); % A. I. mod 15.3.2020
[res_mask_benign_architechtural_distortion, mask_count_benign_architechtural_distortion, pxl_val_benign_architechtural_distortion] = delete_annotation(handles_main.out(image_idx).annotation_benign_architechtural_distortion, X, Y); % A. I. mod 15.3.2020

% Update mask
handles_main.out(image_idx).annotation_malignant_mass = res_mask_malignant_mass;
handles_main.out(image_idx).annotation_malignant_mass_count = mask_count_malignant_mass;
if pxl_val_malignant_mass ~= 0 % A. I. mod 15.3.2020
    handles_main.out(image_idx).annotation_malignant_mass_char(pxl_val_malignant_mass) = [];
    handles_main.out(image_idx).annotation_malignant_mass_x_center(pxl_val_malignant_mass) = [];
    handles_main.out(image_idx).annotation_malignant_mass_y_center(pxl_val_malignant_mass) = [];
end
handles_main.out(image_idx).annotation_benign_mass = res_mask_benign_mass;
handles_main.out(image_idx).annotation_benign_mass_count = mask_count_benign_mass;
if pxl_val_benign_mass ~= 0 % A. I. mod 15.3.2020
    handles_main.out(image_idx).annotation_benign_mass_char(pxl_val_benign_mass) = [];
    handles_main.out(image_idx).annotation_benign_mass_x_center(pxl_val_benign_mass) = [];
    handles_main.out(image_idx).annotation_benign_mass_y_center(pxl_val_benign_mass) = [];
end
handles_main.out(image_idx).annotation_malignant_calc = res_mask_malignant_calc;
handles_main.out(image_idx).annotation_malignant_calc_count = mask_count_malignant_calc;
if pxl_val_malignant_calc ~= 0 % A. I. mod 15.3.2020
    handles_main.out(image_idx).annotation_malignant_calc_char(pxl_val_malignant_calc) = [];
    handles_main.out(image_idx).annotation_malignant_calc_x_center(pxl_val_malignant_calc) = [];
    handles_main.out(image_idx).annotation_malignant_calc_y_center(pxl_val_malignant_calc) = [];
end
handles_main.out(image_idx).annotation_benign_calc = res_mask_benign_calc;
handles_main.out(image_idx).annotation_benign_calc_count = mask_count_benign_calc;
if pxl_val_benign_calc ~= 0 % A. I. mod 15.3.2020
    handles_main.out(image_idx).annotation_benign_calc_char(pxl_val_benign_calc) = [];
    handles_main.out(image_idx).annotation_benign_calc_x_center(pxl_val_benign_calc) = [];
    handles_main.out(image_idx).annotation_benign_calc_y_center(pxl_val_benign_calc) = [];
end
handles_main.out(image_idx).annotation_malignant_architechtural_distortion = res_mask_malignant_architechtural_distortion;
handles_main.out(image_idx).annotation_malignant_architechtural_distortion_count = mask_count_malignant_architechtural_distortion;
if pxl_val_malignant_architechtural_distortion ~= 0 % A. I. mod 15.3.2020
    handles_main.out(image_idx).annotation_malignant_architechtural_distortion_char(pxl_val_malignant_architechtural_distortion) = [];
    handles_main.out(image_idx).annotation_malignant_architechtural_distortion_x_center(pxl_val_malignant_architechtural_distortion) = [];
    handles_main.out(image_idx).annotation_malignant_architechtural_distortion_y_center(pxl_val_malignant_architechtural_distortion) = [];
end
handles_main.out(image_idx).annotation_benign_architechtural_distortion = res_mask_benign_architechtural_distortion;
handles_main.out(image_idx).annotation_benign_architechtural_distortion_count = mask_count_benign_architechtural_distortion;
if pxl_val_benign_architechtural_distortion ~= 0 % A. I. mod 15.3.2020
    handles_main.out(image_idx).annotation_benign_architechtural_distortion_char(pxl_val_benign_architechtural_distortion) = [];
    handles_main.out(image_idx).annotation_benign_architechtural_distortion_x_center(pxl_val_benign_architechtural_distortion) = [];
    handles_main.out(image_idx).annotation_benign_architechtural_distortion_y_center(pxl_val_benign_architechtural_distortion) = [];
end

% disp(handles_main.out(image_idx).annotation_malignant_mass_count) % For debugging
% disp(handles_main.out(image_idx).annotation_benign_mass_count) % For debugging
% disp(handles_main.out(image_idx).annotation_malignant_calc_count) % For debugging
% disp(handles_main.out(image_idx).annotation_benign_calc_count) % For debugging
% disp(handles_main.out(image_idx).annotation_malignant_architechtural_distortion_count) % For debugging
% disp(handles_main.out(image_idx).annotation_benign_architechtural_distortion_count) % For debugging

% Display images and annotations
display_images(handles_main);

% Update handles structure
guidata(hObj_main,handles_main)

% Update handles structure
guidata(hObj_right, right_view_handles);

% Update handles structure
guidata(hObject, left_view_handles);
