#!/bin/sh
set -eu

# Docker's current seccomp profile blocks Chrome's nested sandbox. Keep the
# container restrictions in place and run this demo browser without its own
# sandbox; do not use this launcher for sensitive browsing. Skip Chrome's
# first-run dialog, whose buttons are hidden below the noVNC viewport.
exec /usr/bin/google-chrome-stable --no-sandbox --no-first-run --no-default-browser-check "$@"
