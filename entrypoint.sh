#!/bin/sh
set -e

# Execute cyanrip inside a PTY and normalize CR to LF
exec script -q -c "/usr/local/bin/cyanrip $*" /dev/null | tr '\r' '\n'
