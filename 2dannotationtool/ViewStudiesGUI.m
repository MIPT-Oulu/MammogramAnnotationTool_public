function varargout = ViewStudiesGUI(varargin) % H. H. mod 20.12.2020, A. I. mod 20.8.2023
% VIEWSTUDIESGUI MATLAB code for ViewStudiesGUI.fig
%      VIEWSTUDIESGUI, by itself, creates a new VIEWSTUDIESGUI or raises the existing
%      singleton*.
%
%      H = VIEWSTUDIESGUI returns the handle to a new VIEWSTUDIESGUI or the handle to
%      the existing singleton*.
%
%      VIEWSTUDIESGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWSTUDIESGUI.M with the given input arguments.
%
%      VIEWSTUDIESGUI('Property','Value',...) creates a new VIEWSTUDIESGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ViewStudiesGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ViewStudiesGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ViewStudiesGUI

% Last Modified by GUIDE v2.5 02-Dec-2020 03:16:14

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
    'gui_OpeningFcn', @ViewStudiesGUI_OpeningFcn, ...
    'gui_OutputFcn',  @ViewStudiesGUI_OutputFcn, ...
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


% --- Executes just before ViewStudiesGUI is made visible.
function ViewStudiesGUI_OpeningFcn(hObject, eventdata, handles_list, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ViewStudiesGUI (see VARARGIN)

% Choose default command line output for ViewStudiesGUI
handles_list.output = hObject;

% Create uitable for studies
column_names = {'StudyInstanceUID', 'Status', 'Date modified'};
uit = uitable('Parent',hObject,'Units','Normalized','ColumnWidth', {300,80,120},'OuterPosition',[0,0,1,1], 'ColumnName', column_names, 'Data',{});

% Add to uitable
uit.Tag = 'studies_uitable';
uit.CellSelectionCallback = @studies_window_CellSelectionCallback;

% Set window title
set(handles_list.studies_view, 'Name', 'Study status list');

% Update handles structure
guidata(hObject, handles_list);

% UIWAIT makes ViewStudiesGUI wait for user response (see UIRESUME)
% uiwait(handles_list.studies_view);


% --- Executes on key press with focus on left_view or any of its controls.
function view_studies_WindowKeyPressFcn(hObject, eventdata, handles_list)  %#ok<INUSD>
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


% --- Outputs from this function are returned to the command line.
function varargout = ViewStudiesGUI_OutputFcn(hObject, eventdata, handles_list) %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user dat a (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles_list.output;


function update_and_load_status(handles_main, update_true)

if nargin == 1
    update_true = false;
end

study_idx = handles_main.data_processing_information.study_index;
annotation_status = handles_main.data_processing_information.annotation_status(study_idx); % 'Ready', 'Incomplete', 'Pending' (default)

% Get current study
current_study = handles_main.current_study; % StudyInstanceUID

% Path to StudyInfo CSV file
path_to_studies_csv = fullfile(handles_main.data_processing_information.root_dir, handles_main.data_processing_information.studies_filename);

% Read studies csv and show the content on the uitable
studies_table = readtable(path_to_studies_csv, 'Delimiter', ',' ,'ReadVariableNames', true);

% Get studies, current status and dates modified columns from CSV file
studies = studies_table.StudyInstanceUID;
study_index = studies_table.StudyIndex;
status = studies_table.AnnotationStatus;
date_modified = studies_table.DateModified;

if update_true    
    % Find row for current_study (StudyInstanceUID)
    row_number = find(contains(studies, current_study));
    
    % Update annotation status
    status(row_number) = annotation_status; 
    
    % Update date modified
    date_now = datetime("now");
    date_modified(row_number) = datetime(date_now,'InputFormat','MM.dd.yyyy HH:mm:ss');
    
    % Update and save CSV
    studies_table.StudyIndex = study_index;
    studies_table.AnnotationStatus = status;
    studies_table.DateModified = date_modified;
    writetable(studies_table, path_to_studies_csv, 'Delimiter', ',');
end

% Data for uitable
data_table = {};
data_table(:,1) = studies;
%study_index is skipped in the table as redundant information
data_table(:,2) = num2cell(status);
data_table(:,3) = cellstr(date_modified);

% Get uitable
uit = findobj('Tag','studies_uitable');
set(uit, 'Data', data_table)

% Force display update
drawnow; 


% --- Executes when selected cell(s) is changed in studies_window.
function studies_window_CellSelectionCallback(hObject, eventdata, handles_list) %#ok<INUSD>
% hObject    handle to studies_window (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Handle situation when status is updated and the ViewStudiesGUI is open
if isempty(eventdata.Indices)
    return;
end

hObj_main = findobj('Tag','main_window');
handles_main = guidata(hObj_main);

% Get study to jump to
jump_to_study = hObject.Data{eventdata.Indices(1), 1}; % row and column, column 1 contains StudyInstanceUID

% Remove possible whitespace before and after the string
jump_to_study = strtrim(jump_to_study);

% Get study index
user_input_study_idx = find(strcmp(handles_main.data_processing_information.studies, jump_to_study),1);

Main_GUI('switch_study', hObj_main, eventdata, handles_main, user_input_study_idx);
