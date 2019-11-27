classdef Typewriter < handle
  %TYPEWRITER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Access=private)
    text = {};
  end
  
  methods
    function obj = Typewriter()
      % ...
    end
    
    function txt = getText(obj)
      txt = obj.text;
    end
    
    function addLine(obj, line)
      obj.text = [ obj.text; { line } ];
    end
    
    function addEmptyLine(obj)
      obj.text = [ obj.text; { ' ' } ];
    end
    
    % convenience overloads
    function lt(obj, line)
      if iscell(line)
        obj.text = [ obj.text; line ];
      else
        obj.addLine(line);
      end
    end
    
    function le(obj, line)
      obj < line;
      obj.addEmptyLine();
    end
  end
end

