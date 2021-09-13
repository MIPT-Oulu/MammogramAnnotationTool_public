function handles_main = switch_view(handles_main)

% Swich mammographic view from CC to MLO and vice versa

global current_view
%current_view = handles_main.current_view;

if isempty(current_view) || strcmp(current_view, 'MLO')
    current_view = 'CC';
    handles_main.current_view = current_view;
elseif strcmp(current_view, 'CC')
    current_view = 'MLO';
    handles_main.current_view = current_view;
else
    % do no-op
end

if strcmp(current_view, 'CC')
    res = cellfun(@(v)any(v(:)=='C'),{handles_main.ds.view});
elseif strcmp(current_view, 'MLO')
    res = cellfun(@(v)any(v(:)=='M'),{handles_main.ds.view});
end

handles_main.view_to_display = res;

end