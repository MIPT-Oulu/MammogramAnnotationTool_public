function save_classification_as_csv(handles_main) % Antti mod 05.09.2021

% Get current study
study = handles_main.current_study;

% Get root dir
root_dir = handles_main.data_processing_information.root_dir;

filename = fullfile(root_dir, 'csv', strcat(study, '_classification', '.csv'));

[benign_left, benign_right, malignant_left, malignant_right] = get_classification(handles_main);

T = table({study},benign_right,benign_left,malignant_right,malignant_left);
T.Properties.VariableNames = {'Study','RightBenign','LeftBenign','RightMalignant','LeftMalignant'}; % Antti mod 6.4.2020 

% Save classification results
writetable(T,filename,'Delimiter',',','WriteRowNames',false,'FileType','text')

end