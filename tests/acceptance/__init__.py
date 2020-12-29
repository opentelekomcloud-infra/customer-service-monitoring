# Package for acceptance tests

import unittest

from tests.utils import IS_ACCEPTANCE

if not IS_ACCEPTANCE:
    raise unittest.SkipTest("Skip acceptance tests when 'CSM_ACC' is not set")
