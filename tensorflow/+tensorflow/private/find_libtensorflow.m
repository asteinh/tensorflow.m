function [lib_loc, lib_version] = find_libtensorflow(hints)
%FIND_LIBTENSORFLOW Searches for libtensorflow (library and header directories).
% Provide hints of paths (cell of strings) as an argument.

  % check if debug mode is activated
  if evalin('base', 'exist(''DEBUG'', ''var'')') == 0
    DEBUG = false;
  else
    DEBUG = evalin('base', 'DEBUG');
  end

  % check input arguments
  if nargin == 1 && ~isempty(hints) % hint or hints was/were given
    if ~iscell(hints) % hints is not a cell
      if ischar(hints) % hints is a single string
        hints = { hints };
      else
        error('Cannot interpret hints in the provided format.');
      end
    elseif any(~cellfun(@(c) ischar(c), hints)) % hints are in cell
      error('All hints must be strings.');
    end
  else
    hints = {}; % no hints provded
  end

  % append hints to search paths
  searchpaths = { pwd };
  for i = 1:length(hints)
    searchpaths = append(searchpaths, hints{i});
  end

  % platform dependencies
  if ispc
    userdir = getenv('USERPROFILE');
    libfile = 'tensorflow.dll';
    warning(['If you encounter errors, please consider checking <a href="https://github.com/tensorflow/tensorflow/issues/">the issues</a> in TensorFlow''s github repository. ', ...
             'Especially on Windows, there''s a number of bugs that need manual intervention, e.g. <a href="https://github.com/tensorflow/tensorflow/issues/31567">this issue</a>.']);
  else
    userdir = getenv('HOME');
    searchpaths = append(searchpaths, '/usr/');
    searchpaths = append(searchpaths, '/usr/local/');
    if ismac
      libfile = 'libtensorflow.dylib';
    elseif isunix
      libfile = 'libtensorflow.so';
    else
      error('Platform not supported.');
    end
  end

  searchpaths = append(searchpaths, userdir);
  searchpaths = append(searchpaths, fullfile([userdir, '/Downloads']));

  % traverse search paths
  for i = 1:length(searchpaths)
    p = searchpaths{i};
    % check pure path, but also with '*libtensorflow*' subfolders
    paths = { fullfile(p) };
    cont_dir = dir(paths{1});
    for j = 1:1:numel(cont_dir)
      if cont_dir(j).isdir && ~isempty(strfind(cont_dir(j).name, 'libtensorflow'))
        paths = [paths, { fullfile(p, '/', cont_dir(j).name) }];
      end
    end
    
    lib_loc = [];
    for k = 1:length(paths)
      rel = paths{k};
      if exist(rel, 'dir') % relative folder
        if DEBUG; fprintf('Searching in "%s" ...', rel); end
        dir_incl = fullfile(rel, '/include');
        dir_lib = fullfile(rel, '/lib');
        if ( exist(dir_incl, 'dir') && exist(fullfile(dir_incl, '/tensorflow/c/c_api.h'), 'file') ) ... % include folder and header file
          && ( exist(dir_lib, 'dir') && exist(fullfile(dir_lib, ['/' libfile]), 'file') ) % lib folder and library
          if DEBUG; fprintf('\n\t... found headers in "%s"', dir_incl); end
          if DEBUG; fprintf('\n\t... found libraries in "%s"\n', dir_lib); end
          if isempty(lib_loc)
            % first hit
            lib_version = get_version(rel);
            lib_loc = fullfile(rel);
            if DEBUG && strcmp(lib_version, '0.0.0'); fprintf('\tCould not retrieve version of libtensorflow in "%s".\n', rel);
            elseif DEBUG; fprintf('\tEncountered libtensorflow version %s\n', lib_version); end
          else
            % another hit
            lib_version_ = get_version(rel);
            if DEBUG && strcmp(lib_version_, '0.0.0'); fprintf('\tCould not retrieve version of libtensorflow in "%s".\n', rel); end
            if ver_isgreater(lib_version_, lib_version)
              if DEBUG; fprintf('\tUpdating libtensorflow with this location: version %s > %s\n', lib_version_, lib_version); end
              lib_version = lib_version_;
              lib_loc = fullfile(rel);
            else
              if DEBUG; fprintf('\tIgnoring libtensorflow in this location: version %s < %s\n', lib_version_, lib_version); end
            end
          end
        else
          if DEBUG; fprintf(' nothing found.\n'); end
        end
      else
        if DEBUG; fprintf('Skipping "%s" (does not exist).\n', rel); end
      end
    end
  end

  if ~isempty(lib_loc)
    return;
  else
    error('Couldn''t locate libtensorflow, sorry.');
  end
  
  % helper to append paths to search path cell
  function spc = append(spc, p)
    if strcmp(p(1:2),'./') || strcmp(p(1:3),'../')
      spc{end+1} = fullfile(pwd, p);
    else
      spc{end+1} = fullfile(p);
    end
  end

  % helper to extract version string from path
  function ver = get_version(path)
    res = regexp(path, '\d+(\.\d+){2}', 'match');
    if numel(res) == 1
      ver = res{1};
    else
      ver = '0.0.0';
    end
  end

  % helper to check if version A > version B
  function isg = ver_isgreater(strA, strB)
    isg = false;
    % two shortcuts
    if strcmp(get_version(strA), '0.0.0'); isg = false; return; end
    if strcmp(get_version(strB), '0.0.0'); isg = true; return; end
    % check
    verA_parts = strsplit(strA, '.');
    verB_parts = strsplit(strB, '.');
    for m = 1:1:3
      switch(cmp_str_double(verA_parts{m}, verB_parts{m}))
        case 2
          isg = true; return;
        case 0
          return;
        otherwise
          % nuffin
      end
    end
    
    function mode = cmp_str_double(a,b)
      if str2double(a) > str2double(b)
        mode = 2;
      elseif str2double(a) < str2double(b)
        mode = 0;
      else
        mode = 1;
      end
    end
  end

end
