function save_breast_density_assessment(handles_main) % A. I. mod 05.09.2021

% Save breast density assessment as a CSV file accompanied with StudyInstanceUID 

% Get root dir
root_dir = handles_main.data_processing_information.root_dir; % root_dir for example 'C:\MatlabProjectFiles\MammoAnnotationTool\dataset\'

study = handles_main.current_study;
breast_density = handles_main.breast_density;

T = table({study},{breast_density});
T.Properties.VariableNames = {'Study','BreastDensity'};

filename = fullfile(root_dir, 'csv', strcat(study, '_breast_density', '.csv'));

% Save classification results
writetable(T,filename,'Delimiter',',','WriteRowNames',false,'FileType','text')

end