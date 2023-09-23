function newRange = imgwindowlevel(seedPt, currPt, origRange, deltaStep) % A. I. mod 22.11.2019
%IMGWINDOWLEVEL Adjust window/level
%   
% INPUTS:
%      seedPt          
%      currPt          
%      origRange       range of intensity values
%      deltaStep       the pace of window/level change
%
% OUTPUTS:
%      newRange        range after window/level
%
% See also CAXIS

% Method adapted from the WindowLevel function by H.J. Wisselink, which is 
% licensed under a CC by-nc-sa 4.0 license, adaptation re-licensed to MIT 
% license with permission for 'https://github.com/MIPT-Oulu/MammogramAnnotationTool_public'.
% See: https://www.mathworks.com/matlabcentral/fileexchange/66885-windowlevel
%      https://github.com/thrynae/WindowLevel
%      https://creativecommons.org/licenses/by-nc-sa/4.0/


seedPt = seedPt(1, :);
currPt = currPt(1, :);

deltaPos = double(deltaStep) * (seedPt - currPt);

level = mean(origRange);
window = diff(origRange);

level = level - deltaPos(2); % motion down will lower the level

window = window - deltaPos(1); % motion left will lower the window

if window < 0
    window = abs(window);
end

if window == 0
    window = 2 * eps * level;
end

newRange = level + [-0.5 0.5] * window;

end