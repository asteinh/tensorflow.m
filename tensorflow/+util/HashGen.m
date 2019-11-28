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
      if isOctave
        obj.sha256_fcn = @(str) hash('SHA256', str);
        obj.sha1_fcn   = @(str) hash('SHA1', str);
      else
        % caching generators in Matlab
        obj.generators.sha256 = java.security.MessageDigest.getInstance('SHA-256');
        obj.generators.sha1 = java.security.MessageDigest.getInstance('SHA-1');
        obj.sha256_fcn = @(str) obj.generators.sha256.digest(str);
        obj.sha1_fcn   = @(str) obj.generators.sha1.digest(str);
      end
    end

    function [h, hs] = sha256(obj, str)
      if nargin ~= 2 || isempty(str); str = obj.gen_string(); end
      h = sprintf('%2.2x', typecast(obj.sha256_fcn(uint8(str)), 'uint8')');
      hs = h(1:8);
    end

    function [h, hs] = sha1(obj, str)
      if nargin ~= 2 || isempty(str); str = obj.gen_string(); end
      h = sprintf('%2.2x', typecast(obj.sha1_fcn(uint8(str)), 'uint8')');
      hs = h(1:8);
    end
  end

  methods (Access=private)
    function s = gen_string(obj)
      t = now();
      s = [datestr(t, 'hh:MM:ss:FFF@') char(floor(94*rand(1, 16)) + 32) datestr(t, '@dd-mm-yyyy')];
    end
  end
end
