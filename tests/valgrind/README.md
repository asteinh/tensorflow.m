Run a script in Matlab/valgrind via:

```bash
matlab \
  -nodisplay \
  -nosplash \
  -nodesktop \
  -r "try; test(); catch e; disp(e.message); end; quit" \
  -D"valgrind --keep-debuginfo=yes --leak-check=full --show-leak-kinds=definite --track-origins=yes --verbose --log-file=valgrind.log"
```

*NOTE:* `"--keep-debuginfo=yes"` requires valgrind >= 3.14
