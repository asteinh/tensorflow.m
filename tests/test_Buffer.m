clear; clc;
addpath('../tensorflow');

% empty Buffer (de)allocation
buf = tensorflow.Buffer();
assert(isempty(buf.data()));
clear buf

% Buffer with length 1000
buf = tensorflow.Buffer();
data_tx = random_char_arr(1000);
buf.data(data_tx);
data_rx = buf.data();
assert(sum(uint8(data_tx)-data_rx) == 0)
clear buf data_rx data_tx

function str = random_char_arr(len)
  symbols = ['a':'z' 'A':'Z' '0':'9'];
  nums = randi(numel(symbols), [1 len]);
  str = symbols(nums);
end