function handles = compl_image(handles)

% Changes truth value of a variable to switch between original and inverted image

% Complement/invert selected
handles.im_compl = ~handles.im_compl; 

end