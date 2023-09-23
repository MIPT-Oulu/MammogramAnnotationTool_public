function num_masks = count_masks(mask)

% Binarize mask
binary_mask = imbinarize(mask, 0); 

% Count the number of non overlapping masks
[~, num_masks] = bwlabel(binary_mask);

clear mask binary_mask

end