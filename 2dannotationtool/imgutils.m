function imgutils(hfig, varargin)  % A. I. mod 22.11.2019
%IMGUTILS Instant mouse zoom and pan, and window/level.
%
% INPUTS:
%
% 'Magnify' General magnitication factor. 1.0 or greater (default: 1.1). A value of 2.0
%             solves the zoom and pan deformations caused by MATLAB's embedded image resize method.
% 'XMagnify'        Magnification factor of X axis (default: 1.0).
% 'YMagnify'        Magnification factor of Y axis (default: 1.0).
% 'ChangeMagnify'.  Relative increase of the magnification factor. 1.0 or greater (default: 1.1).
% 'IncreaseChange'  Relative increase in the ChangeMagnify factor. 1.0 or greater (default: 1.1).
% 'MinValue' Sets the minimum value for Magnify, ChangeMagnify and IncreaseChange (default: 1.1).
% 'MaxZoomScrollCount' Maximum number of scroll zoom-in steps; might need adjustements depending
%                        on your image dimensions & Magnify value (default: 30).
%
% 'ImgWidth' Original image pixel width. A value of 0 disables the functionality that prevents the
%            user from zooming outside of the image.
% 'ImgHeight' Original image pixel height. A value of 0 disables the functionality that prevents the
%            user from zooming outside of the image.
%
% OUTPUTS:
%  none
%
% See also HITTEST, ANCESTOR

% Requires imgwindowlevel.m

% Modified from the imgzoompan (see original licence below) function with permission.

% Simplified BSD License
% 
% Copyright (c) 2018 Dany Alejandro Cabrera Vargas, University of Victoria, Canada
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
% * Redistributions of source code must retain the above copyright notice,
%   this list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright
%   notice, this list of conditions and the following disclaimer in the
%   documentation and/or other materials provided with the distribution.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% 
% See: https://github.com/danyalejandro/imgzoompan

% Parse configuration options
p = inputParser;

% Zoom configuration options
p.addOptional('Magnify', 1.1, @isnumeric);
p.addOptional('XMagnify', 1.0, @isnumeric);
p.addOptional('YMagnify', 1.0, @isnumeric);
p.addOptional('ChangeMagnify', 1.1, @isnumeric);
p.addOptional('IncreaseChange', 1.1, @isnumeric);
p.addOptional('MinValue', 1.1, @isnumeric);
p.addOptional('MaxZoomScrollCount', 30, @isnumeric);

% Pan configuration options
p.addOptional('ImgWidth', 0, @isnumeric);
p.addOptional('ImgHeight', 0, @isnumeric);

% Mouse options and callbacks
p.addOptional('WindowLevelMouseButton', 2, @isnumeric);  % A. I. mod
p.addOptional('PanMouseButton', 1, @isnumeric);
p.addOptional('ResetMouseButton', 3, @isnumeric);
p.addOptional('ButtonDownFcn',  @(~,~) 0);
p.addOptional('ButtonUpFcn', @(~,~) 0);

parse(p, varargin{:});
opt = p.Results;

if opt.Magnify<opt.MinValue
    opt.Magnify=opt.MinValue;
end
if opt.ChangeMagnify<opt.MinValue
    opt.ChangeMagnify=opt.MinValue;
end
if opt.IncreaseChange<opt.MinValue
    opt.IncreaseChange=opt.MinValue;
end

% Set up callback functions
set(hfig, 'WindowScrollWheelFcn', @zoom_fcn_cb);
set(hfig, 'WindowButtonDownFcn', @mouse_button_down_fcn_cb);
set(hfig, 'WindowButtonUpFcn', @mouse_button_up_fcn_cb);

