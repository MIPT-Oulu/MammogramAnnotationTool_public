function get_perimeter_rep(mask, handles_view, color_option)

% Get perimeter representation for a segmentation mask

if strcmp(color_option,'red')
    line_color = 'r';
elseif strcmp(color_option,'green')
    line_color = 'g';
elseif strcmp(color_option,'magenta')
    line_color = 'm';
elseif strcmp(color_option,'yellow')
    line_color = 'y';
elseif strcmp(color_option,'blue')
    line_color = 'b';
elseif strcmp(color_option,'cyan')
    line_color = 'c';
else
    line_color = 'k';
end

% Get annotation mask boundaries
[B,~,N] = bwboundaries(mask);

% Display object boundaries
hold(handles_view.axes_mammogram,'on'); %hold on; 
for k=1:length(B)
    boundary = B{k};
    if(k > N) % Antti mod 23.4.2020
        % do no-op
    else
        plot(boundary(:,2), boundary(:,1), 'Color', line_color, 'LineWidth', 2, 'Parent', handles_view.axes_mammogram);
    end
end
hold(handles_view.axes_mammogram,'off'); %hold off;

end