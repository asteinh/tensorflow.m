classdef BuildEnvironment < util.mixin.Base
  %BUILDENVIRONMENT Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private, GetAccess=public)
    lib = [];
    pkg = [];
    dir = struct();
    filename = 'tensorflow_m_'; % the name of the resulting MEX interface
    mexfile = [];
  end

  methods
    function obj = BuildEnvironment(pkg_dir, libhint)
      obj.pkg = pkg_dir;
      obj.prepare();
      obj.lib = util.bob.LibHandler(obj, libhint);
      obj.build();
      obj.postprocessing();
    end
  end
  
  methods (Access=private)
    function prepare(obj)
      obj.dir.mex = fullfile(obj.pkg, 'mex');
      obj.dir.out = fullfile(obj.dir.mex, 'build');
      obj.mexfile = fullfile(obj.dir.out, [obj.filename '.' mexext]);
      
      % clear possibly loaded MEXs
      [~, loaded] = inmem();
      for f = 1:1:numel(loaded)
        if ~isempty(strfind(loaded{f}, obj.filename))
          clear(loaded{f});
        end
      end
      
      % delete existing file with identical name
      if exist(obj.mexfile, 'file') == 3
        delete(obj.mexfile);
      end
    end

    function build(obj)
      % include directories for building
      includedirs = { ...
        ['-I' fullfile(obj.dir.mex, 'include')], ...
        ['-I' fullfile(obj.lib.path, 'include')] ...
      };

      % the source to be MEXed
      file = fullfile(obj.dir.mex, 'src', [obj.filename '.c']);

      % additional sources
      sources = {};

      % directories to be considered to resolve library dependencies
      libdirs = { ['-L' fullfile(obj.lib.path, 'lib')] };

      % library dependencies
      libs = { '-ltensorflow' };

      % helping Matlab to 'lib_tf.*' when executing the MEX function
      LD_RUN_PATH = getenv('LD_RUN_PATH');
      if ~contains(LD_RUN_PATH, fullfile(obj.lib.path, 'lib'))
        setenv('LD_RUN_PATH', [fullfile(obj.lib.path, '/lib:'), LD_RUN_PATH]);
      end

      % collected arguments for MEX
      mexargs = [ {'LDOPTIMFLAGS=-O3'}, ...
                  {['LDFLAGS=$LDFLAGS,-rpath,' fullfile(obj.lib.path, 'lib')]}, ...
                  includedirs(:)', ...
                  { file }, ...
                  sources(:)', ...
                  libdirs(:)', ...
                  libs(:)', ...
                  {'-outdir'}, { obj.dir.out }, ...
                  {'-largeArrayDims'} ...
                ];

      % MEXing, possibly in debug mode (= verbose build + debug symbols)
      if obj.isdebug()
        mex('-v', '-g',  'CFLAGS=$CFLAGS -std=c99 -DDEBUG -g -ggdb3', mexargs{:});
      else
        mex('CFLAGS=$CFLAGS -std=c99', mexargs{:});
      end
    end
    
    function postprocessing(obj)
      % TODO - find a nicer workaround for this:
      %   on Windows the MEX file won't find the DLL (unless it's on the
      %   system path...)
      if ispc
        copyfile(fullfile(obj.lib.path, 'lib', obj.lib.libfile), fullfile(obj.dir.out, obj.lib.libfile));
      end
    end
  end
end
