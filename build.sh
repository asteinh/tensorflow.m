matlab \
  -nodisplay \
  -nosplash \
  -nodesktop \
  -r "try; addpath('tensorflow'); DEBUG = true; tensorflow.build(); catch e; disp(e.message); end; quit"
