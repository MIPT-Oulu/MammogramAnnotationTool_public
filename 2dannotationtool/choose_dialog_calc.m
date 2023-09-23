function output = choose_dialog_calc(dlg_title, position)

% This dialog is shown after a ROI has been drawn

if iscell(dlg_title)
    dlg_title = cell2mat(dlg_title);
end

x_pos = position(1);
y_pos = position(2)-100;

%d = dialog('Position',[300 300 350 110],'Name',dlg_title);
d = dialog('Units','pixels','Position',[x_pos y_pos 350 110],'Name',dlg_title);

movegui(d,'center') % A. I. mod

txt_morphology = uicontrol('Parent',d,...
    'Style','text',...
    'Position',[20 80 130 20],...
    'String','Select morphology:');

popup_morphology = uicontrol('Parent',d,...
    'Style','popup',...
    'Position',[20 70 100 20],...
    'String',{'none';'amorphous';'heterogeneous';'pleomorphic';'linear';'coarse';'round';'punctate';'casting';'indistinct'},... % ;'ring'},...
    'Callback',@popup_callback,...
    'Tag','morphology');

txt_distribution = uicontrol('Parent',d,...
    'Style','text',...
    'Position',[20 60 130 20],...
    'String','Select distribution:');

popup_distribution = uicontrol('Parent',d,...
    'Style','popup',...
    'Position',[20 50 100 20],...
    'String',{'none';'diffuse';'regional';'grouped';'linear';'segmental'},...
    'Callback',@popup_callback,...
    'Tag','distribution');

btn = uicontrol('Parent',d,...
    'Position',[130 10 70 25],...
    'String','Close',...
    'Callback','delete(gcf)');

align([txt_morphology popup_morphology],'Fixed',10,'Middle');
align([txt_distribution popup_distribution],'Fixed',10,'Bottom');
align(btn,'Center','None');

output.choice_morphology = 'none';
output.choice_distribution = 'none';

% Wait for d to close before running to completion
uiwait(d);

       function popup_callback(popup,~)
          idx = popup.Value;
          popup_items = popup.String;
          if strcmp(popup.Tag,'morphology')
             output.choice_morphology = char(popup_items(idx,:));
          elseif strcmp(popup.Tag,'distribution')
             output.choice_distribution = char(popup_items(idx,:));
          end
       end
   
end