zoomScrollCount = 0;
orig.h=[];
orig.XLim=[];
orig.YLim=[];

    function zoom_fcn_cb(~, cbdata)
        scrollChange = cbdata.VerticalScrollCount; % -1: zoomIn, 1: zoomOut
        
        if ((zoomScrollCount - scrollChange) <= opt.MaxZoomScrollCount)
            % Fixes issue when zooming is atempted while mouse is over
            % one window and another window is active
            if strcmp(cbdata.Source.Tag, 'left_view') % A. I. mod
                hObj_left = findobj('Tag','left_view');
                left_view_handles = guidata(hObj_left);
                axish = left_view_handles.axes_mammogram;
            elseif strcmp(cbdata.Source.Tag, 'right_view') % A. I. mod
                hObj_right = findobj('Tag','right_view');
                right_view_handles = guidata(hObj_right);
                axish = right_view_handles.axes_mammogram;
            end
                
            if ~(strcmp(axish.Parent.Tag, 'right_view') || strcmp(axish.Parent.Tag, 'left_view')) || strcmp(axish.Parent.Tag, 'main_window') % A. I. mod
                return;
            end
            
            if (isempty(orig.h) || axish ~= orig.h)
                orig.h = axish;
                orig.XLim = axish.XLim;
                orig.YLim = axish.YLim;
            end
            
            % Calculate the new XLim and YLim
            cpaxes = mean(axish.CurrentPoint);
            newXLim = (axish.XLim - cpaxes(1)) * (opt.Magnify * opt.XMagnify)^scrollChange + cpaxes(1);
            newYLim = (axish.YLim - cpaxes(2)) * (opt.Magnify * opt.YMagnify)^scrollChange + cpaxes(2);
            
            newXLim = floor(newXLim);
            newYLim = floor(newYLim);
            
            % Check for image border location only if user provided ImgWidth
            if (opt.ImgWidth > 0)
                if (newXLim(1) >= 0 && newXLim(2) <= opt.ImgWidth && newYLim(1) >= 0 && newYLim(2) <= opt.ImgHeight)
                    axish.XLim = newXLim;
                    axish.YLim = newYLim;
                    zoomScrollCount = zoomScrollCount - scrollChange;
                else
                    axish.XLim = orig.XLim;
                    axish.YLim = orig.YLim;
                    zoomScrollCount = 0;
                end
            else
                axish.XLim = newXLim;
                axish.YLim = newYLim;
                zoomScrollCount = zoomScrollCount - scrollChange;
            end
            
        end
    end

    function mouse_button_down_fcn_cb(hObj, evt)  % A. I. mod
        opt.ButtonDownFcn(hObj, evt); % First, run callback from options
        
        clickType = evt.Source.SelectionType;
        
        % Panning action
        panBt = opt.PanMouseButton;
        if (panBt > 0)
            if (panBt == 1 && strcmp(clickType, 'normal'))  % A. I. mod
                
                guiArea = hittest(hObj);  % A. I. mod
                parentAxes = ancestor(guiArea,'axes');  % A. I. mod
                
                curr_ptr = get(evt.Source,'Pointer');  % A. I. mod
                % If the mouse is over the desired axis, trigger the pan fcn
                if ~isempty(parentAxes) && (strcmp(evt.Source.CurrentAxes.Parent.Tag, 'right_view') || strcmp(evt.Source.CurrentAxes.Parent.Tag, 'left_view')) && strcmp(curr_ptr, 'arrow') % A. I. mod
                    startPan(parentAxes)
                else
                    %setptr(evt.Source,'forbidden')  % A. I. mod
                end
            end
        end
        windowLevelBt = opt.WindowLevelMouseButton;  % A. I. mod
        if (windowLevelBt > 0)  % A. I. mod
            if (windowLevelBt == 2 && strcmp(clickType, 'alt'))
                
                guiArea = hittest(hObj);  % A. I. mod
                parentAxes = ancestor(guiArea,'axes');  % A. I. mod
                
                curr_ptr = get(evt.Source,'Pointer');  % A. I. mod
                if ~isempty(parentAxes) && (strcmp(evt.Source.CurrentAxes.Parent.Tag, 'right_view') || strcmp(evt.Source.CurrentAxes.Parent.Tag, 'left_view')) && strcmp(curr_ptr, 'arrow')  % A. I. mod
                    startWindowLevel(parentAxes)
                else
                    %setptr(evt.Source,'forbidden')
                end
            end
        end
    end

    function mouse_button_up_fcn_cb(hObj, evt)
        opt.ButtonUpFcn(hObj, evt); % First, run callback from options
        
        clickType = evt.Source.SelectionType;
        
        resBt = opt.ResetMouseButton;
        if (resBt > 0 && ~isempty(orig.XLim))
            if (resBt == 3 && strcmp(clickType, 'extend'))  % A. I. mod
                
                guiArea = hittest(hObj);
                parentAxes = ancestor(guiArea,'axes');
                parentAxes.XLim=orig.XLim;
                parentAxes.YLim=orig.YLim;
                
            end
        end
        
        stopPan
        
    end

    function startPan(hAx)
        % Take in desired Axis to pan
        hFig = ancestor(hAx, 'Figure', 'toplevel');   % Parent Fig
        
        seedPt = get(hAx, 'CurrentPoint'); % Get init mouse position
        seedPt = seedPt(1, :); % Keep only 1st
        
        % Temporarily stop 'auto resizing'
        hAx.XLimMode = 'manual';
        hAx.YLimMode = 'manual';
        
        set(hFig,'WindowButtonMotionFcn',{@panningFcn,hAx,seedPt});
        setptr(hFig, 'hand'); % Assign 'Panning' cursor
    end

    function stopPan
        set(gcbf,'WindowButtonMotionFcn',[]);
        setptr(gcbf,'arrow');
    end

    function startWindowLevel(hAx)  % A. I. mod
        % Take in desired Axis to pan
        hFig = ancestor(hAx, 'Figure', 'toplevel'); % Parent Fig
        
        %disp(hFig.CurrentObject.XData(2)) % For debugging
        %disp(hFig.CurrentObject.YData(2))
        
        seedPt = get(hAx, 'CurrentPoint'); % Get initial mouse position
        %disp(seedPt) % For debugging
        
        origValueRange = clim(hAx); % A. I. mod 10.8.2023
        
        set(hFig,'WindowButtonMotionFcn',{@windowLevelFcn,hAx,seedPt,origValueRange});
        [cdata, ptr_hotspot] = get_custom_ptr_params();
        set(hFig,'Pointer','custom','PointerShapeCData',cdata,'PointerShapeHotSpot',ptr_hotspot) % Assign 'Window/Level' cursor
    end

    function windowLevelFcn(~,~,hAx,seedPt,origRange) % A. I. mod
        
        try 
            % Get current mouse position
            currPt = get(hAx,'CurrentPoint');
            
            deltaStep = 0.5; % Sets the pace of window/level change
            newRange = imgwindowlevel(seedPt,currPt,origRange,deltaStep); % A. I. mod
            
             % Pseudocolor axis scaling
            clim(hAx, newRange); % A. I. mod 10.8.2023
        catch
            % do no-op
        end
        
    end

    function panningFcn(~,~,hAx,seedPt) % Controls the real-time panning on the desired axis
        
        % Get current mouse position
        currPt = get(hAx,'CurrentPoint');
        
        % Current Limits [absolute vals]
        XLim = hAx.XLim;
        YLim = hAx.YLim;
        
        % Original (seed) and Current mouse positions [relative (%) to axes]
        x_seed = (seedPt(1)-XLim(1))/(XLim(2)-XLim(1));
        y_seed = (seedPt(2)-YLim(1))/(YLim(2)-YLim(1));
        
        x_curr = (currPt(1,1)-XLim(1))/(XLim(2)-XLim(1));
        y_curr = (currPt(1,2)-YLim(1))/(YLim(2)-YLim(1));
        
        % Change in mouse position [delta relative (%) to axes]
        deltaX = x_curr-x_seed;
        deltaY = y_curr-y_seed;
        
        % Calculate new axis limits based on mouse position change
        newXLims(1) = -deltaX*diff(XLim)+XLim(1);
        newXLims(2) = newXLims(1)+diff(XLim);
        
        newYLims(1) = -deltaY*diff(YLim)+YLim(1);
        newYLims(2) = newYLims(1)+diff(YLim);
        
        % Round the axis limits
        newXLims = round(newXLims); % Lack of anti-aliasing in MATLAB deforms the image if XLims and YLims are not integers
        newYLims = round(newYLims);
        
        % Update Axes limits
        if (newXLims(1) > 0.0 && newXLims(2) < opt.ImgWidth)
            set(hAx,'Xlim',newXLims);
        end
        if (newYLims(1) > 0.0 && newYLims(2) < opt.ImgHeight)
            set(hAx,'Ylim',newYLims);
        end
    end

    function [cdata, hotspot] = get_custom_ptr_params()  % A. I. mod 22.11.2019
        
        % Custom pointer image for window/level functionality
        cdata = [...
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     1     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     1     1     1     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     1     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     1     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2    NaN   NaN   NaN    2    NaN    2    NaN   NaN   NaN    2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     1     2     2     2     2     1     2     2     2     2     2     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     1     1     1     1    NaN    1     1     1    NaN    1     1     1     1     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     1     2     2     2     2     1     2     2     2     2     2     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2    NaN   NaN   NaN    2    NaN    2    NaN    2     2     2     2     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     1     2     2     2     1     1     1     1     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     1     2     2     1     1     1     2     1     1     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     1     1     1     2     1     1     1     2     2     1     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     1     2     2     1     1     1     2     2     1     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2    NaN    2     1     1     1     2     1     1     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     1     1     1     1     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    2     2     2     2    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
            NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
        ]; % 32x32 array
        
        % Pointer hotspot
        hotspot = [16 16];
        
    end

end