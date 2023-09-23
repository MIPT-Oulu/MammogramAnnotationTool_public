function makedir(foldername) % A. I. mod
%MAKEDIR Check if folder already exists and if not, then make one
% 
% See also FULLFILE

if ~exist(foldername, 'dir')
    mkdir(foldername);
end

end