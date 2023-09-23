function [x, y] = select_point(hAx) % A. I. mod

% Create customizable point ROI, https://www.mathworks.com/help/images/ref/drawpoint.html
%roi = drawpoint(hAx, 'InteractionsAllowed', 'none', 'Visible', 'on', 'Color','k');

% Create customizable crosshair ROI, https://www.mathworks.com/help/images/ref/drawcrosshair.html
roi = drawcrosshair(hAx,'InteractionsAllowed', 'none', 'Visible', 'on', 'LineWidth', 1, 'Color', 'y');

if isempty(roi.Position)
    x = [];
    y = [];
    return;
end

x = roi.Position(1);
y = roi.Position(2);

end