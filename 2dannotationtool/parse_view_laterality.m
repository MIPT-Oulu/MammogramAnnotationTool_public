function [view, laterality] = parse_view_laterality(dicomnfo) % A. I. mod 3.4.2020 and 10.8.2023

% Handle different DICOM header variants

if sum(strcmp(fieldnames(dicomnfo), 'AcquisitionDeviceProcessingDescription')) == 1
    desc = strsplit(dicomnfo.AcquisitionDeviceProcessingDescription, ' ');
elseif sum(strcmp(fieldnames(dicomnfo), 'AcquisitionDeviceProcessingDescription')) == 0
    desc = {{' '},{' '}}; % FIXME
end

% Handle special cases
if strcmp(desc{1},'MLO') || ( sum(strcmp(fieldnames(dicomnfo), 'ViewPosition')) == 1 && strcmp(dicomnfo.ViewPosition,'RMLO') ) || ( sum(strcmp(fieldnames(dicomnfo), 'ViewPosition')) == 1 && strcmp(dicomnfo.ViewPosition,'LMLO') )
    view = 'MLO';
elseif strcmp(desc{1},'CC') || ( sum(strcmp(fieldnames(dicomnfo), 'ViewPosition')) == 1 && strcmp(dicomnfo.ViewPosition,'RCC') ) || ( sum(strcmp(fieldnames(dicomnfo), 'ViewPosition')) == 1 && strcmp(dicomnfo.ViewPosition,'LCC') )
    view = 'CC';
end

if strcmp(desc{2},'SIN') || ( sum(strcmp(fieldnames(dicomnfo), 'ViewPosition')) == 1 && strcmp(dicomnfo.ViewPosition,'LMLO') ) || ( sum(strcmp(fieldnames(dicomnfo), 'ViewPosition')) == 1 && strcmp(dicomnfo.ViewPosition,'LCC') )
    laterality = 'L';
elseif strcmp(desc{2},'DEX') || ( sum(strcmp(fieldnames(dicomnfo), 'ViewPosition')) == 1 && strcmp(dicomnfo.ViewPosition,'RMLO') ) || ( sum(strcmp(fieldnames(dicomnfo), 'ViewPosition')) == 1 && strcmp(dicomnfo.ViewPosition,'RCC') )
    laterality = 'R';
end

end