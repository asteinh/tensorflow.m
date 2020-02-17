function setup()
%SETUP Setup function of tensorflow.m
%  Builds the MEX interface, adds respective paths, etc.

  disp('Setting up tensorflow.m');
  tstart = tic;

  % 1) check if debug mode is activated
  if evalin('base', 'exist(''DEBUG'', ''var'')') == 0
    DEBUG = false;
  else
    DEBUG = evalin('base', 'DEBUG');
  end
  if DEBUG; disp('Debug mode active, will produce verbose output.'); end

  % 2) check if hints for the location of C library were given
  if evalin('base', 'exist(''LIBTENSORFLOW'', ''var'')') == 0
    LIBTENSORFLOW = '';
  else
    LIBTENSORFLOW = evalin('base', 'LIBTENSORFLOW');
    assert(ischar(LIBTENSORFLOW), 'Hint for location (LIBTENSORFLOW) must be provided as char array.');
  end

  % 3) adjust paths
  disp('Adding required paths ...');
  % add path, if not already added
  pkg_dir = fullfile(pwd, 'tensorflow');
  if DEBUG; disp(['Root folder of tensorflow.m: ' pkg_dir]); end

  paths_ = regexp(path, pathsep, 'split');
  required_paths = { pkg_dir, fullfile(pkg_dir, 'mex', 'build') };
  for i = 1:numel(required_paths)
    p = required_paths{i};
    if ( ispc && ~any(strcmpi(p, paths_))) || ...
       (~ispc && ~any(strcmp(p, paths_)))
      % not yet in path, add root folder
      if DEBUG; disp(['Folder ''' p ''' not found in path - adding it and saving the path.']); end
      addpath(p);
      savepath;
    else
      if DEBUG; disp(['Folder ''' p ''' already in path.']); end
    end
  end

  % 4) build MEX
  disp('Building MEX interface ...');
  warning('off', 'MATLAB:mex:GccVersion_link');
  util.bob.BuildEnvironment(pkg_dir, LIBTENSORFLOW);

  % 5) generate OPs
  op_dir = fullfile(pkg_dir, '+tensorflow', '@Ops');
  util.bob.OpGenerator(op_dir);

  tspent = toc(tstart);
  disp(['Setup of tensorflow.m successful. Took ' num2str(tspent) ' seconds.']);
end
