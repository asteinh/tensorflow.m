#!/bin/bash

# cleanup
rm -rf MOxUnit && rm -rf MOcov && rm -rf results

# clone required repositories
git clone https://github.com/MOxUnit/MOxUnit.git
git clone https://github.com/MOcov/MOcov.git

# output directory
mkdir results
