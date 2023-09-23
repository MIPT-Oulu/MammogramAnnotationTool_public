function output = edit_breast_density(density, position)

dlg_title = {'Breast density asessement'};

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
rb3 = uicontrol(bg,'Style','radiobutton','Position',[10 30 291 15],'Tag','3');
rb4 = uicontrol(bg,'Style','radiobutton','Position',[10 10 291 15],'Tag','4');

% Set label
rb0.String = 'Undefined';
rb1.String = 'The breasts are almost entirely fatty';
rb2.String = 'There are scattered areas of fibroglandular density';
rb3.String = 'The breasts are heterogeneously dense';
rb4.String = 'The breasts are extremely dense';

% Create button and set label
btn = uicontrol(hFig,'Style','pushbutton','Position',[137 50 123 25],'String','OK','Callback','closereq');

if density == '0'
    selected_rb = rb0;
elseif density == '1'
    selected_rb = rb1;
elseif density == '2'
    selected_rb = rb2;
elseif density == '3'
    selected_rb = rb3;
elseif density == '4'
    selected_rb = rb4;
else
    selected_rb = rb0;
end

% Make the uibuttongroup visible after creating child objects
bg.Visible = 'on';

% Set the callbacks
set(bg,'SelectedObject',selected_rb);
set(bg,'SelectionChangeFcn',@buttongrp_SelectionChangeFcn_cb);

output.d = density;

% Wait for hFig to close before running to completion
uiwait(hFig);

    function buttongrp_SelectionChangeFcn_cb(~,eventdata)
        switch get(eventdata.NewValue, 'Tag')
            case '0'
                output.d = '0';
            case '1'
                output.d = '1';
            case '2'
                output.d = '2';
            case '3'
                output.d = '3';
            case '4'
                output.d = '4';
        end
    end

end