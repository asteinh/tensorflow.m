function randres = rand_tensor(dims, type)
  if any(strcmp(type, { 'double', 'single' }))
    randres = randn(dims)*1e6;
  elseif strcmp(type, 'logical')
    randres = round(rand(dims));
  elseif any(strcmp(type, { 'int64', 'int32', 'int16', 'int8' }))
    randres = round(2*(rand(dims)-0.5)*min(1e6, double(intmax(type))));
  elseif any(strcmp(type, { 'uint64', 'uint32', 'uint16', 'uint8' }))
    randres = round(rand(dims)*min(1e6, double(intmax(type))));
  elseif strcmp(type, 'complex')
    error('Not implemented.');
  else
    error('Not supported.');
  end
  
  randres = cast(randres, type);
end

