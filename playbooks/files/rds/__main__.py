#!/usr/bin/env python3

from pg2.db_methods import main as pg2_main
from sqla.db_methods import main as sqla_main

from arg_parser import get_run_option
import os
import sys

sys.path.append(os.path.dirname(os.path.realpath(__file__)))


if get_run_option() == "pg2":
    pg2_main()
if get_run_option() == "sqla":
    sqla_main()

