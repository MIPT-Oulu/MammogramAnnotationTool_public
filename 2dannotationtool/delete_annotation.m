function [res, count, val] = delete_annotation(src, X, Y) % Antti mod 28.11.2019

% Removing colored areas, here segmentation masks, from src

%whos src % For debugging

% Get pixel color at (X,Y)
val = src(Y, X);

%disp(val) % For debugging

mask = src == val; % FIXME: There is an issue with this implementation when the masks partially overlap
res = src.*uint16(~mask);

count = count_masks(res);

clear src mask

end