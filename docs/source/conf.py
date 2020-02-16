import os, sys
this_dir = os.path.abspath('.')

# for autodoc
sys.path.insert(0, os.path.abspath('../../'))

import recommonmark
from recommonmark.parser import CommonMarkParser
source_parsers = { '.md': CommonMarkParser }

# GENERAL
project = 'tensorflow.m'
copyright = '2020'
author = 'Armin Steinhauser'
extensions = [
    'sphinxcontrib.matlab',
    'sphinx.ext.autodoc',
    'sphinx.ext.napoleon',
    'sphinx.ext.githubpages',
    'sphinx.ext.mathjax'
]
exclude_patterns = []

# MATLAB
matlab_src_dir = os.path.abspath(os.path.join(this_dir, '../../tensorflow'))
matlab_keep_package_prefix = False
primary_domain = 'mat'

# HTML
html_theme = 'press' # 'sphinx_rtd_theme'
html_static_path = ['_static']

source_suffix = ['.rst', '.md']

from recommonmark.transform import AutoStructify
def setup(app):
    app.add_config_value('recommonmark_config', {
            'enable_math': True,
            'enable_eval_rst': True,
            'auto_code_block': True,
            }, True)
    app.add_transform(AutoStructify)
