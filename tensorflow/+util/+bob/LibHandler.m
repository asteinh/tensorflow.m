classdef LibHandler < util.mixin.Base
  %LIBHANDLER Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private, GetAccess=public)
    path = [];
    version = [];
    searchpaths = {};
    libfile = [];
  end

  methods
    function obj = LibHandler(benv, hints)
      obj.prepare();

      if ~isempty(hints)
        % manually supplied hint
        obj.debugMsg('Checking manually supplied search paths for TensorFlow C library ...\n');
        [obj.path, obj.version] = obj.search_for_library(hints);
        assert(~isempty(obj.path), 'TensorFlow C library could not be found in manually supplied path - aborting.');
      else
        % check default paths
        obj.debugMsg('Checking default search paths for TensorFlow C library ...\n');
        [obj.path, obj.version] = obj.search_for_library(obj.searchpaths);
        if isempty(obj.path)
          % otherwise download it
          obj.debugMsg('Automatically obtaining TensorFlow C library ...\n');
          [obj.path, obj.version] = obj.download_library(benv);
        end
      end

      assert(~isempty(obj.path), 'Something went wrong while setting up things for the TensorFlow C library.');
    end
  end

  methods (Access=private)
    function [location, version] = download_library(obj, benv)
      version = '1.15.0';

      if ismac
        % macOS (CPU only)
        fname = ['libtensorflow-cpu-darwin-x86_64-' version];
        fext = 'tar.gz';
      elseif isunix
        % Linux (CPU only)
        fname = ['libtensorflow-cpu-linux-x86_64-' version];
        fext = 'tar.gz';
      else % must be Windows, after prepare() already checked for unknown system
        % Windows (CPU only)
        fname = ['libtensorflow-cpu-windows-x86_64-' version];
        fext = 'zip';
      end

      location = fullfile(benv.dirs.mex, 'third_party', fname);

      if exist(location, 'dir') == 0
        dl_link = ['https://storage.googleapis.com/tensorflow/libtensorflow/' fname '.' fext];
        dl_file = fullfile(tempdir, [fname '.' fext]);
        if exist(dl_file, 'file') ~= 2
          obj.debugMsg('Downloading TensorFlow C library ...\n');
          websave(dl_file, dl_link);
        else
          obj.debugMsg('Using TensorFlow C library archive already present in temp directory.\n');
        end

        obj.debugMsg('Extracting TensorFlow C library ...\n');
        if strcmp(fext, 'zip')
          unzip(dl_file, location);
        else
          [s,c] = system(['mkdir -p ' location ' && tar -xzf ' dl_file ' --directory ' location]);
          assert(s==0, 'Untar failed, setup aborted. The command returned:\n%s', c)
        end
      end
    end

    function prepare(obj)
      % platform specific
      if ispc
        userdir = getenv('USERPROFILE');
        obj.libfile = 'tensorflow.dll';
        warning(['If you encounter errors, please consider checking <a href="https://github.com/tensorflow/tensorflow/issues/">the issues</a> in TensorFlow''s github repository. ', ...
                 'Especially on Windows, there''s a number of bugs that need manual intervention, e.g. <a href="https://github.com/tensorflow/tensorflow/issues/31567">this issue</a>.']);
      else
        userdir = getenv('HOME');
        obj.searchpaths = [obj.searchpaths, { '/usr/' }];
        obj.searchpaths = [obj.searchpaths, { '/usr/local/' }];
        if ismac
          obj.libfile = 'libtensorflow.dylib';
        elseif isunix
          obj.libfile = 'libtensorflow.so';
        else
          error('Platform not supported.');
        end
      end
      obj.searchpaths = [obj.searchpaths, { userdir }];
      obj.searchpaths = [obj.searchpaths, { fullfile(userdir, 'Downloads') }];
    end

    function [location, version] = search_for_library(obj, searchpaths)
      % check input arguments
      assert(nargin == 2, 'Wrong number of input arguments.');
      if ischar(searchpaths)
        searchpaths = { searchpaths };
      end

      for i = 1:length(searchpaths)
        p = searchpaths{i};

        % check pure path, but also with '*libtensorflow*' subfolders
        paths = { fullfile(p) };
        cont_dir = dir(paths{1});
        for j = 1:1:numel(cont_dir)
          if cont_dir(j).isdir && ~isempty(strfind(cont_dir(j).name, 'libtensorflow'))
            paths = [paths, { fullfile(p, cont_dir(j).name) }];
          end
        end

        location = [];
        version = [];
        for k = 1:length(paths)
          rel = paths{k};
          if exist(rel, 'dir') % relative folder
            obj.debugMsg('Searching in "%s" ...', rel);
            dir_incl = fullfile(rel, '/include');
            dir_lib = fullfile(rel, '/lib');
            if ( exist(dir_incl, 'dir') && exist(fullfile(dir_incl, '/tensorflow/c/c_api.h'), 'file') ) ... % include folder and header file
              && ( exist(dir_lib, 'dir') && exist(fullfile(dir_lib, obj.libfile), 'file') ) % lib folder and library
              obj.debugMsg('\n\t... found headers in "%s"', dir_incl);
              obj.debugMsg('\n\t... found libraries in "%s"\n', dir_lib);
              if isempty(location)
                % first hit
                version = obj.get_version(rel);
                location = fullfile(rel);
                if strcmp(version, '0.0.0')
                  obj.debugMsg('\tCould not retrieve version of libtensorflow in "%s".\n', rel);
                else
                  obj.debugMsg('\tEncountered libtensorflow version %s\n', version);
                end
              else
                % another hit
                version_ = obj.get_version(rel);
                if strcmp(version_, '0.0.0')
                  obj.debugMsg('\tCould not retrieve version of libtensorflow in "%s".\n', rel);
                end
                if ver_isgreater(version_, version)
                  obj.debugMsg('\tUpdating libtensorflow with this location: version %s > %s\n', version_, version);
                  version = version_;
                  location = fullfile(rel);
                else
                  obj.debugMsg('\tIgnoring libtensorflow in this location: version %s < %s\n', version_, version);
                end
              end
            else
              obj.debugMsg(' nothing found.\n');
            end
          else
            obj.debugMsg('Skipping "%s" (does not exist).\n', rel);
          end
        end
      end
    end

    % helper to check if version A > version B
    function isg = ver_isgreater(strA, strB)
      isg = false;
      % two shortcuts
      if strcmp(obj.get_version(strA), '0.0.0'); isg = false; return; end
      if strcmp(obj.get_version(strB), '0.0.0'); isg = true; return; end
      % check
      verA_parts = strsplit(strA, '.');
      verB_parts = strsplit(strB, '.');
      for m = 1:1:3
        if str2double(verA_parts{m}) > str2double(verB_parts{m})
          isg = true;
          return;
        elseif str2double(verA_parts{m}) < str2double(verB_parts{m})
          return;
        else
          % nuffin
        end
      end
    end
  end

  methods (Static, Access=private)
    % helper to extract version string from path
    function ver = get_version(path)
      res = regexp(path, '\d+(\.\d+){2}', 'match');
      if numel(res) == 1
        ver = res{1};
      else
        ver = '0.0.0';
      end
    end
  end
end
