#! /usr/bin/env zsh

function run {
	if ! pgrep $1; then
		$@&
	fi
}

run dropbox start > /dev/null 2>&1 
run cmus-daemon

# Load this late
if [[ $(/bin/hostname) == "weyl" ]]; then
    run xcompmgr -D5 -I.05 -O.05 -c -f -F -C -t-5 -l-5 -r4.2 -o.55
    run /usr/bin/env XDG_CURRENT_DESKTOP=Unity stretchly > /dev/null 2>&1
    run blueproximity
fi
