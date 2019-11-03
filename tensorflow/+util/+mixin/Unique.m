classdef Unique < handle
  %UNIQUE Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private)
    hash = [];
  end

  methods
    function obj = Unique()
      obj.hash = util.KeyGen.sha1();
    end
  end
end
