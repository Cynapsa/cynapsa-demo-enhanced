#!/bin/sh
cd /opt/cynapsa-enhanced/files || exit 1
printf '\nFiles agent is stopped. Start it when ready:\n  ./run.sh\n\n'
exec /bin/bash -i
