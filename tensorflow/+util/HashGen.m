classdef HashGen < handle
  %HASHGEN Summary of this class goes here
  %   Detailed explanation goes here

  properties (Access=private)
    generators = [];
    sha256_fcn = [];
    sha1_fcn = [];
  end

  methods
    function obj = HashGen()
      if (exist('OCTAVE_VERSION', 'builtin') ~= 0)
        % we're on Octave
        obj.sha256_fcn = @(str) hash('SHA256', str);
        obj.sha1_fcn   = @(str) hash('SHA1', str);
      else
        % caching generators in Matlab
        obj.generators.sha256 = java.security.MessageDigest.getInstance('SHA-256');
        obj.generators.sha1 = java.security.MessageDigest.getInstance('SHA-1');
        obj.sha256_fcn = @(str) sprintf('%2.2x', typecast(obj.generators.sha256.digest(uint8(str)), 'uint8'));
        obj.sha1_fcn   = @(str) sprintf('%2.2x', typecast(obj.generators.sha1.digest(uint8(str)), 'uint8'));
      end
    end

    function [h, hs] = sha256(obj, str)
      if nargin ~= 2 || isempty(str); str = obj.gen_string_(); end
      h = sprintf('%s', obj.sha256_fcn(str));
      hs = h(1:8);
    end

    function [h, hs] = sha1(obj, str)
      if nargin ~= 2 || isempty(str); str = obj.gen_string_(); end
      h = sprintf('%s', obj.sha1_fcn(str));
      hs = h(1:8);
    end
  end

  methods (Access=private)
    function s = gen_string_(obj)
      t = now();
      s = [datestr(t, 'hh:MM:ss:FFF@') char(floor(94*rand(1, 16)) + 32) datestr(t, '@dd-mm-yyyy')];
    end
  end
end
