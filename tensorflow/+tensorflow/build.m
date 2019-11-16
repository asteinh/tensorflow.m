function build(DEBUG)
%BUILD ...
% ...

  % path considerations
  fullpath = mfilename('fullpath');
  [~, rem] = strtok(fliplr(fullpath), filesep);
  priv_dir = [fliplr(rem(2:end)) '/private'];
  mex_dir = fullfile([priv_dir '/../../mex']);

  % locate the tensorflow C library
  [lib_tf, ver_tf] = find_libtensorflow();

  % the name of the resulting MEX interface
  filename = 'tensorflow_m_';

  % include directories for building
  includedirs = { ...
    fullfile(['-I' mex_dir '/include']), ...
    fullfile(['-I' lib_tf '/include']) ...
  };

  % the source to be MEXed
  file = fullfile([mex_dir '/src/' filename '.c']);

  % additional sources
  sources = {};

  % directories to be considered to resolve library dependencies
  libdirs = { fullfile(['-L' lib_tf '/lib']) };

  % library dependencies
  libs = { '-ltensorflow' };

  % helping Matlab to 'lib_tf.*' when executing the MEX function
  LD_RUN_PATH = getenv('LD_RUN_PATH');
  if ~contains(LD_RUN_PATH, [lib_tf '/lib'])
    setenv('LD_RUN_PATH', [lib_tf, '/lib:', LD_RUN_PATH])
  end

  % collected arguments for MEX
  mexargs = [ {'LDOPTIMFLAGS=-O3'}, ...
              {['LDFLAGS=$LDFLAGS,-rpath,' lib_tf '/lib']}, ...
              includedirs(:)', ...
              {file}, ...
              sources(:)', ...
              libdirs(:)', ...
              libs(:)', ...
              {'-outdir'}, {fullfile([mex_dir '/build'])}, ...
              {'-largeArrayDims'} ...
            ];

  % MEXing, possibly in debug mode (= verbose build + debug symbols)
  if DEBUG
    mex('-v', '-g',  'CFLAGS=$CFLAGS -std=c99 -DDEBUG -g -ggdb3', mexargs{:});
  else
    mex('CFLAGS=$CFLAGS -std=c99', mexargs{:});
  end

  % move MEX file to private package folder
  private_mex = fullfile([priv_dir '/' filename '.' mexext]);
  if exist(private_mex, 'file') == 3
    delete(private_mex);
  end
  copyfile(fullfile([mex_dir '/build/' filename '.' mexext]), private_mex);

  disp('Built tensorflow.m MEX interface.');
end
