classdef Base < handle
  %BASE Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private)
    hash = [];
    debug = false;
  end

  methods
    function obj = Base()
      obj.debug = obj.isdebug();
      obj.hash = util.KeyGen.sha1();
      obj.debugMsg('%s: created new object with hash %s\n', class(obj), obj.hash);
    end

    function delete(obj)
      obj.debugMsg('%s: deleting object with hash %s\n', class(obj), obj.hash);
    end
  end

  methods (Access=public)
    function debugMsg(obj, varargin)
      if obj.debug
        fprintf(varargin{:});
      end
    end
  end

  methods (Static)
    function deb = isdebug()
      % check if debug mode is activated
      if evalin('base', 'exist(''DEBUG'', ''var'')') == 0
        deb = false;
      else
        deb = evalin('base', 'DEBUG');
      end
    end
  end
end
