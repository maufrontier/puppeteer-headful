#!/bin/sh

# Startup Xvfb
Xvfb -ac :99 -screen 0 1280x1024x16 > /dev/null 2>&1 &

# Export some variables
export DISPLAY=:99.0
export PUPPETEER_EXEC_PATH="google-chrome-stable"

# Run commands
for task in "$@"; do {
  echo "Running '$cmd'!"
  $task &
  if $task; then
        # no op
        echo "Successfully ran '$task'"
    else
        exit_code=$?
        echo "Failure running '$task', exited with $exit_code"
        exit $exit_code
    fi
} done
