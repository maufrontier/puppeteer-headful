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
    if [ "${command: -1}" = "&" ]; then
        echo "This is a parallel command"
        newcommand=${command::-1}
        $newcommand &
    else
        echo "This is a serial command"
        $command
    fi
} done
