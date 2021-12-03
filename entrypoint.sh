#!/bin/bash

# Startup Xvfb
Xvfb -ac :99 -screen 0 1280x1024x16 > /dev/null 2>&1 &

# Export some variables
export DISPLAY=:99.0
export PUPPETEER_EXEC_PATH="google-chrome-stable"

# Run commands
x="$@"
readarray -t commands <<<"$x"

for command in "${commands[@]}" ; do {
    echo "Running '$command'!"

    # Check for background process operator
    # This wouldn't work here if we simply ran the command as is
    if [ "${command: -1}" = "&" ]; then
        echo "This is a background process (parallel command)"
        # remove trailing whitespace
        command="${command%"${command##*[![:space:]]}"}"
        # remove background process operator
        newcommand=${command::-1}
        # execute command with background process operator added back in
        $newcommand &
    else
        echo "This is a regular process (serial command)"
        $command
    fi
} done
