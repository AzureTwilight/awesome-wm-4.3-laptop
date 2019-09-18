#! /usr/bin/env zsh

function run {
	if ! pgrep $1; then
		$@&
	fi
}

# run compton
run xcompmgr -D5 -I.05 -O.05 -c -f -F -C -t-5 -l-5 -r4.2 -o.55
run ibus-daemon -drx
run cmus-daemon

run aria2c > /dev/null 2>&1
run /usr/bin/env XDG_CURRENT_DESKTOP=Unity stretchly > /dev/null 2>&1

sleep 3
run dropbox start > /dev/null 2>&1 

# Load this late
sleep 3
run blueproximity

sleep 3
run python3.7 -m http.server --directory $HOME/local-server > /tmp/local-server.log 2>&1
