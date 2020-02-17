#!/usr/bin/python3

# Import modules
import sys
import subprocess
import ipaddress
import argparse
import logging as log

# We need to declare these elsewhere
# Declare
infile=""
outfile="outfile.txt"

# Include

# Read file containing subnets
# Do we use CIDR format?
# Do we want unique IP addresses?

# Create a parser for our arguments
parser = argparse.ArgumentParser(description='Scan a network based on user input. This can be used to scan a single address or a range if addresses, provided in CIDR  notation.')
parser.add_argument("-v", "--verbose", action="store_true")
parser.add_argument("-q", "--quiet", action="store_true")
parser.add_argument("-i", "--infile", help="input file. This expects subnets in CIDR notation.")
parser.add_argument("-o", "--outfile", help="output file. This will out put the result of a scan. default: outfile.txt", default="outfile.txt")
parser.add_argument("-S", "--singleton", help="Scan a single IP address from the command line.")
parser.add_argument("-c", "--cidr", help="Scan a CIDR range ie 10.0.0.0/24 which would scan address range 10.0.0.0 - 10.0.0.255")

# rename parse_args to something more managable
args = parser.parse_args()

# Some sanity tests
# If no arguments are provided, help and exit
if args.cidr:
  net_addr = args.cidr
  scanRange(net_addr)
elif args.singleton:
  net_addr = args.singleton
elif args.infile:
  print(args.infile)
else:
  parser.print_help() 
  sys.exit()

if args.verbose:
  log.basicConfig(format="%(levelname)s: %(message)s", level=log.DEBUG)
  log.info("CIDR:    ", args.cidr)
else:
  log.basicConfig(format="%(levelname)s: %(message)s")

# subroutine to scan a range of addresses
def scanRange():
  # Create the network
  ip_net = ipaddress.ip_network(net_addr, strict=False)
  for host in ip_net.hosts():
    print (host)
  
  # Get all hosts on that network
  all_hosts = list(ip_net.hosts())
  
  # Configure subprocess to hide the console window
  info = subprocess.STARTUPINFO()
  info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
  info.wShowWindow = subprocess.SW_HIDE
  
  # For each IP address in the subnet, 
  # run the ping command with subprocess.popen interface
  for i in range(len(all_hosts)):
      output = subprocess.Popen(['ping', '-n', '1', '-w', '500', str(all_hosts[i])], stdout=subprocess.PIPE, startupinfo=info).communicate()[0]
      if "Destination host unreachable" in output.decode('utf-8'):
          print(str(all_hosts[i]), "is Offline")
      elif "Request timed out" in output.decode('utf-8'):
          print(str(all_hosts[i]), "is Offline")
      else:
          print(str(all_hosts[i]), "is Online")

# TODO
# All a comma-seperated range as an input
# Allow the --cidr option to define the contents of infile
# Otherwise allow a comma-separated range fro infile
