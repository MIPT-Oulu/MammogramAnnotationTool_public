function varargout = Main_GUI(varargin) %#ok<*DEFNU>
% MAIN_GUI MATLAB code for Main_GUI.fig
%      MAIN_GUI, by itself, creates a new MAIN_GUI or raises the existing
%      singleton*.
%
%      H = MAIN_GUI returns the handle to a new MAIN_GUI or the handle to
%      the existing singleton*.
%
%      MAIN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_GUI.M with the given input arguments.
%
%      MAIN_GUI('Property','Value',...) creates a new MAIN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Main_GUI

% Last Modified by GUIDE v2.5 05-Sep-2021 22:28:44

% Copyright (c) 2019 Research Unit of Medical Imaging, Physics and Technology
% Copyright (c) 2019 Antti Isosalo 
% Copyright (c) 2019 Satu Inkinen
% Copyright (c) 2019 Miika T. Nieminen

% Features
% 
% Panning:
% * Left mouse button down, panning
% 
% Window/Level:
% * Right mouse button down, horizontal movement, brightness
% * Right mouse button down, vertical movement, contrast
% * Brightness/contrast, also when image is inverted
% 
% Zoom:
% * Mouse roll, zoom in / zoom out
% * Mouse roll click (keypress z), zoom out
% 
% Annotations:
% * Creating annotations (keypress F1-F6), freehand ROI can be drawn by holding left mouse button down, cancel before releasing left mouse button by pressing ESC
% * Removing annotations (keypress r), target the desired ROI with crosshair, cancel without removing any annotations with right mouse click
% * Visualizing annotations, automatic
% 
% Invert image:
% * Invert image, keypress i
% 
% Switch view:
% * Switch view (CC/MLO), keypress v
% 
% Saving results:
% * Saving annotations and other user inputed data, automatic/manual
% * Ctrl + S saves results/progress
%
% Swich study:
% * Right arrow next / left arrow previous
% * By inputting StudyInstanceUID and pressing pushbutton "Go"

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Main_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Main_GUI_OutputFcn, ...
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


% --- Executes just before Main_GUI is made visible.
function Main_GUI_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main_GUI (see VARARGIN)

% Choose default command line output for Main_GUI
handles.output = hObject;

% Set window title
ver = get_version(); % cell array
set(handles.main_window, 'Name', cell2mat(strcat({'Mammogram annotation tool'}, {' '}, ver)));

% Set global and initialize current_view
global current_view
current_view = '';
handles.current_view = current_view;

% Initialize breast density
handles.breast_density = '0'; % initial situation when breast density has not been assessed

% Initialize remarks field
handles.remarks = '';

% Initialize im_compl variable, image not inverted
handles.im_compl = false;

% Initialize structures for data processing
data_processing_information = struct('root_dir', [], 'studies', [], 'study_index', []);
handles.data_processing_information = data_processing_information;

% Move figure to specified location on screen
movegui(gcf,'center')

set(handles.menu_item_help,'Enable','off') % FIXME: Enable 'user_guide.html'

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Main_GUI wait for user response (see UIRESUME)
% uiwait(handles.main_window);


% --- Outputs from this function are returned to the command line.
function varargout = Main_GUI_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_item_open_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to menu_item_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get information related to studies within the dataset
[filename, root_dir] = uigetfile('..\*.csv', 'Select a CSV File');

% User selected 'cancel' in the File dialog
if filename == 0
    return;
end

handles.data_processing_information.studies_filename = filename;

studies_table = readtable(fullfile(root_dir, filename), 'Delimiter',',' ,'ReadVariableNames',true);

% Get studies
studies = studies_table.StudyInstanceUID; % these correspond to the folder names

% Get annotation status
handles.data_processing_information.annotation_status = studies_table.AnnotationStatus; % 0, 2, 1

% Get date when last modified
handles.data_processing_information.date_modified = studies_table.DateModified;

handles.data_processing_information.root_dir = root_dir;
handles.data_processing_information.studies = studies;
handles.data_processing_information.study_index = 1;

% Handle the situation where all studies have been annotated
if all(studies_table.AnnotationStatus)
    uiwait(msgbox('All studies have been marked ready.','Annotation status','help'));
    return;
end

% Check if annotation status is "1" and step forward
if studies_table.AnnotationStatus(handles.data_processing_information.study_index)
    handles.data_processing_information.study_index = find(studies_table.AnnotationStatus == 0, 1); % first study which is not marked as Ready, i.e. as "1"
end

% Load data
handles = load_data(handles);

% Check if we have saved data for the studies
handles = load_progress(handles);

% Set StudyInstanceUID to the corresponding Main_GUI field
set(handles.edit_study_instance_uid, 'string', num2str(handles.current_study));

% Initialize view
handles = switch_view(handles);

% Display image data
display_images(handles)

% Make buttons and other main GUI elements visible
set(handles.uipanel_study,'Visible','on')
set(handles.menu_item_save,'Enable','on')
set(handles.menu_view,'Visible','on')
set(handles.menu_study,'Visible','on')
set(handles.menu_item_study_list,'Visible','off')
%set(handles.menu_item_help,'Enable','on') % FIXME

