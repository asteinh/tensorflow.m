function exitcode = run_unittests(varargin)
  WITH_COVERAGE = false;

  exitcode = 1;

  if nargin > 0 && any(strcmpi('-with_coverage', varargin))
    WITH_COVERAGE = true;
  end

  addpath(fullfile(pwd, 'MOxUnit', 'MOxUnit'));
  addpath(fullfile(pwd, 'MOcov', 'MOcov'));
  moxunit_set_path();

  pkg_dir = fullfile(pwd, '..', 'tensorflow');
  if WITH_COVERAGE
    res_dir = fullfile(pwd, 'results');
    res = moxunit_runtests('unittests', '-verbose', ...
                           '-with_coverage', '-cover', pkg_dir, ...
                           '-cover_exclude', '@Ops', '-cover_exclude', '\+util', ...
                           '-cover_html_dir', fullfile(res_dir, 'html'), ...
                           '-cover_xml_file', fullfile(res_dir, 'coverage.xml'));
  else
    res = moxunit_runtests('unittests', '-verbose');
  end

  if res; exitcode = 0; end
end
