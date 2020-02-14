#!/usr/bin/python3

# Use the logging module to perform the duties of a 
# 'verbose' switch for a script

import logging as log
import argparse

args = p.parse_args()
if args.verbose:
  log.basicConfig(format="%(levelname)s: %(message)s", level=log.DEBUG)
  log.info("Verbose output.")
else:
  log.basicConfig(format="%(levelname)s: %(message)s")

log.info("This should be verbose.")
log.warning("This is a warning.")
log.error("This is an error.")
