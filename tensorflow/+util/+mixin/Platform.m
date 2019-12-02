classdef Platform < handle
  %PLATFORM Adds static information on executing platform and environment.
  %   ...

  properties (Constant)
    platform = struct( ...
      'ismatlab', (exist('OCTAVE_VERSION', 'builtin') == 0), ...
      'version', NaN ...  % TODO
    );
  end

end