% Update handles structure
guidata(hObject,handles)


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_item_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_item_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
main_window_CloseRequestFcn(hObject.Parent.Parent, eventdata, handles)  % hObject.Parent is File and File.Parent is Main_GUI


% --- Executes when user attempts to close main_window.
function main_window_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to main_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Save all user inputed data and reference to the raw data
if ~isempty(handles.data_processing_information.studies)
    save_progress(handles)
end

% Close additional figures and GUI windows
delete(findall(groot, 'Type', 'figure'));

% Close figure
delete(hObject);


% --- Executes on key press with focus on main_window or any of its controls.
function main_window_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to main_window (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% Handle a situation keypress originates from the edit box
if isequal(gco, handles.edit_study_instance_uid)
    return;
end

modifiers = get(gcf,'currentModifier'); 
ctrl_is_pressed = ismember('control',modifiers);

% Handle a situation where combination of keys with ctrl key are pressed
if ctrl_is_pressed
    return;
end

% Handle the situation where there are not yet any studies open
if ~isfield(handles,'current_study') % Antti mod 8.4.2020
    return;
end

switch eventdata.Key % Keypress
    case 'c'
        %get_classification(handles); % For debugging
    case 'd'
        %get_breast_density(handles); % For debugging
    case 'e'
        %disp(handles.remarks) % For debugging
    case 'i'
        handles = compl_image(handles); % invert (coplement) image
        display_images(handles);
        guidata(hObject, handles)
    case 's'
        menu_item_save_Callback(hObject, eventdata, handles)
    case 'v'
        handles = switch_view(handles);
        display_images(handles);
        guidata(hObject, handles)
    case 'z' % zoom out
        display_images(handles);
    case 'rightarrow' % next
        switch_study(hObject, eventdata, handles);
    case 'leftarrow' % previous
        switch_study(hObject, eventdata, handles);
    otherwise
        %disp(eventdata.Key) % For debugging
        
end


% --------------------------------------------------------------------
function menu_item_about_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to menu_item_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Display About dialog
licence = get_licence_text();
CreateStruct.Interpreter = 'tex';
CreateStruct.WindowStyle = 'non-modal';
msgbox(licence,'About','help',CreateStruct); % see https://www.mathworks.com/help/matlab/ref/msgbox.html


% --------------------------------------------------------------------
function handles = switch_study(hObject, eventdata, handles, user_input_study_idx)

current_study_index = handles.data_processing_information.study_index;

if strcmp(eventdata.EventName,'WindowKeyPress')
    if strcmp(eventdata.Key,'leftarrow') && current_study_index == 1 % handle the situation when there are no more (previous) studies
        uiwait(msgbox('This is the first study.','Previous','help'));
        return;
    elseif strcmp(eventdata.Key,'rightarrow') && current_study_index == size(handles.data_processing_information.studies, 1) % handle the situation when there are no more (next) studies
        uiwait(msgbox('This is the last study.','Next','help'));
        return;
    end
end

% Handle the situation where all studies have been annotated
if all(handles.data_processing_information.annotation_status)
    uiwait(msgbox('All studies have been marked ready.','Annotation status','help'));
    return;
end

% Check if there are any annotated studies and if not do no-op
if strcmp(eventdata.EventName,'WindowKeyPress')
    if strcmp(eventdata.Key,'leftarrow') && handles.data_processing_information.annotation_status(current_study_index - 1) == 1
        study_idx_unannotated = find(handles.data_processing_information.annotation_status == 0); % studies which are not marked as ready, i.e. "1"
        idxs = study_idx_unannotated(study_idx_unannotated < (current_study_index - 1));
        if isempty(idxs)
            uiwait(msgbox('There is no previous unannotated study.','Previous','help'));
            return;
        end
    elseif strcmp(eventdata.Key,'rightarrow') && handles.data_processing_information.annotation_status(current_study_index + 1) == 1
        study_idx_unannotated = find(handles.data_processing_information.annotation_status == 0); % studies which are not marked as ready, i.e. "1"
        idxs = study_idx_unannotated(study_idx_unannotated > (current_study_index + 1));
        if isempty(idxs)
            uiwait(msgbox('There is no next unannotated study.','Next','help'));
            return;
        end
    end
end

% Save all user inputed data and reference to the raw data
save_progress(handles)

% Initialize fields
handles = rmfield(handles, 'ds');
handles = rmfield(handles, 'out');
handles = rmfield(handles, 'rcc_ind');
handles = rmfield(handles, 'lcc_ind');
handles = rmfield(handles, 'rmlo_ind');
handles = rmfield(handles, 'lmlo_ind');
handles = rmfield(handles, 'breast_density');
handles = rmfield(handles, 'remarks');
handles = rmfield(handles, 'status_ready');

% Initialize breast density
handles.breast_density = '0'; % initial situation when breast density has not been assessed (or is not possible to assess)

% Initialize remarks field
handles.remarks = '';

% Initialize im_compl variable, image not inverted
handles.im_compl = false;

if strcmp(hObject.Tag,'pushbutton_jump')
    handles.data_processing_information.study_index = user_input_study_idx;
end

if strcmp(eventdata.EventName,'WindowKeyPress')
    if strcmp(eventdata.Key,'leftarrow')
        handles.data_processing_information.study_index = current_study_index - 1;
    elseif strcmp(eventdata.Key,'rightarrow')
        handles.data_processing_information.study_index = current_study_index + 1;
    end
end

if strcmp(eventdata.EventName,'WindowKeyPress')
    % Check if annotation status is "1" and step forward
    if handles.data_processing_information.annotation_status(handles.data_processing_information.study_index) == 1
        study_idx_unannotated = find(handles.data_processing_information.annotation_status == 0); % studies which are not marked as ready, i.e. "1"
        if strcmp(eventdata.Key,'leftarrow')
            idxs = study_idx_unannotated(study_idx_unannotated < handles.data_processing_information.study_index);
            handles.data_processing_information.study_index = idxs(end);
        elseif strcmp(eventdata.Key,'rightarrow')
            idxs = study_idx_unannotated(study_idx_unannotated > handles.data_processing_information.study_index);
            handles.data_processing_information.study_index = idxs(1);
        end
    end
end

% Load data
handles = load_data(handles);

% Load annotation progress (if there is such)
handles = load_progress(handles);

% Set StudyInstanceUID to the corresponding Main_GUI field
set(handles.edit_study_instance_uid, 'string', num2str(handles.current_study)); 
    
% Initialize view
global current_view
current_view = '';
handles.current_view = current_view;
handles = switch_view(handles);

% Display image data
display_images(handles)

% Get the handles for right_view and left_view
hObj_right = findobj('Tag','right_view');
hObj_left = findobj('Tag','left_view');

right_view_handles = guidata(hObj_right);
left_view_handles = guidata(hObj_left);

% Update handles structure
guidata(hObject, handles)

% Update handles structure
guidata(hObj_right, right_view_handles);

% Update handles structure
guidata(hObj_left, left_view_handles);


% --------------------------------------------------------------------
function menu_view_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to menu_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_jump.
function pushbutton_jump_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_jump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get study to jump to
jump_to_study = get(handles.edit_study_instance_uid,'String'); % StudyInstanceUID

% Remove possible whitespace before and after the string
jump_to_study = strtrim(jump_to_study);

% Get study index
jump_to_idx = find(strcmp(handles.data_processing_information.studies, jump_to_study));

if isempty(jump_to_idx)
    uiwait(msgbox('Study was not found.','Go','help'));
    return;
end

% Handle the situation where all studies have been annotated
if all(handles.data_processing_information.annotation_status)
    uiwait(msgbox('All studies have been marked ready.','Go','help'));
    return;
end

% Check if annotation status of the inputted study is "1" and is so, do no-op
if handles.data_processing_information.annotation_status(jump_to_idx) == 1
    uiwait(msgbox('That particular study has been marked ready.','Go','help'));
    return;
end

handles = switch_study(hObject, eventdata, handles, jump_to_idx);

% Update handles structure
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function pushbutton_jump_CreateFcn(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to pushbutton_jump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function menu_item_view_mammography_views_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to menu_item_view_mammography_views (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% View View_R_GUI and View_L_GUI
if ~isempty(findobj('Tag','right_view')) && ~isempty(findobj('Tag','left_view'))
    return;
else
    display_images(handles)
end


function edit_study_instance_uid_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to edit_study_instance_uid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_study_instance_uid as text
%        str2double(get(hObject,'String')) returns contents of edit_study_instance_uid as a double


% --- Executes during object creation, after setting all properties.
function edit_study_instance_uid_CreateFcn(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to edit_study_instance_uid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_item_save_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to menu_item_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Save all user inputed data and reference to the raw data
save_progress(handles)


% --------------------------------------------------------------------
function menu_item_status_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to menu_item_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get main window position on the screen
window_position = getpixelposition(hObject.Parent.Parent);

study_idx = handles.data_processing_information.study_index;
result = edit_status(handles.data_processing_information.annotation_status(study_idx), window_position);
handles.data_processing_information.annotation_status(study_idx) = result.s;

% Update file with folder names and annotation status
handles = update_annotation_status(handles);

% Update handles structure
guidata(hObject, handles)


% --------------------------------------------------------------------
function menu_item_help_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to menu_item_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open tool documentation
%web(fullfile('','html','user_guide.html'))


% --------------------------------------------------------------------
function menu_item_remarks_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to menu_item_remarks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get main window position on the screen
window_position = getpixelposition(hObject.Parent.Parent);

result = edit_remarks(handles.remarks, window_position);
handles.remarks = result.r;

% Update handles structure
guidata(hObject, handles)


% --------------------------------------------------------------------
function menu_item_breast_density_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to menu_item_breast_density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get main window position on the screen
window_position = getpixelposition(hObject.Parent.Parent);

result = edit_breast_density(handles.breast_density, window_position);
handles.breast_density = result.d;

% Update handles structure
guidata(hObject, handles)


% --------------------------------------------------------------------
function menu_study_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to menu_study (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_item_study_list_Callback(hObject, eventdata, handles)
% hObject    handle to menu_item_study_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
