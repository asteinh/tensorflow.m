classdef BuildEnvironment < util.mixin.Base & util.mixin.Platform
  %BUILDENVIRONMENT Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private, GetAccess=public)
    lib = [];
    pkg = [];
    dirs = struct();
    filename = 'tensorflow_m_'; % the name of the resulting MEX interface
    executable = [];
  end

  methods
    function obj = BuildEnvironment(env_root, libhint)
      % root directory of build environment (i.e. package location)
      obj.pkg = env_root;

      % prepare build: setting properties and cleaning up
      obj.prepare();

      % find or download TensorFlow C library
      obj.lib = util.bob.LibHandler(obj, libhint);

      % build the MEX interface
      obj.build_mex_interface();
    end
  end

  methods (Access=private)
    function prepare(obj)
      obj.dirs.mex = fullfile(obj.pkg, 'mex');
      obj.dirs.out = fullfile(obj.dirs.mex, 'build');
      obj.executable = fullfile(obj.dirs.out, obj.filename);

      % clear possibly loaded MEXs
      if obj.platform.ismatlab
        [~, loaded] = inmem();
        for f = 1:1:numel(loaded)
          if ~isempty(strfind(loaded{f}, obj.filename))
            clear(loaded{f});
          end
        end
      end

      % delete existing file with identical name
      if exist([obj.executable '.' mexext], 'file') == 3
        delete([obj.executable '.' mexext]);
      end

      % cleanup build directory
      files = dir(obj.dirs.out);
      for f = files'
        if ~f.isdir && ~strcmpi(f.name, '.gitkeep')
          delete(fullfile(obj.dirs.out, f.name));
        end
      end
    end

    function build_mex_interface(obj)
      % include directories for building
      includedirs = { ...
        ['-I' fullfile(obj.dirs.mex, 'include')], ...
        ['-I' fullfile(obj.lib.path, 'include')] ...
      };

      % the source to be MEXed
      file = fullfile(obj.dirs.mex, 'src', [obj.filename '.c']);

      % additional sources
      sources = { ...
        fullfile(obj.dirs.mex, 'src', [obj.filename 'impl.c']), ...
        fullfile(obj.dirs.mex, 'src', [obj.filename 'util.c']) ...
      };

      % directories to be considered to resolve library dependencies
      libdirs = { ['-L' fullfile(obj.lib.path, 'lib')] };

      % library dependencies
      libs = { '-ltensorflow' };

      % helping Matlab to 'lib_tf.*' when executing the MEX function
      LD_RUN_PATH = getenv('LD_RUN_PATH');
      if isempty(strfind(LD_RUN_PATH, fullfile(obj.lib.path, 'lib')))
        setenv('LD_RUN_PATH', [fullfile(obj.lib.path, '/lib:'), LD_RUN_PATH]);
      end

      % MEXing, possibly in debug mode (= verbose build + debug symbols)
      if obj.platform.ismatlab
        % collected arguments for MEX
        mexargs = [ {'LDOPTIMFLAGS=-O3'}, ...
                    {['LDFLAGS=$LDFLAGS,-rpath,' fullfile(obj.lib.path, 'lib')]}, ...
                    includedirs(:)', ...
                    { file }, ...
                    sources(:)', ...
                    libdirs(:)', ...
                    libs(:)', ...
                    {'-outdir'}, { obj.dirs.out }, ...
                    {'-largeArrayDims'} ...
                  ];

        if obj.isdebug()
          mex('-v', '-g',  'CFLAGS=$CFLAGS -std=c99 -DDEBUG -g -ggdb3', mexargs{:});
        else
          mex('CFLAGS=$CFLAGS -std=c99', mexargs{:});
        end
      else
        % on Octave
        mkoctargs = [ { ['-Wl,-rpath ' fullfile(obj.lib.path, 'lib')] }, ...
                      includedirs(:)', ...
                      { file }, ...
                      sources(:)', ...
                      libdirs(:)', ...
                      libs(:)', ...
                      { '-o' }, { obj.executable }, ...
                      { '--mex' } ...
                    ];

        if obj.isdebug()
          [a, status] = mkoctfile('-v', '-g', mkoctargs{:});
          assert(status == 0, 'Irrecoverable error while building interface. Aborting.');
        else
          mkoctfile(mkoctargs{:});
        end
      end

      % TODO - find a nicer workaround for this:
      %   on Windows the MEX file won't find the DLL (unless it's on the
      %   system path...)
      if ispc
        copyfile(fullfile(obj.lib.path, 'lib', obj.lib.libfile), fullfile(obj.dirs.out, obj.lib.libfile));
      end
    end
  end
end
