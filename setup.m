function setup()
%SETUP Setup function of tensorflow.m
%  Builds the MEX interface, adds respective paths, etc.

  disp('Setting up tensorflow.m ...');

  % check if debug mode is activated
  if evalin('base', 'exist(''DEBUG'', ''var'')') == 0
    DEBUG = false;
  else
    DEBUG = evalin('base', 'DEBUG');
  end
  if DEBUG; disp('Debug mode active, will produce verbose output.'); end

  
  % add path, if not already added
  pkg_loc = fullfile(pwd, 'tensorflow');
  if DEBUG; disp(['Root folder of tensorflow.m: ' pkg_loc]); end
  
  paths_ = regexp(path, pathsep, 'split');
  if ( ispc && ~any(strcmpi(pkg_loc, paths_))) || ...
     (~ispc && ~any(strcmp(pkg_loc, paths_)))
    % not yet in path, add root folder
    if DEBUG; disp('Root folder not found in path - adding it and saving the path.'); end
    addpath(pkg_loc);
    savepath;
  else
    if DEBUG; disp('Root folder already in path.'); end
  end
  
  % build mex interface
  tensorflow.build(DEBUG);
  
  disp('Setup of tensorflow.m completed.');

end

