#!/bin/bash

# cleanup
rm -rf MOxUnit && rm -rf MOcov && rm -rf results

# clone required repositories
git clone git@github.com:MOxUnit/MOxUnit.git
git clone git@github.com:MOcov/MOcov.git

# output directory
mkdir results
