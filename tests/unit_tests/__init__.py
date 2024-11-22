import importlib
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', '..'))

import DOVE.src._utils as dutils

if importlib.util.find_spec("ravenframework") is None:
  sys.path.append(dutils.get_raven_loc())
