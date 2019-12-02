clear; clc

addpath(fullfile(pwd, 'MOxUnit', 'MOxUnit'));
addpath(fullfile(pwd, 'MOcov', 'MOcov'));
moxunit_set_path();

pkg_dir = fullfile(pwd, '..', 'tensorflow');
res_dir = fullfile(pwd, 'results');

moxunit_runtests('unittests', '-verbose', ...
                 '-with_coverage', '-cover', pkg_dir, ...
                 '-cover_exclude', '@Ops', '-cover_exclude', '\+util', ...
                 '-cover_json_file', fullfile(res_dir, 'coverage.json'));
