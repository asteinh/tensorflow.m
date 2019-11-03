function libtensorflow = locate_tensorflow(hints)
%LOCATE_TENSORFLOW Searches for libtensorflow (library and header directories).
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
    libext = 'dll';
  else
    userdir = getenv('HOME');
    searchpaths = append(searchpaths, '/usr/');
    searchpaths = append(searchpaths, '/usr/local/');
    if ismac
      libext = 'dylib';
    elseif isunix
      libext = 'so';
    else
      error('Platform not supported.');
    end
  end

  searchpaths = append(searchpaths, userdir);
  searchpaths = append(searchpaths, fullfile([userdir, '/Downloads']));

  % traverse search paths
  for i = 1:length(searchpaths)
    p = searchpaths{i};
    % check pure path, but also with 'libtensorflow' subfolder
    paths = { fullfile(p), fullfile(p, '/libtensorflow') };
    for k = 1:length(paths)
      rel = paths{k};
      if exist(rel, 'dir') % relative folder
        if DEBUG; disp(['Searching in "', rel, '" ...']); end
        dir_incl = fullfile(rel, '/include');
        dir_lib = fullfile(rel, '/lib');
        if ( exist(dir_incl, 'dir') && exist(fullfile(dir_incl, '/tensorflow/c/c_api.h'), 'file') ) ... % include folder and header file
          && ( exist(dir_lib, 'dir') && exist(fullfile(dir_lib, ['/libtensorflow.', libext]), 'file') ) % lib folder and library
          if DEBUG; disp(['Found headers in "', dir_incl, '"!']); end
          if DEBUG; disp(['Found libraries in "', dir_lib, '"!']); end
          libtensorflow = fullfile(rel);
          return;
        end
      else
        if DEBUG; disp(['Skipping "', rel, '" ...']); end
      end
    end
  end

  % we only land here if we couldn't find anything
  error('Couldn''t locate libtensorflow, sorry.');

  % helper to determine if string represents a relative path
  function ret = isrelpath(p)
    ret = false;
    if strcmp(p(1:2),'./') || strcmp(p(1:3),'../')
      ret = true;
    end
  end

  % helper to append paths to search path cell
  function spc = append(spc, p)
    if isrelpath(p)
      spc{end+1} = fullfile(pwd, p);
    else
      spc{end+1} = fullfile(p);
    end
  end

end
