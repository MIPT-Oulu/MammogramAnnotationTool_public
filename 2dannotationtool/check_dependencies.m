function [checks_flag, required_products] = check_dependencies()

% Check that all required products are found

% Get MATLAB version
v = ver;

% Get a list of products which one or more files require to run
[~,pList] = matlab.codetools.requiredFilesAndProducts('Main_GUI.m');
required_products = {pList.Name}';

% Check that the user has all dependencies set up
for i=1:length(required_products)
    has_fsolve(i) = any(strcmp({v.Name}, cell2mat(required_products(i)))); %#ok<AGROW>
end
checks_flag = all(has_fsolve);

end