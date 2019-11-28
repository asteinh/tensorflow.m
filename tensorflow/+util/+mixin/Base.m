classdef Base < handle
  %BASE Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private)
    hash = [];
  end

  properties (Access=protected)
    debug = false;
    isMatlab = (exist('OCTAVE_VERSION', 'builtin') == 0);
  end

  properties (Constant)
    hash_generator = util.HashGen();
  end

  methods
    function obj = Base()
      obj.debug = obj.set_debug_mode();
      obj.hash = obj.hash_generator.sha1();
      obj.debugMsg('%s: created new object with hash %s\n', class(obj), obj.hash);
    end

    function d = isdebug(obj)
      d = obj.debug;
    end

    function delete(obj)
      obj.debugMsg('%s: deleting object with hash %s\n', class(obj), obj.hash);
    end
  end

  methods (Access=protected)
    function debugMsg(obj, varargin)
      if obj.debug
        fprintf(varargin{:});
      end
    end
  end

  methods (Static, Access=private)
    function deb = set_debug_mode()
      % check if debug mode is activated
      if evalin('base', 'exist(''DEBUG'', ''var'')') == 0
        deb = false;
      else
        deb = evalin('base', 'DEBUG');
      end
    end
  end
end
