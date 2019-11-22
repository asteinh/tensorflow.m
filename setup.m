function setup()
%SETUP Setup function of tensorflow.m
%  Builds the MEX interface, adds respective paths, etc.

  disp('Setting up tensorflow.m');

  % check if debug mode is activated
  if evalin('base', 'exist(''DEBUG'', ''var'')') == 0
    DEBUG = false;
  else
    DEBUG = evalin('base', 'DEBUG');
  end
  if DEBUG; disp('Debug mode active, will produce verbose output.'); end

  % check if hints for the location of C library were given
  if evalin('base', 'exist(''LIBTENSORFLOW'', ''var'')') == 0
    LIBTENSORFLOW = '';
  else
    LIBTENSORFLOW = evalin('base', 'LIBTENSORFLOW');
    assert(ischar(LIBTENSORFLOW), 'Hint for location (LIBTENSORFLOW) must be provided as char array.');
  end

  disp('Checking paths ...');
  % add path, if not already added
  pkg_dir = fullfile(pwd, 'tensorflow');
  if DEBUG; disp(['Root folder of tensorflow.m: ' pkg_dir]); end

  paths_ = regexp(path, pathsep, 'split');
  if ( ispc && ~any(strcmpi(pkg_dir, paths_))) || ...
     (~ispc && ~any(strcmp(pkg_dir, paths_)))
    % not yet in path, add root folder
    if DEBUG; disp('Root folder not found in path - adding it and saving the path.'); end
    addpath(pkg_dir);
    addpath(fullfile(pkg_dir, 'mex', 'build'));
    savepath;
  else
    if DEBUG; disp('Root folder already in path.'); end
  end
  
  % build it
  disp('Building MEX interface ...');
  benv = util.bob.BuildEnvironment(pkg_dir, LIBTENSORFLOW);
  benv.build();

  
  

  disp('Setup of tensorflow.m successful.');

end
