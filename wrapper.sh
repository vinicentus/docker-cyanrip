#!/bin/sh
set -e

# Quote each argument for the inner shell: wrap in single quotes, escape ' as '\''
# so the -c string passes args through without space/split or quoting issues
quoted=""
for a in "$@"; do
  safe=$(echo "$a" | /usr/local/bin/sed "s/'/'\\\\''/g")
  quoted="$quoted '$safe'"
done

# Execute cyanrip inside a PTY; normalize CRLF to LF, then standalone \r (progress bar) to \n
# (tr '\r' '\n' would turn \r\n into \n\n and create extra blank lines)
exec /usr/local/bin/script -q -c "/usr/local/bin/cyanrip $quoted" /dev/null | /usr/local/bin/sed -e 's/\r$//' -e 's/\r/\n/g'
