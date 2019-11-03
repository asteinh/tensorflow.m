classdef KeyGen
  properties (Constant)
    sha256_ = java.security.MessageDigest.getInstance('SHA-256');
    sha1_ = java.security.MessageDigest.getInstance('SHA-1');
  end

  methods (Static)
    function s = gen_string()
      t = now();
      s = [datestr(t, 'hh:MM:ss:FFF@') char(floor(94*rand(1, 16)) + 32) datestr(t, '@dd-mm-yyyy')];
    end

    function [h, hs] = sha256(string)
      if nargin ~= 1 || isempty(string); string = util.KeyGen.gen_string(); end;
      h = sprintf('%2.2x', typecast(util.KeyGen.sha256_.digest(uint8(string)), 'uint8')');
      hs = h(1:8);
    end

    function [h, hs] = sha1(string)
      if nargin ~= 1 || isempty(string); string = util.KeyGen.gen_string(); end;
      h = sprintf('%2.2x', typecast(util.KeyGen.sha1_.digest(uint8(string)), 'uint8')');
      hs = h(1:8);
    end
  end
end
