function output = add_remarks(remarks, position)

dlg_title = {'Remarks'};

if iscell(dlg_title)
    dlg_title = cell2mat(dlg_title);
end

x_pos = position(1);
y_pos = position(2)-100;

% Create dialog
%hFig = dialog('Position',[0 0 398 271],'Name',dlg_title);
hFig = dialog('Units','pixels','Position',[x_pos y_pos 398 271],'Name',dlg_title);

% Create edit box 
ebh = uicontrol(hFig, 'Style', 'edit',...
    'Position', [117 100 153 25],...
    'OuterPosition', [37 100 330 140],...
    'HorizontalAlignment', 'left',...
    'Tag', 'edit',...
    'CallBack', @remark_text_change_cb,...
    'max', 5);

set(ebh,'string', remarks);

% Create button and set label
btn = uicontrol(hFig, 'Style', 'pushbutton',...
    'Position', [137 50 123 25],...
    'String', 'OK',...
    'Callback', 'closereq'); %#ok<NASGU>

output.r = remarks;

% Wait for hFig to close before running to completion
uiwait(hFig);

    function [] = remark_text_change_cb(handles,~)
        output.r = get(handles,'string');
    end

end