function output = edit_status(status, position)

dlg_title = {'Change annotation status'};

if iscell(dlg_title)
    dlg_title = cell2mat(dlg_title);
end

x_pos = position(1);
y_pos = position(2)-100;

% Create dialog
%hFig = dialog('Position',[0 0 398 271],'Name',dlg_title);
hFig = dialog('Units','pixels','Position',[x_pos y_pos 398 271],'Name',dlg_title);

movegui(hFig, 'center') % A. I. mod

% Create button group
bg = uibuttongroup(hFig,'Position',[.14 .35 .72 .42]);

% Create radio buttons
rb0 = uicontrol(bg,'Style','radiobutton','Position',[10 90 291 15],'Tag','0');
rb1 = uicontrol(bg,'Style','radiobutton','Position',[10 70 291 15],'Tag','1');
rb2 = uicontrol(bg,'Style','radiobutton','Position',[10 50 291 15],'Tag','2');

% Set label
rb0.String = 'Pending (default)'; % (default)
rb1.String = 'Incomplete';
rb2.String = 'Ready'; 

% Create button and set label
btn = uicontrol(hFig,'Style','pushbutton','Position',[137 50 123 25],'String','OK','Callback','closereq'); %#ok<NASGU>

if strcmp(string(status), '2') % 'Ready'
    selected_rb = rb2;
elseif strcmp(string(status), '1') % 'Incomplete'
    selected_rb = rb1;
elseif strcmp(string(status), '0') % 'Pending (default)'
    selected_rb = rb0;
end

% Make the uibuttongroup visible after creating child objects
bg.Visible = 'on';

% Set the callbacks
set(bg,'SelectedObject',selected_rb);
set(bg,'SelectionChangeFcn',@buttongrp_SelectionChangeFcn_cb);

output.s = status;

% Wait for hFig to close before running to completion
uiwait(hFig);

    function buttongrp_SelectionChangeFcn_cb(~,eventdata)
        switch get(eventdata.NewValue, 'Tag')
            case '0'
                output.s = 0; % 'Pending (default)'
            case '1'
                output.s = 1; % 'Incomplete'
            case '2'
                output.s = 2; % 'Ready'
        end
    end

end