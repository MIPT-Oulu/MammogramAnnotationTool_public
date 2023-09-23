function output = choose_dialog_architechtural_distortion(dlg_title, position)

% This dialog is shown after a ROI has been drawn

if iscell(dlg_title)
    dlg_title = cell2mat(dlg_title);
end

x_pos = position(1);
y_pos = position(2)-100;

%d = dialog('Position',[300 300 350 100],'Name',dlg_title);
d = dialog('Units','pixels','Position',[x_pos y_pos 350 110],'Name',dlg_title);

movegui(d,'center') % A. I. mod

txt_appearance = uicontrol('Parent',d,...
    'Style','text',...
    'Position',[20 80 130 20],...
    'String','Select appearance:');

popup_appearance = uicontrol('Parent',d,...
    'Style','popup',...
    'Position',[20 70 100 20],...
    'String',{'none';'convergent_spicules';'radiating_spicules';'radiating_lines';'retraction';'straightening';'parenchymal_scar';'blurring_of_tissue';'compression_of_tissue'},...
    'Callback',@popup_callback,...
    'Tag','appearance');

btn = uicontrol('Parent',d,...
    'Position',[130 10 70 25],...
    'String','Close',...
    'Callback','delete(gcf)');

align([txt_appearance popup_appearance],'Fixed',10,'Middle');
align(btn,'Center','Bottom');

output.choice_appearance = 'none';

% Wait for d to close before running to completion
uiwait(d);

       function popup_callback(popup,~)
          idx = popup.Value;
          popup_items = popup.String;
          if strcmp(popup.Tag,'appearance')
             output.choice_appearance = char(popup_items(idx,:));
          end
       end
   
end