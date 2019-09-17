#! /usr/bin/env zsh

function run {
	if ! pgrep $1; then
		$@&
	fi
}

# run compton
run xcompmgr -D5 -I.05 -O.05 -c -f -F -C -t-5 -l-5 -r4.2 -o.55

ibus-daemon -drx
dropbox start
# run cmus-daemon

# run aria2c > /dev/null 2>&1
