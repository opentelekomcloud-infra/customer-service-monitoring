# Package for acceptance tests

import os
import unittest

_IS_ACCEPTANCE = bool(os.getenv("CSM_ACC"))

if not _IS_ACCEPTANCE:
    raise unittest.SkipTest("Skip acceptance tests when 'CSM_ACC' is not set")
