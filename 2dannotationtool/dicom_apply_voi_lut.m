function arr_out = dicom_apply_voi_lut(arr_in, nfo, index)
%DICOM_APPLY_VOI_LUT Apply a VOI lookup table or windowing operation to
% image data from a compliant DICOM file
%
% INPUTS
%    arr_in     image data from a compliant DICOM file
%    nfo        metadata from a compliant DICOM file
%    index      the index of the view (when the VOI LUT Module contains multiple alternative views)
%
% OUTPUTS:
%    out_arr    image data with applied VOI LUT or windowing operation
%
% See also DICOMINFO, DICOMREAD

% Author: Antti Isosalo, antti.isosalo@oulu.fi, University of Oulu, 2020-

% Method adapted from the Pydicom library function apply_voi_lut, 
% which is originally licensed under the following license:
% 
% Copyright (c) 2008-2020 Darcy Mason and pydicom contributors
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
%
% See: https://pydicom.github.io/
% See: https://github.com/pydicom/pydicom
% See: https://github.com/pydicom/pydicom/blob/b6709beba54f534418ad621e1832f20f4f5e0af2/pydicom/pixel_data_handlers/util.py#L263

if ~exist('index', 'var') ||  isempty(index)
    index = 1; % default value
end

if sum(strcmp(fieldnames(nfo), 'VOILUTSequence')) == 1
    items = nfo.VOILUTSequence;
    items = struct2cell(items);
    item1 = items{index};

    if ~isempty(item1.LUTDescriptor(1)) && any(item1.LUTDescriptor(1)) % empty or zero
        nr_entries = item1.LUTDescriptor(1);
    else
        nr_entries = 2^16;
    end
    
    first_map = item1.LUTDescriptor(2);

    nominal_depth = item1.LUTDescriptor(3);
    
    if any([10, 11, 12, 13, 14, 15, 16] == nominal_depth)
        dtype = 'uint16';
    elseif nominal_depth == 8
        dtype = 'uint8';
    else
        error('NotImplementedError:entryNotSupported',...
            'NotImplementedError. \n%s bits per LUT entry is not supported.',num2str(nominal_depth))
    end
    
    if strcmp(dtype,'uint16')
        lut_data = item1.LUTData;
        lut_data = uint16(lut_data);
    elseif strcmp(dtype,'uint8')
        lut_data = item1.LUTData;
        lut_data = uint8(lut_data);
    end
    
    if strcmp(class(arr_in), 'uint16')  %#ok<STISA>
        clipped_iv = uint16(zeros(size(arr_in)));
    elseif strcmp(class(arr_in), 'uint8') %#ok<STISA>
        clipped_iv = uint8(zeros(size(arr_in)));
    else
        error('NotImplementedError:inputArrayNotSupported',...
            'NotImplementedError. \nInput array type %s not supported.',class(arr_in))
    end
    
    mapped_pixels = arr_in >= first_map;
    
    clipped_iv(mapped_pixels) = arr_in(mapped_pixels) - first_map;
    
    clipped_iv(clipped_iv > (nr_entries - 1)) = (nr_entries - 1);
    
    [~, ~, ind] = unique(clipped_iv);
    clipped_iv_mapped = lut_data(ind);
    
    arr_out = reshape(clipped_iv_mapped, size(clipped_iv));
    
elseif sum(strcmp(fieldnames(nfo), 'WindowCenter')) == 1 && sum(strcmp(fieldnames(nfo), 'WindowWidth')) == 1
    if sum(strcmp(nfo.PhotometricInterpretation, 'MONOCHROME1')) == 0 && sum(strcmp(nfo.PhotometricInterpretation, 'MONOCHROME2')) == 0
        error('ValueError:photometricInterpretationNotAllowed',...
            'ValueError. \nOnly MONOCHROME1 and MONOCHROME2 are allowed for (0028,0004) Photometric Interpretation.')
    end
    
    if sum(strcmp(fieldnames(nfo), 'VOILUTFunction')) == 0 % no such field as VOILUTFunction
        voi_func = 'LINEAR';
    else
        voi_func = upper(nfo.VOILUTFunction); % convert to uppecase
    end
    
    data_elem_wc = nfo.WindowCenter;
    
    if isstruct(data_elem_wc) && sum(strcmp(fieldnames(data_elem_wc), 'VM')) == 0 && data_elem_wc.VM > 1
        center = data_elem_wc(index);
    else
        center = data_elem_wc;
    end
    
    data_elem_ww = nfo.WindowWidth;
    
    if isstruct(data_elem_ww) && sum(strcmp(fieldnames(data_elem_ww), 'VM')) == 0 && data_elem_ww.VM > 1
        width = data_elem_ww(index);
    else
        width = data_elem_ww;
    end
    
    % The output range depends on whether or not a modality LUT or rescale
    % operation has been applied
    if sum(strcmp(fieldnames(nfo), 'ModalityLUTSequence')) == 1 % unsigned
        y_min = 0;
        modality_lut_seq = nfo.ModalityLUTSequence;
        lut_desc = modality_lut_seq{1};
        bit_depth = lut_desc{2};
        y_max = int32(2^bit_depth - 1);
    elseif sum(strcmp(fieldnames(nfo), 'PixelRepresentation')) == 1 && nfo.PixelRepresentation == 0 % unsigned
        y_min = 0;
        y_max = int32(2^nfo.BitsStored - 1);
    else % signed
        y_min = -int32(2^(nfo.BitsStored - 1));
        y_max = int32(2^(nfo.BitsStored - 1) - 1);
    end
    
    if sum(strcmp(fieldnames(nfo), 'RescaleSlope')) == 1 && sum(strcmp(fieldnames(nfo), 'RescaleIntercept')) == 1
        y_min = y_min * nfo.RescaleSlope + nfo.RescaleIntercept;
        y_max = y_max * nfo.RescaleSlope + nfo.RescaleIntercept;
    end
    
    y_range = y_max - y_min;
    y_range = double(y_range);
    
    arr_in = double(arr_in);
    
    if strcmp(voi_func,'LINEAR') || strcmp(voi_func,'LINEAR_EXACT')
        if strcmp(voi_func,'LINEAR')
            if width < 1
                error('ValueError:invalidWindowWidth',...
                    'ValueError. \nWindow Width must be greater than or equal to 1 for a %s windowing operation.', 'LINEAR')
            end    
            
            center = center - 0.5;
            center = double(center);
            
            width = width - 1;
            width = double(width);
            
        elseif width <= 0
        	error('ValueError:invalidWindowWidth',...
                    'ValueError. \nWindow Width must be greater than 0 for a %s windowing operation.', 'LINEAR_EXACT')
        end        
        
        below = arr_in <= (center - width / 2);
        above = arr_in > (center + width / 2);
        
        between = and(~below,~above);    
        
        arr_in(below) = y_min;
        arr_in(above) = y_max;
        
        if any(between)
            arr_in(between) = ((arr_in(between) - center) / width + 0.5) * y_range + double(y_min);
        end
        
    elseif strcmp(voi_func,'SIGMOID')
        if width <= 0
            error('ValueError:invalidWindowWidth',...
                    'ValueError. \nWindow Width must be greater than 0 for a %s windowing operation.', 'SIGMOID')
        end
        arr_in = y_range ./ (1 + exp(-4 * (arr_in - center) / width)) + double(y_min);
    else
        error('ValueError:invalidWindowWidth',...
                    'ValueError. \nUnsupported (0028,1056) VOI LUT Function value %s.', voi_func)
    end
    
    arr_out = arr_in;
end

end
